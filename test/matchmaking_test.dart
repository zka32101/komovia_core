import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  group('findBestMatchCandidate', () {
    test('returns the candidate with the closest rating within range', () {
      final result = findBestMatchCandidate(
        selfUid: 'me',
        selfRating: 1200,
        candidates: const [
          MatchCandidate(uid: 'a', rating: 1350),
          MatchCandidate(uid: 'b', rating: 1210),
          MatchCandidate(uid: 'c', rating: 1600),
        ],
      );
      expect(result?.uid, 'b');
    });

    test('excludes the self uid even if it appears in the candidate list', () {
      final result = findBestMatchCandidate(
        selfUid: 'me',
        selfRating: 1200,
        candidates: const [
          MatchCandidate(uid: 'me', rating: 1200),
          MatchCandidate(uid: 'a', rating: 1250),
        ],
      );
      expect(result?.uid, 'a');
    });

    test('returns null when no candidate is within maxRatingDiff', () {
      final result = findBestMatchCandidate(
        selfUid: 'me',
        selfRating: 1200,
        candidates: const [MatchCandidate(uid: 'a', rating: 1500)],
      );
      expect(result, isNull);
    });

    test('returns null for an empty candidate list', () {
      final result = findBestMatchCandidate(
        selfUid: 'me',
        selfRating: 1200,
        candidates: const [],
      );
      expect(result, isNull);
    });

    test('respects a custom maxRatingDiff', () {
      final result = findBestMatchCandidate(
        selfUid: 'me',
        selfRating: 1200,
        candidates: const [MatchCandidate(uid: 'a', rating: 1250)],
        maxRatingDiff: 30,
      );
      expect(result, isNull);
    });

    test('a tie on diff keeps the first-seen candidate', () {
      final result = findBestMatchCandidate(
        selfUid: 'me',
        selfRating: 1200,
        candidates: const [
          MatchCandidate(uid: 'a', rating: 1210),
          MatchCandidate(uid: 'b', rating: 1190),
        ],
      );
      expect(result?.uid, 'a');
    });
  });
}
