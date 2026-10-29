/// 実力マッチングの候補選定アルゴリズムの、ゲーム非依存な中核部分。
///
/// komovia_core は Flutter/Firebase 非依存の素のDartパッケージ
/// （`app_notification.dart`/`entitlement.dart`参照）のため、Firestore
/// 待機列の読み書き・トランザクションそのものは各アプリの
/// `MatchingService`に残す。ここでは、go/shogi/reversiaで一字一句
/// 重複していた「待機中の候補からレート差が最も近い相手を選ぶ」
/// 純粋なロジックだけを抽出する。

/// マッチングアルゴリズムが必要とする候補の最小データ。
class MatchCandidate {
  final String uid;
  final int rating;

  const MatchCandidate({required this.uid, required this.rating});
}

/// 既定の許容レート差（この範囲内なら「マッチ」とみなす）。
const defaultMaxMatchmakingRatingDiff = 200;

/// [candidates]の中から、[selfUid]以外で[selfRating]とのレート差が
/// [maxRatingDiff]以内かつ最も近い候補を返す。該当がなければnull。
MatchCandidate? findBestMatchCandidate({
  required String selfUid,
  required int selfRating,
  required Iterable<MatchCandidate> candidates,
  int maxRatingDiff = defaultMaxMatchmakingRatingDiff,
}) {
  MatchCandidate? best;
  var bestDiff = 1 << 30;

  for (final candidate in candidates) {
    if (candidate.uid == selfUid) continue;
    final diff = (candidate.rating - selfRating).abs();
    if (diff <= maxRatingDiff && diff < bestDiff) {
      best = candidate;
      bestDiff = diff;
    }
  }

  return best;
}
