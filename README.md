# komovia_core

将棋（komovia_shogi）・囲碁（komovia_go）・チェス（komovia_chess）が共有する、ゲーム非依存の基盤パッケージ。盤・ルール・AI・棋譜・盤描画のインターフェース（`Game`/`Engine`/`BoardRenderer`/`GameRecord`/`Puzzle`/`HandicapRule`）と、各ゲームパッケージが自分のテストで実行する契約テストキット（`package:komovia_core/testkit.dart`）を提供する。

依存の向き: アプリ → ゲーム（komovia_shogi 等） → **komovia_core** → 共通キット。本パッケージはどのゲームの型も、Flutter SDKも知らない（純Dartパッケージ）。

## 現在の段階

段階1（インターフェース定義・契約テストの骨子、2026-10-06完了）・段階2（kouki-shogi→komovia_shogi移植、2026-10-07完了）を経て、現在は段階3以降相当の共通化が並行して進んでいる状態。`lib/src/` の各インターフェースは設計書（Komovia_共通基盤設計_v0.8 §6のステージ定義）と、効棋（`zka32101/kouki-shogi`）の実コード調査に基づく。

契約テストキット（`runGameContractTests`）は `test/fixtures/tictactoe/` の最小実装だけでなく、komovia_shogi/komovia_go/komovia_chess 3つの実ゲームの `Game` 実装に対しても各リポジトリ側のテストから実行され、パスしている（tictactoeは段階1当初の実現可能性検証用フィクスチャとして残しているのみで、現時点ではそれ以上の役割はない）。

`AppNotification`/`Friendship`/`DirectMessage`・`MessageThread`/`LeaderboardEntry`/`Tournament`/`ShareableMoment`/`Entitlement` は、設計書が想定する段階3（サービス共通化）相当の内容だが、3アプリとも実際の運用コードから既に利用されている（`Entitlement` はkomovia_go/komovia_chessが各々の購入フロー発の既存フィールドを変換して利用、komovia_shogiは課金機能自体が未実装のため対象外）。`PromotedApp` は現時点ではkomovia_chessのみが利用。

## 開発

```
dart pub get
dart analyze
dart test
```

## 参考

- Komovia_共通基盤設計_v0.8（Google Drive）
- Komovia_リリース計画_v0.4（ゲート方式の段階定義）
- `zka32101/kouki-shogi`（効棋。将棋固有ロジックの移行元）
