# Operations

## 日次/週次でやること

1. 公式価格ページを確認
2. `data/pricing.json` を更新
3. 品質チェック工程を実行
4. ローカル表示を確認
5. 計算結果が極端にずれていないか確認
6. GitHubにpush
7. Cloudflare Pagesで公開確認

## 品質チェック工程

公開前に必ず以下を実行する。

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\quality-check.ps1
```

その後、`docs/quality-check.md` の目視チェックを行う。

## 更新対象の公式ページ

- OpenAI: https://openai.com/api/pricing/
- Anthropic: https://docs.anthropic.com/en/docs/about-claude/pricing
- Gemini: https://ai.google.dev/gemini-api/docs/pricing
- Mistral: https://mistral.ai/pricing

## 自動化候補

- 公式ページの変更検出
- JSON差分の作成
- 計算テスト
- リンク切れチェック
- sitemap更新
- Cloudflare Pagesへの自動デプロイ

## 収益化メモ

- 主要APIそのものにアフィリエイトがない場合がある
- 周辺SaaS、SEO、AI Visibility、チャットボット、開発者ツールで収益化する
- アフィリエイトリンクを使う場合はページ上で明示する
- 価格比較の中立性を損なう掲載方法は避ける
