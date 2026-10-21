import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  group('buildShareCaption', () {
    test('includes headline, stat lines, app name and hashtag', () {
      const moment = ShareableMoment(
        appName: 'Komovia将棋',
        headline: '勝利！',
        statLines: ['対戦相手: AI Lv.8', '手数: 42手'],
        hashtag: '#Komovia将棋',
      );

      final caption = buildShareCaption(moment);

      expect(caption, '''
勝利！

対戦相手: AI Lv.8
手数: 42手

Komovia将棋 #Komovia将棋''');
    });

    test('omits the stat-lines blank section when there are none', () {
      const moment = ShareableMoment(
        appName: 'Komovia囲碁',
        headline: '詰碁クリア！',
      );

      final caption = buildShareCaption(moment);

      expect(caption, '''
詰碁クリア！

Komovia囲碁''');
    });

    test('omits the hashtag when none is given', () {
      const moment = ShareableMoment(
        appName: 'Komoviaチェス',
        headline: '5連勝達成！',
      );

      final caption = buildShareCaption(moment);

      expect(caption.endsWith('Komoviaチェス'), isTrue);
      expect(caption.contains('#'), isFalse);
    });

    test('appends the store URL as its own trailing line when given', () {
      const moment = ShareableMoment(
        appName: 'Komovia将棋',
        headline: '勝利！',
      );

      final caption = buildShareCaption(
        moment,
        storeUrl: 'https://play.google.com/store/apps/details?id=com.yourwish.shogi',
      );

      expect(
        caption,
        '勝利！\n\nKomovia将棋\nhttps://play.google.com/store/apps/details?id=com.yourwish.shogi',
      );
    });

    test('ignores an empty store URL', () {
      const moment = ShareableMoment(appName: 'Komovia囲碁', headline: '勝利！');

      final caption = buildShareCaption(moment, storeUrl: '');

      expect(caption, '勝利！\n\nKomovia囲碁');
    });
  });

  group('ShareableMoment', () {
    test('equality and hashCode consider every field including statLines', () {
      const a = ShareableMoment(
        appName: 'Komovia将棋',
        headline: '勝利！',
        statLines: ['手数: 42手'],
        hashtag: '#Komovia将棋',
      );
      const b = ShareableMoment(
        appName: 'Komovia将棋',
        headline: '勝利！',
        statLines: ['手数: 42手'],
        hashtag: '#Komovia将棋',
      );
      const c = ShareableMoment(
        appName: 'Komovia将棋',
        headline: '勝利！',
        statLines: ['手数: 50手'],
        hashtag: '#Komovia将棋',
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });

    test('copyWith can explicitly clear the nullable hashtag', () {
      const moment = ShareableMoment(
        appName: 'Komovia将棋',
        headline: '勝利！',
        hashtag: '#Komovia将棋',
      );

      final cleared = moment.copyWith(hashtag: null);

      expect(cleared.hashtag, isNull);
      expect(cleared.headline, moment.headline);
    });

    test('copyWith leaves fields untouched when not passed', () {
      const moment = ShareableMoment(
        appName: 'Komovia将棋',
        headline: '勝利！',
        hashtag: '#Komovia将棋',
      );

      final copy = moment.copyWith(headline: '5連勝達成！');

      expect(copy.headline, '5連勝達成！');
      expect(copy.appName, moment.appName);
      expect(copy.hashtag, moment.hashtag);
    });
  });
}
