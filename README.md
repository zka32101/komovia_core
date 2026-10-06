# komovia_core

将棋（komovia_shogi）・囲碁（komovia_go）・チェス（komovia_chess）が共有する、ゲーム非依存の基盤パッケージ。盤・ルール・AI・棋譜・盤描画のインターフェース（`Game`/`Engine`/`BoardRenderer`/`GameRecord`/`Puzzle`/`HandicapRule`）と、各ゲームパッケージが自分のテストで実行する契約テストキット（`package:komovia_core/testkit.dart`）を提供する。

依存の向き: アプリ → ゲーム（komovia_shogi 等） → **komovia_core** → 共通キット。本パッケージはどのゲームの型も、Flutter SDKも知らない（純Dartパッケージ）。

## 現在の段階

段階1（インターフェース定義・契約テストの骨子）。`lib/src/` の各インターフェースは設計書（Komovia_共通基盤設計_v0_3 §3-1）と、効棋（`zka32101/kouki-shogi`）の実コード調査に基づく。`test/fixtures/tictactoe/` は三並べによる最小実装で、インターフェースが実際に実装可能であることと契約テストキットの動作を検証するためのフィクスチャ（Komoviaの対象ゲームではない）。

## 開発

```
dart pub get
dart analyze
dart test
```

## 参考

- Komovia_共通基盤設計_v0_3（Google Drive）
- Komovia_リリース計画_v0_2（ゲート方式の段階定義）
- `zka32101/kouki-shogi`（効棋。将棋固有ロジックの移行元）
