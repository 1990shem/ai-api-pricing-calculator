# AI API Pricing Calculator

AI API料金比較と月額費用計算機の静的サイトMVPです。

## 目的

開発者や事業担当者が、主要AI APIの月額コストを短時間で比較できるようにします。

## 構成

- `index.html`: 画面本体
- `styles.css`: スタイル
- `app.js`: 計算ロジック
- `data/pricing.json`: 価格データ
- `docs/operations.md`: 運用メモ
- `docs/quality-check.md`: 品質チェック工程
- `scripts/quality-check.ps1`: 自動品質チェック

## 品質チェック

公開前に必ず以下を実行します。

```powershell
.\scripts\quality-check.ps1
```

その後、ブラウザで文字化け、モバイル表示、横スクロール、計算結果、公式リンクを確認します。

## ローカル確認

静的ファイルですが、`fetch("./data/pricing.json")` を使うためローカルサーバで確認します。

```powershell
E:\Codex\tools\node-v24.15.0-win-x64\node.exe .\scripts\static-server.mjs
```

その後、ブラウザで `http://localhost:4173` を開きます。

このワークスペースでは、Node.js LTSを以下にポータブル配置しています。

```text
E:\Codex\tools\node-v24.15.0-win-x64
```

## 公開方針

初期公開は Cloudflare Pages です。

本番URL:

```text
https://ai-api-pricing-calculator.pages.dev/
```

1. GitHubにリポジトリを作成
2. Cloudflare PagesでGitHubリポジトリを接続
3. Build commandは空
4. Output directoryは `/`
5. 独自ドメインを接続

## 注意

価格データは公式価格ページをもとに更新します。実際の請求額は、契約条件、無料枠、地域、税、為替、ツール利用料で変わる可能性があります。
