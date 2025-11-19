# 収益化要件定義書（v1.0）

## 1. 目的
本ドキュメントは、インディー音楽発見・物語共有アプリにおける収益化仕様を定義し、  
**アプリ審査適合性・アーティストへの高還元性・開発実装容易性** の3要件を同時に満たすための要件書を提供する。

本アプリは以下の2軸で収益化を行う：

1. **アーティスト月額サブスクリプション（応援モデル）**
2. **作品（トラック／物語）に対する単発投げ銭（Thanksモデル）**

課金処理は **アプリ外（Web）＋ Stripe 決済** に統一し、  
アプリ内課金（IAP）は使用しない。

---

## 2. 収益化モデルの全体構造

### 2.1 二層構造（アプリ → Web決済）
- アプリ内では「応援する」「Thanks」などの **メタ情報としてのボタンのみ** を表示する。
- ボタン押下 → **Web のアーティストページ / 作品ページ** へ遷移。
- Web側で Stripe Checkout／Payment Element を通じて **安全な課金処理** を行う。

### 2.2 課金方式
- サブスク：Stripe Subscriptions（月額）
- 投げ銭：Stripe Checkout（1回購入）
- アプリ内では金額・課金処理 UI を表示しない（規約準拠）

### 2.3 アーティスト還元率
- Stripe手数料：3.6%（国内カード）
- プラットフォームフィー：10%（Stripe Application Fee）
- アーティスト取り分：約 **86.4%**

---

## 3. 収益化要件（機能要件）

### 3.1 アーティスト応援（月額サブスク）
#### 要件
1. アプリ内「アーティストを応援する」ボタンを設置。
2. タップすると Web のアーティストページへ遷移。
3. Webページに以下を表示：
   - アーティストプロフィール
   - 作品リスト
   - サブスク特典（文章）
   - **サブスク購入ボタン（Stripe Subscriptions）**
4. 購入後、Stripe Webhook → API → DB に購読情報を保存。
5. サブスク状態はアプリ内で参照可能（認証ユーザーに紐づく）。

#### 保存データ
| フィールド | 説明 |
|-----------|------|
| stripe_customer_id | Stripeの顧客ID |
| subscription_id | サブスク契約ID |
| subscription_status | active / canceled / incomplete 等 |
| current_period_end | 次回更新日 |

---

### 3.2 作品への投げ銭（Thanks）
#### 要件
1. トラック詳細画面に「Thanks（作品にありがとう）」ボタンを設置。
2. タップすると Web の作品ページへ遷移。
3. Webページで以下を表示：
   - カバー画像
   - トラック／物語の概要
   - **投げ銭ボタン（¥100 / ¥300 / ¥500 の3段階）**
4. 購入後、Stripe Webhook → API → DB に投げ銭履歴を保存。

#### 保存データ
| フィールド | 説明 |
|-----------|------|
| user_id | 投げ銭したユーザー |
| track_id | 対象トラック |
| amount | 金額 |
| payment_intent_id | Stripe支払ID |
| created_at | 日付 |

---

## 4. 収益化API仕様（バックエンド）

### 4.1 Stripe Webhook エンドポイント
```
POST /webhooks/stripe
```

#### 処理内容
- event.type により処理を分岐：
  - `checkout.session.completed`（投げ銭）
  - `customer.subscription.created`（サブスク開始）
  - `customer.subscription.updated`（更新）
  - `customer.subscription.deleted`（解約）
- データベースへ購読/投げ銭情報を書き込み

### 4.2 アプリ側参照用 API
| 目的 | エンドポイント | 内容 |
|------|----------------|-------|
| サブスク状態取得 | `GET /me/subscription` | active / canceled |
| アーティストサブスク一覧 | `GET /artists/{id}/supporters` | サポーター人数 |
| 投げ銭履歴 | `GET /tracks/{id}/thanks` | 投げ銭者一覧（集計のみ） |

---

## 5. Webフロント仕様（Next.js/Vue等）

### 5.1 アーティストページ
- URL: `/artists/{artist_id}`
- 表示要素：
  - カバー写真
  - プロフィール
  - アーティスト説明
  - 作品リスト（最新順）
  - サブスク特典
  - **CTA: [ 月額サポートする ]**
- Stripe Subscription 課金ボタンを設置

### 5.2 作品（トラック）ページ
- URL: `/tracks/{track_id}`
- 表示要素：
  - カバー画像
  - タイトル / 作者名
  - 物語（冒頭のみ）
  - **CTA: [ Thanks を送る（200円から） ]**
- Stripe Checkout（1回購入）を呼び出す

---

## 6. アプリ側UI仕様（ネイティブ）

### 6.1 トラック詳細画面
- プレイヤーUI下部に以下アクションを配置：
  ```
  ❤️ Like     📤 Share     🙏 Thanks
  ```
- Thanks押下 → ブラウザ起動 → `/tracks/{id}`

### 6.2 アーティストプロフィール画面
- ヘッダー直下に大きめのCTA：
  ```
  🎧 アーティストを応援する
  ```
- 押下 → `/artists/{id}`へ遷移

### 6.3 注意（審査適合）
- アプリ内には **決済金額・課金UI・購入可能表現** を表示しない
- あくまで “応援ページのリンク” として扱う

---

## 7. データモデル拡張要件

### 7.1 user テーブルの拡張
| カラム | 型 | 説明 |
|--------|----|------|
| stripe_customer_id | text | Stripe顧客ID（nullable） |

### 7.2 subscriptions テーブル
| カラム | 型 |
|--------|----|
| id | pk |
| user_id | fk |
| artist_id | fk |
| stripe_subscription_id | text |
| status | text |
| current_period_end | timestamp |

### 7.3 thanks テーブル
| カラム | 型 |
|--------|----|
| id | pk |
| user_id | fk |
| track_id | fk |
| amount | int |
| payment_intent_id | text |
| created_at | timestamp |

---

## 8. 分配ロジック

### 8.1 サブスク
```
売上 = Stripe金額（例 ¥500）
Stripe手数料 = 3.6%
プラットフォームフィー = 10%
アーティスト取り分 = 売上 × (1 - 0.036 - 0.10)
```
→ 約 **86.4%** がアーティストへ

### 8.2 投げ銭
```
売上 = Stripe金額（例 ¥300）
Stripe手数料 3.6%
プラットフォームフィー 10%
```
→ アーティスト取り分は同様

---

## 9. KPI

### 9.1 サブスク系
- アーティスト別サポーター数
- アーティスト別月次MRR
- 継続率（1・3・6・12ヶ月）

### 9.2 投げ銭系
- 曲別の投げ銭件数 / 金額
- 1ユーザー当たりの投げ銭回数
- 投げ銭のタイミング（再生直後など）

### 9.3 全体
- MAU / DAU
- 再生→Thanks への遷移率
- プロフィール閲覧 → 応援ボタン押下率

---

## 10. セキュリティ要件

1. Stripe Webhookは署名検証を必須とする
2. JWTに課金状態を含めず、毎回API参照で状態を取得
3. DBへの金額値はサーバ側で確定させ、クライアントから金額を受け取らない
4. Webhook処理は冪等性を保証する（payment_intent_id で重複排除）

---

## 11. 非機能要件

### パフォーマンス
- 課金ページのLCP 2.5s以内
- Webhook処理は300ms以内でレスポンス返却（処理は非同期可）

### 可用性
- 決済関連APIのSLO：99.9%

### 拡張性
- 将来的に「月額200円・500円・1000円」のプラン増設に耐える
- 投げ銭金額の可変化（アーティスト自身が設定）に対応可能な構造にする

---

## 12. リスクと回避策

| リスク | 回避策 |
|--------|--------|
| Stripe障害時に決済できない | メンテナンス表示＋後日再試行 |
| Webhook重複送信 | payment_intent_id のユニーク制約 |
| 不正な金額リクエスト | 金額はサーバ側が固定値で管理 |
| ブラウザ遷移離脱率が高い | スマホ最適化（1画面1 CTA） |

---

## 13. リリース条件

- サブスク／投げ銭の Stripe 実装が完了
- Webhook が全イベントに対して冪等動作する
- アプリ側の外部遷移が審査落ちしない構造（課金表現無し）
- KPI ダッシュボード（PostHog または Metabase）で計測できる状態

---

## 14. 今後の拡張（Optional）

### 14.1 アーティスト側の収益ダッシュボード
- 月次MRR表示
- 投げ銭の時系列グラフ
- サブスク推移

### 14.2 ファンクラブ機能
- サブスク特典：限定物語、限定トラック、限定メッセージ
- ロール名称：Supporter / Gold / Platinum

### 14.3 ギフト送付
- 物語に「ギフト」を添える（イラスト、メッセージ等）

---

# 付録A：参考遷移図

```
アプリ（Profile）
   ↓ 応援する
Web（Artist Page）
   ↓ サブスク
Stripe Checkout
   ↓
Webhook → API → DB
   ↓
アプリに購読状態反映
```

```
アプリ（Track Detail）
   ↓ Thanks
Web（Track Page）
   ↓ 投げ銭
Stripe Checkout
   ↓
Webhook → DB
```

---

# 付録B：想定URL

```
/artists/{id}
/tracks/{id}
/support/checkout
/support/webhook
```

---

# 付録C：Stripe連携に必要なSecrets

```
STRIPE_SECRET_KEY
STRIPE_WEBHOOK_SECRET
STRIPE_PRICE_SUBSCRIPTION
STRIPE_PRICE_TIP_100
STRIPE_PRICE_TIP_300
STRIPE_PRICE_TIP_500
```

---

以上が、アプリとWeb、Stripe、審査、収益分配をすべて包含した **完全版の収益化要件定義書** である。
