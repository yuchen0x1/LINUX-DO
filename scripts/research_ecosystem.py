#!/usr/bin/env python3
"""Read-only GitHub research; bounded samples, no code execution or remote writes.

Uses gh's existing authentication (or GITHUB_TOKEN in Actions). Raw evidence is
saved under ignored dist/; only small metadata and evidence links are published.
"""
import argparse
import base64
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone
import json
import hashlib
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
PROJECTS = [
    ('R-lz/LINUX-DO', 'direct', '上游功能、Android 网络边界'),
    ('ruezo/LINUX-DO', 'direct', '同源客户端维护策略'),
    ('Lingyan000/fluxdo', 'direct', '论坛阅读与自适应导航'),
    ('1molchuan/CFluxDo', 'direct', '论坛跨平台实现成本'),
    ('wshhfy/V2DO', 'direct', '多社区阅读体验'),
    ('xiaojia21190/linux_do_web', 'direct', 'WebView 与独立客户端区别'),
    ('discourse/DiscourseMobile', 'direct', '官方移动认证和站点集成'),
    ('discourse/discourse', 'protocol', '论坛 API、权限和响应式网页'),
    ('discourse/discourse_api', 'protocol', 'API 合同与错误处理'),
    ('discourse/message_bus', 'protocol', '通知游标、长轮询生命周期'),
    ('discourse/discourse-chat-integration', 'protocol', '聊天通知的权限边界'),
    ('discourse/discourse-reactions', 'protocol', '表态接口兼容性'),
    ('discourse/discourse-docker', 'deployment', '服务端运维与客户端职责区别'),
    ('flarum/framework', 'adjacent', '扩展式论坛模块边界'),
    ('NodeBB/NodeBB', 'adjacent', '实时论坛、响应式导航'),
    ('LemmyNet/lemmy', 'adjacent', '社区 API 和服务端权限'),
    ('LemmyNet/lemmy-ui', 'adjacent', '浏览器社区体验与 PWA'),
    ('thunder-app/thunder', 'adjacent', 'Flutter 社区客户端导航'),
    ('Liftoff-app/liftoff', 'adjacent', '移动社区阅读和活跃度风险'),
    ('imranr98/obtainium', 'updating', '按架构选择资产和系统安装'),
    ('localsend/localsend', 'updating', '多平台发布与安装文档'),
    ('flutter/flutter', 'framework', '大屏、无障碍和平台实现'),
    ('flutter/packages', 'library', '包信息、文件存储和平台插件'),
    ('cfug/dio', 'library', '下载取消、超时、进度与拦截器'),
    ('pichillilorenzo/flutter_inappwebview', 'library', '认证网页及平台代理能力'),
    ('juliansteenbakker/flutter_secure_storage', 'library', '凭据迁移与安全存储'),
    ('Baseflow/flutter-permission-handler', 'library', '按需申请权限'),
    ('MaikuB/flutter_local_notifications', 'library', '通知授权和平台差异'),
    ('llfbandit/app_links', 'library', '冷启动和热启动深链'),
    ('fluttercommunity/plus_plugins', 'library', '分享、设备 ABI、包信息'),
]


def api(path, accept=None):
    cmd = ['gh', 'api', path]
    if accept:
        cmd += ['-H', 'Accept: ' + accept]
    cache = ROOT / 'dist/research-api' / (hashlib.sha256(path.encode()).hexdigest() + '.json')
    if cache.exists():
        return json.loads(cache.read_text(encoding='utf-8'))
    try:
        result = subprocess.run(cmd, capture_output=True, timeout=90)
    except subprocess.TimeoutExpired:
        return {'error': 'GitHub request timed out after 90s'}
    if result.returncode:
        return {'error': result.stderr.decode('utf-8', errors='replace')[:240]}
    try:
        data = json.loads(result.stdout)
        cache.parent.mkdir(parents=True, exist_ok=True)
        cache.write_text(json.dumps(data), encoding='utf-8')
        return data
    except ValueError:
        return {'error': 'non-JSON response'}


def inspect(project):
    repo, category, focus = project
    prefix = f'repos/{repo}'
    raw_dir = ROOT / 'dist/research' / repo.replace('/', '__')
    def evidence(name, path):
        target = raw_dir / f'{name}.json'
        if target.exists():
            saved = json.loads(target.read_text(encoding='utf-8'))
            if not isinstance(saved, dict) or 'error' not in saved:
                return saved
        return api(path)
    metadata = evidence('metadata', prefix)
    if 'error' in metadata:
        return dict(repo=repo, category=category, focus=focus, error=metadata['error'])
    branch = metadata['default_branch']
    readme = evidence('readme', prefix + '/readme')
    tree = evidence('tree', prefix + f'/git/trees/{branch}?recursive=1')
    releases = evidence('releases', prefix + '/releases?per_page=3')
    issues = evidence('issues', prefix + '/issues?state=all&sort=updated&per_page=8')
    commits = evidence('commits', prefix + '/commits?per_page=100')
    files = [x['path'] for x in tree.get('tree', []) if x['type'] == 'blob']
    candidates = [p for p in files if p.endswith(('.dart', '.kt', '.rb', '.ts', '.tsx', '.js', '.go', '.rs'))
                  and any(p.startswith(d) for d in ('lib/', 'src/', 'app/', 'packages/'))
                  and not any(x in p for x in ('.g.dart', '/test', '/vendor/', '/generated/'))]
    candidates.sort(key=lambda p: (not any(x in p.lower() for x in ('update', 'download', 'auth', 'main.')), len(p)))
    source_path = candidates[0] if candidates else None
    source = evidence('source', prefix + f'/contents/{source_path}?ref={branch}') if source_path else {}
    raw_dir.mkdir(parents=True, exist_ok=True)
    for name, data in dict(metadata=metadata, readme=readme, tree=tree, releases=releases,
                           issues=issues, commits=commits, source=source).items():
        (raw_dir / f'{name}.json').write_text(json.dumps(data, ensure_ascii=False), encoding='utf-8')
    now = datetime.now(timezone.utc)
    activity = {}
    for days in (30, 90, 180):
        count = sum((now - datetime.fromisoformat(c['commit']['committer']['date'].replace('Z', '+00:00'))).days < days
                    for c in commits) if isinstance(commits, list) else 0
        activity[str(days)] = dict(sample_count=count, bounded_to_latest_100=True)
    latest = releases[0] if isinstance(releases, list) and releases else {}
    return dict(repo=metadata['full_name'], category=category, focus=focus,
                stars=metadata['stargazers_count'], forks=metadata['forks_count'],
                pushed_at=metadata['pushed_at'], archived=metadata['archived'],
                license=(metadata.get('license') or {}).get('spdx_id', 'UNKNOWN'),
                language=metadata['language'], description=metadata.get('description'),
                latest_release=latest.get('tag_name'), latest_release_date=latest.get('published_at'),
                activity=activity, source=source_path, source_sha=source.get('sha'),
                readme_sha=readme.get('sha'), tree_truncated=tree.get('truncated'),
                workflow_count=sum(p.startswith('.github/workflows/') for p in files),
                tests_present=any('/test' in p or p.startswith(('test/', 'spec/')) for p in files),
                issue_samples=[dict(title=i['title'], url=i['html_url']) for i in issues
                               if 'pull_request' not in i] if isinstance(issues, list) else [],
                source_bytes=source.get('size', 0))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', default='docs/research/ecosystem-snapshot.json')
    args = parser.parse_args()
    with ThreadPoolExecutor(max_workers=4) as executor:
        data = list(executor.map(inspect, PROJECTS))
    target = ROOT / args.output
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(dict(checked_at=datetime.now(timezone.utc).isoformat(),
                                     method='GitHub API; latest 100 commits, 8 issues, 3 releases; one source file per repository',
                                     projects=data), ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'Researched {len(data)} repositories; {sum("error" in p for p in data)} unavailable. Evidence: {target}')
    return 1 if any('error' in p for p in data) else 0


if __name__ == '__main__':
    raise SystemExit(main())
