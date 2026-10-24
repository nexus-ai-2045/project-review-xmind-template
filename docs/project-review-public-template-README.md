# Project Review Public Template

配布用のプロジェクトレビューXMindテンプレートです。

## ファイル

- `project-review-public-template.xmind`

初めて使う場合は、先に [`quick-start.md`](quick-start.md) と [`../examples/sample-project-review.md`](../examples/sample-project-review.md) を確認してください。

## 対応フォーマット

このテンプレートの一次成果物はXMind形式です。
交換用フォーマットとして、以下を生成できます。

- `.xmind`: XMind用
- `.opml`: アウトライナー / 一部マインドマップツール向け
- `.mm`: FreeMind / Freeplane向け
- `.md`: Markdownアウトライン
- `.mmd`: Mermaid mindmap
- `.json`: 構造化データ
- `.csv` / `.tsv`: 表計算・台帳化向け

PDF、PNG、SVGなどの見た目固定ファイルは、XMindなどGUIレンダラー依存のため自動生成対象外です。

## 想定用途

- 週次プロジェクトレビュー
- フェーズゲートレビュー
- リスク・課題の棚卸し
- 意思決定会議
- PM/PO/リード間の状況共有

## シート構成

1. `00 使い方`
   - 進行方法、マーカー凡例、配布前チェック
2. `01 レビュー本体`
   - 結論、前提、進捗、品質、リスク、判断、次アクション
3. `02 意思決定ログ`
   - 今日決めること、保留事項、決定済みログ
4. `03 リスク台帳`
   - Critical、Watch、カテゴリ別チェック、受容済みリスク
5. `04 アクショントラッカー`
   - P1、P2、Waiting、Done
6. `05 関係者・RACI`
   - 主要関係者、RACI、コミュニケーション設計
7. `06 学び・改善`
   - Keep / Problem / Try、テンプレ改善、ナレッジ化

## 運用ルール

- レビュー本体の「エグゼクティブサマリー」を最初に更新する
- リスクは「影響・確率・対応策・オーナー・期限」で書く
- TODOは「担当・期限・完了条件・証跡」を必ず入れる
- 会議で決めたことは意思決定ログへ残す
- 次回レビュー前にAction TrackerとRisk Registerを更新する

## 配布前チェック

- 固有名詞・機密情報が残っていない
- サンプル項目を実案件向けに置き換えた
- 判断者・担当者・期限が明確
- 次回レビュー日と持参物が入っている

## 開発者向け検証

配布前に以下を実行してください。

```powershell
./scripts/test-local.ps1
```

このチェックでは、XMindファイルの展開、必須XML、シート構成、主要トピック、交換フォーマット生成、Markdownリンク、ローカル絶対パス混入を確認します。
