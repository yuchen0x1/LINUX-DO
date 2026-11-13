import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html;

void main() {
  test(
    'html 0.15.7 supports rendered CSS class, child and attribute selectors',
    () {
      final element = html
          .parseFragment(
            '<section><p class="notice" data-kind="info">body</p></section>',
          )
          .querySelector('p')!;
      final styled = StyledElement(name: 'p', style: Style(), node: element);

      expect(styled.matchesSelector('.notice'), isTrue);
      expect(styled.matchesSelector('section > p[data-kind="info"]'), isTrue);
      expect(styled.matchesSelector('section .notice'), isTrue);
      expect(styled.matchesSelector('.missing'), isFalse);
      expect(styled.matchesSelector('p[data-kind="warning"]'), isFalse);
    },
  );

  test('an empty CSS selector does not match or interrupt rendering', () {
    final element = html.parseFragment('<p>body</p>').querySelector('p')!;
    final styled = StyledElement(name: 'p', style: Style(), node: element);
    expect(styled.matchesSelector(''), isFalse);
  });
}
