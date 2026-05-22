# Contributing

このテンプレートは、実務レビューで使いやすくすることを優先します。

## 変更方針

- 進捗報告ではなく、意思決定、リスク、TODOに効く変更を優先する
- 枝を増やす場合は、会議中に本当に埋められるかを確認する
- XMindだけでなく、MarkdownやCSVでも意味が通る構造にする
- 交換フォーマットの互換性を壊さない

## 変更後に実行すること

```powershell
./tools/make-project-review-public-template.ps1
./tools/export-template-formats.ps1
./scripts/test-local.ps1
```

`exports/` は生成済み配布物なので、テンプレートや変換ロジックを変えた場合は必ず再生成してください。
