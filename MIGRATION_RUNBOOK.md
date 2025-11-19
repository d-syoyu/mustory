# MIGRATION_RUNBOOK.md — Flutter を本線に戻すための整理ログ

React Native への移行プランは 2025-11-18 時点で **中止** し、Flutter MVP を磨き込む方針に確定した。本ドキュメントでは、過去の RN 移行タスクをどのようにアーカイブし、Flutter へ集中するかのワークフローを残す。

---

## 1. 決定事項のサマリ
- RN クライアント（apps/mobile-rn 以下）と RN ドキュメント群（`RN_*`）は削除済み。
- Flutter クライアント（apps/mobile）を唯一のモバイルアプリとみなす。
- API / Worker / Infra の構成変更は不要。Flutter から既存 API を直接利用する。

---

## 2. 影響を受けた領域
| 領域 | 対応 | 備考 |
|------|------|------|
| モバイルクライアント | Flutter のみを維持 | `README.md` と `AGENTS.md` を Flutter 前提に更新 |
| ドキュメント | RN 系を削除 / Flutter 系を充実 | `BACKGROUND_AUDIO_IMPLEMENTATION.md`, `UPLOAD_IMPLEMENTATION_PROGRESS.md` などは現役 |
| CI / スクリプト | RN 用 Workflow を削除予定 | Flutter CI への一本化を随時進める |

---

## 3. Flutter 集中のチェックリスト
1. **リポジトリ衛生**
   - [x] RN ディレクトリ削除
   - [x] RN ドキュメント削除
   - [ ] CI から RN ワークフローを除去
2. **ドキュメント更新**
   - [x] README を Flutter 中心に更新
   - [x] AGENTS を Flutter 基準へ書き換え
   - [ ] Flutter 関連ドキュメントの抜け漏れ整理（例：アセット命名規則）
3. **ナレッジ移管**
   - [ ] RN で得られた学び（Audio, Upload など）を Flutter 向けドキュメントに転記
   - [ ] Flutter テスト戦略の追記（Widget / Integration / Golden）

---

## 4. 今後の運用ルール
- Flutter を前提に要件を定義し、React Native への派生要望が出た場合は別ブランチで検証する。
- 新規ドキュメントには「Flutter」が明記されているかをレビュー項目に入れる。
- 何らかの理由で RN を再検討する際は、本ドキュメントを更新してから実装着手すること。

---

## 5. 参考
- `REQUIREMENTS.md`（Flutter v0.6 UI 仕様）
- `AGENTS.md`（Flutter 実装ガイド）
- `BACKGROUND_AUDIO_IMPLEMENTATION.md` / `UPLOAD_IMPLEMENTATION_PROGRESS.md`

Flutter へ集中することで、トラック投稿〜物語閲覧のコア体験に再投資する。今後この Runbook は「脱線しないための見張り役」として、Flutter 前提から逸れそうな変更が入る際に更新する。
