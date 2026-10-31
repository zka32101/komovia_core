/// A single SNS-shareable highlight from a finished game or solved
/// puzzle, shared by every Komovia app (shogi/go/chess, and future
/// siblings) so each one's "SNSでシェア" button produces the same
/// consistent caption shape instead of each app inventing its own
/// format and emoji conventions independently.
///
/// Deliberately a plain Dart data class, same as [PromotedApp] — no
/// Flutter/Firebase dependency, so komovia_core stays usable from a
/// pure-Dart test and doesn't need a widget tree to build a caption.
/// Rendering an actual share-card *image* (if an app wants one, not
/// just text) is each app's own concern, since that needs each app's
/// own theme/board-painting code; this only covers the text caption
/// that `share_plus`'s `Share.share`/`shareWithResult` sends.
class ShareableMoment {
  /// Display name of the app sharing this moment, e.g. `'Komovia将棋'`.
  final String appName;

  /// The headline of the moment, e.g. `'勝利！'`, `'5連勝達成！'`,
  /// `'詰め将棋クリア！'`. Kept short — this is the first line of the
  /// caption and often the only part visible before a "see more" fold
  /// on most SNS clients.
  final String headline;

  /// Supporting detail lines shown under the headline, e.g.
  /// `['対戦相手: AI Lv.8', '手数: 42手', '対局時間: 12分']`. Each
  /// app decides what's worth bragging about for its own game.
  final List<String> statLines;

  /// Hashtag(s) to append, e.g. `'#Komovia将棋'`. Optional — a moment
  /// with nothing distinguishing to tag (e.g. a plain daily puzzle)
  /// can omit it.
  final String? hashtag;

  const ShareableMoment({
    required this.appName,
    required this.headline,
    this.statLines = const [],
    this.hashtag,
  });

  ShareableMoment copyWith({
    String? appName,
    String? headline,
    List<String>? statLines,
    Object? hashtag = _unset,
  }) {
    return ShareableMoment(
      appName: appName ?? this.appName,
      headline: headline ?? this.headline,
      statLines: statLines ?? this.statLines,
      hashtag: hashtag == _unset ? this.hashtag : hashtag as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ShareableMoment &&
      other.appName == appName &&
      other.headline == headline &&
      _listEquals(other.statLines, statLines) &&
      other.hashtag == hashtag;

  @override
  int get hashCode =>
      Object.hash(appName, headline, Object.hashAll(statLines), hashtag);

  @override
  String toString() =>
      'ShareableMoment($appName, $headline, $statLines, $hashtag)';
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Builds the SNS share caption for [moment] in a consistent shape
/// across every Komovia app:
///
/// ```
/// <headline>
///
/// <statLine1>
/// <statLine2>
/// ...
///
/// <appName> <hashtag>
/// <storeUrl>
/// ```
///
/// [storeUrl] is optional (an app may not have a published store
/// listing yet, or may prefer to omit the link for a given share
/// surface) and, when passed, is appended as its own trailing line
/// so SNS clients that auto-link URLs can do so cleanly.
String buildShareCaption(ShareableMoment moment, {String? storeUrl}) {
  final lines = <String>[moment.headline];

  if (moment.statLines.isNotEmpty) {
    lines.add('');
    lines.addAll(moment.statLines);
  }

  lines.add('');
  lines.add(
    moment.hashtag == null
        ? moment.appName
        : '${moment.appName} ${moment.hashtag}',
  );

  if (storeUrl != null && storeUrl.isNotEmpty) {
    lines.add(storeUrl);
  }

  return lines.join('\n');
}

/// Sentinel used by [ShareableMoment.copyWith] to distinguish "not
/// passed" from an explicit `null`, so the nullable [ShareableMoment.hashtag]
/// field can actually be cleared.
const Object _unset = Object();
