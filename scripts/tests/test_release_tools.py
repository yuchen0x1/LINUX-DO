"""Release gates exercised with temporary source files and mocked apksigner."""
import hashlib
import io
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

from scripts import release_tools


CERTIFICATE = '4b0e72061c8d08da00cf99f8bc3e6df730530965f9b1c8ba9803a66e28bdd517'
RELEASE_BODY = (
    '## 📢 版本概述\n\n维护更新。\n\n'
    '## 更新内容\n\n- 修复发布正文。\n\n'
    '## 下载与升级\n\n保留原签名以支持覆盖升级。\n'
)
APK_CONTENTS = {
    'arm64-v8a': b'fixture arm64 APK\x00\xff',
    'armeabi-v7a': b'fixture armv7 APK\x01',
    'x86_64': b'fixture x86_64 APK\x02\xfe',
}


class ReleaseToolsTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        root_patch = mock.patch.object(release_tools, 'ROOT', self.root)
        root_patch.start()
        self.addCleanup(root_patch.stop)
        self.write('pubspec.yaml', 'name: fixture\nversion: 1.2.3+42\n')
        self.apk_dir = self.root / 'apks'
        self.output = self.root / 'dist/release'
        self.signer = self.root / 'apksigner'

    def write(self, relative_path, text):
        path = self.root / relative_path
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding='utf-8')
        return path

    def prepare_package(self):
        self.apk_dir.mkdir()
        for abi, content in APK_CONTENTS.items():
            (self.apk_dir / f'app-{abi}-release.apk').write_bytes(content)
        self.write('docs/releases/release-notes-v1.2.3.md', RELEASE_BODY)
        self.write('android/network-core.lock.json', json.dumps({
            'repository': 'https://example.com/network-core',
            'commit': 'fixture-source-commit',
        }))
        self.write('assets/licenses/network-core-NOTICE.txt', 'Fixture core notice\n')

    @staticmethod
    def signed_result(certificate=CERTIFICATE):
        return subprocess.CompletedProcess(
            [], 0, stdout=f'Signer #1 certificate SHA-256 digest: {certificate}\n',
            stderr='')

    def test_version_parses_version_and_integer_build(self):
        self.write('pubspec.yaml', '# version: 9.9.9+99\nversion: 1.20.300+0042\n\n')
        self.assertEqual(release_tools.version(), ('1.20.300', 42))

    def test_version_rejects_missing_or_invalid_version(self):
        for text in ('name: fixture\n', 'version: 1.2.3\n',
                     'version: 1.2+42\n', 'version: 1.2.3+invalid\n',
                     'version: 1.2.3+-1\n', 'version: 1.2.3-rc.1+42\n'):
            with self.subTest(text=text):
                self.write('pubspec.yaml', text)
                with self.assertRaisesRegex(ValueError, 'SemVer\\+integer build number'):
                    release_tools.version()

    def test_version_command_rejects_mismatched_tag(self):
        with mock.patch.object(sys, 'argv', ['release_tools.py', 'version',
                                            '--tag', 'v1.2.4']), \
                mock.patch('sys.stderr', new_callable=io.StringIO) as stderr:
            with self.assertRaises(SystemExit) as error:
                release_tools.main()
        self.assertEqual(error.exception.code, 2)
        self.assertIn('Tag and source version differ', stderr.getvalue())

    def test_version_command_accepts_standalone_notes_without_changelog(self):
        self.write('docs/releases/release-notes-v1.2.3.md', RELEASE_BODY)
        with mock.patch.object(sys, 'argv', ['release_tools.py', 'version',
                                            '--tag', 'v1.2.3']), \
                mock.patch('sys.stdout', new_callable=io.StringIO) as stdout:
            release_tools.main()
        self.assertEqual(stdout.getvalue(), '1.2.3+42\n')

    def test_standalone_notes_preserve_template_and_take_precedence(self):
        self.write('docs/releases/release-notes.md', '## v1.2.3\n\nLegacy notes.\n')
        self.write('docs/releases/release-notes-v1.2.3.md', '\n' + RELEASE_BODY + '\n')
        self.assertEqual(release_tools.notes('v1.2.3'), RELEASE_BODY)

    def test_standalone_notes_reject_empty_text_without_fallback(self):
        self.write('docs/releases/release-notes.md', '## v1.2.3\n\nLegacy notes.\n')
        for text in ('', ' \n\t\n'):
            with self.subTest(text=text):
                self.write('docs/releases/release-notes-v1.2.3.md', text)
                with self.assertRaisesRegex(ValueError, 'No release notes for v1.2.3'):
                    release_tools.notes('v1.2.3')

    def test_standalone_notes_require_overview_heading(self):
        self.write('docs/releases/release-notes.md', '## v1.2.3\n\nLegacy notes.\n')
        for text in ('## v1.2.3\n\n' + RELEASE_BODY,
                     '## 更新内容\n\nSome changes.\n',
                     '## 📢 版本概述 extra\n\nSome changes.\n'):
            with self.subTest(text=text):
                self.write('docs/releases/release-notes-v1.2.3.md', text)
                with self.assertRaisesRegex(ValueError, 'must start with'):
                    release_tools.notes('v1.2.3')

    def test_notes_fall_back_to_requested_historical_section(self):
        section = '## v1.2.3 · 2026-01-02\n\nLegacy notes.\n\n### Fixes\n\n- Fixed.\n'
        self.write('docs/releases/release-notes.md',
                   '# Changelog\n\n## v1.2.4\n\nNewer.\n\n' + section +
                   '\n## v1.2.2\n\nOlder.\n')
        self.write('docs/releases/release-notes-v1.2.4.md', RELEASE_BODY)
        self.assertEqual(release_tools.notes('v1.2.3'), section)

    def test_notes_reject_missing_or_empty_historical_section(self):
        for text in ('## v1.2.2\n\nAnother version.\n',
                     '## v1.2.3\n\n \t\n## v1.2.2\n\nOlder.\n',
                     '## v1.2.3\n\n'):
            with self.subTest(text=text):
                self.write('docs/releases/release-notes.md', text)
                with self.assertRaisesRegex(ValueError, 'No release notes for v1.2.3'):
                    release_tools.notes('v1.2.3')

    def test_package_rejects_mismatched_tag_before_signing(self):
        with mock.patch.object(release_tools.subprocess, 'run') as run:
            for tag in ('v1.2.4', '1.2.3', 'v1.2.30'):
                with self.subTest(tag=tag):
                    with self.assertRaisesRegex(ValueError, 'Tag does not match source version'):
                        release_tools.package(self.apk_dir, self.output, self.signer, tag)
            run.assert_not_called()
        self.assertFalse(self.output.exists())

    def test_package_verifies_three_abis_and_writes_matching_assets(self):
        self.prepare_package()
        with mock.patch.object(release_tools.subprocess, 'run',
                               return_value=self.signed_result(CERTIFICATE.upper())) as run, \
                mock.patch('sys.stdout', new_callable=io.StringIO):
            release_tools.package(self.apk_dir, self.output, self.signer, 'v1.2.3')
        self.assertEqual(run.call_args_list, [
            mock.call([str(self.signer), 'verify', '--verbose', '--print-certs',
                       str(self.apk_dir / f'app-{abi}-release.apk')],
                      check=True, capture_output=True, text=True)
            for abi in APK_CONTENTS
        ])
        expected_assets = []
        sums = []
        for abi, content in APK_CONTENTS.items():
            name = f'linux_do_android_release_1.2.3_{abi}.apk'
            digest = hashlib.sha256(content).hexdigest()
            self.assertEqual((self.output / name).read_bytes(), content)
            sums.append(f'{digest}  {name}')
            expected_assets.append({
                'abi': abi, 'name': name, 'size': len(content), 'sha256': digest,
                'url': f'https://github.com/yuchen0x1/LINUX-DO/releases/download/v1.2.3/{name}',
            })
        metadata = json.loads((self.output / 'android-update.json').read_text(encoding='utf-8'))
        self.assertEqual(metadata, {
            'schema_version': 1, 'version': '1.2.3', 'build_number': 42,
            'platform': 'android', 'min_sdk': 23, 'mandatory': False,
            'certificate_sha256': CERTIFICATE, 'assets': expected_assets,
        })
        self.assertEqual((self.output / 'SHA256SUMS-v1.2.3.txt').read_text(encoding='utf-8'),
                         '\n'.join(sums) + '\n')
        self.assertEqual((self.output / 'release-notes-v1.2.3.md').read_text(encoding='utf-8'),
                         RELEASE_BODY)
        self.assertEqual((self.output / 'network-core-NOTICE.txt').read_text(encoding='utf-8'),
                         'Fixture core notice\n\nExact source: '
                         'https://example.com/network-core/tree/fixture-source-commit\n')
        self.assertEqual({path.name for path in self.output.iterdir()},
                         {asset['name'] for asset in expected_assets} |
                         {'android-update.json', 'SHA256SUMS-v1.2.3.txt',
                          'release-notes-v1.2.3.md', 'network-core-NOTICE.txt'})

    def test_package_rejects_bad_certificates_without_writing_metadata(self):
        self.prepare_package()
        valid = self.signed_result()
        for stdout in (self.signed_result('0' * 64).stdout, '',
                       valid.stdout + f'Signer #2 certificate SHA-256 digest: {CERTIFICATE}\n'):
            with self.subTest(stdout=stdout):
                invalid = subprocess.CompletedProcess([], 0, stdout=stdout, stderr='')
                with mock.patch.object(release_tools.subprocess, 'run',
                                       side_effect=[valid, valid, invalid]) as run:
                    with self.assertRaisesRegex(ValueError, 'x86_64: signing certificate differs'):
                        release_tools.package(self.apk_dir, self.output, self.signer, 'v1.2.3')
                self.assertEqual(run.call_count, 3)
                self.assertFalse(self.output.exists())

    def test_package_rejects_apksigner_failure_without_writing_metadata(self):
        self.prepare_package()
        with mock.patch.object(release_tools.subprocess, 'run',
                               side_effect=subprocess.CalledProcessError(1, 'apksigner')):
            with self.assertRaises(subprocess.CalledProcessError):
                release_tools.package(self.apk_dir, self.output, self.signer, 'v1.2.3')
        self.assertFalse(self.output.exists())


if __name__ == '__main__':
    unittest.main()
