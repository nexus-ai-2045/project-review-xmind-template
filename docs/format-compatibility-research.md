# マインドマップ形式互換性リサーチ

調査日: 2026-05-22

## 結論

マインドマップには、すべての主要ツールが完全互換する単一の標準ファイル形式はありません。

そのため、このリポジトリでは以下を「実用上のデファクト互換セット」として扱います。

- `.xmind`: XMind利用者向けの一次成果物
- `.opml`: アウトライナー / マインドマップ間の交換形式
- `.mm`: FreeMind / Freeplane系の交換形式
- `.md`: Markdown / Markmap / GitHubで読めるテキスト版
- `.mmd`: Mermaid mindmap
- `.json`: 自動処理・変換用の構造化データ
- `.csv` / `.tsv`: 表計算・台帳化

## 根拠

### XMind

XMind公式ドキュメントでは、エクスポート形式としてPNG、SVG、PDF、Excel、Word、OPML、TextBundle、PowerPoint、Markdownなどが挙げられています。
また、インポート形式としてMindMaster、MindManager、FreeMind、MindNode、Word、Markdown、OPML、TextBundleなどが挙げられています。

このため、XMind本体に加えてOPML、Markdown系を持つことは妥当です。

出典:
- https://xmind.com/user-guide/export-new
- https://xmind.com/user-guide/import-new

### MindNode

MindNode公式ドキュメントでは、インポート形式としてMarkdown、TextBundle、FreeMind、iThoughts、OPML、Xmindなどが挙げられています。
エクスポート形式としてPDF、SVG、FreeMind、OPML、Image、Markdown、Textなどが挙げられています。

このため、`.opml`、`.mm`、`.md` はMindNodeとの移行にも効きます。

出典:
- https://www.mindnode.com/support/guides/import-and-export

### MindMeister

MindMeister公式ヘルプでは、MindMeister、MindManager、XMind、FreeMind形式のインポートに言及しています。
有料ユーザーのエクスポートではPDF、Image、FreeMind、XMind、MindManager、Word、PowerPoint、Zip Presentationsが挙げられています。

このため、XMind形式とFreeMind系 `.mm` を押さえる価値があります。

出典:
- https://support.mindmeister.com/hc/en-us/articles/8031990936466-Can-I-Import-Export-My-Mind-Maps

### Freeplane / FreeMind

Freeplane公式ドキュメントでは、Freeplane 1.0/1.1がFreeMindの形式と拡張子 `.mm` を使っていたことが説明されています。
FreeMind / Freeplane系との互換を考えるなら `.mm` は重要です。

出典:
- https://docs.freeplane.org/attic/old-mediawiki-content/New_Freeplane_File_Format_%28Proposal%29.html

### OPML

OPML 2.0仕様は、XML 1.0でoutlineを保存する形式として説明されています。
アウトライナーやマインドマップ間の構造交換に向いています。

出典:
- https://2005.opml.org/spec2.html

### Mermaid / Markmap

Mermaid公式ドキュメントにはmindmap構文がありますが、mindmapは実験的な位置づけで、構文や読み込み方式が変わる可能性にも触れられています。
MarkmapはMarkdownから階層構造を取り出してインタラクティブなmindmapとして描画するツールです。

このため、Mermaid `.mmd` はドキュメント埋め込み用、Markdown `.md` はMarkmapやGitHub可読性向けとして扱います。
Mermaid mindmapは実験的な位置づけのため、このリポジトリの `.mmd` はbest effortの交換形式です。
厳密な視覚確認が必要な場合は、Mermaid Live Editorや利用先のレンダラーで確認してください。

出典:
- https://mermaid.js.org/syntax/mindmap.html
- https://markmap.js.org/docs/markmap

## 対応しない/自動生成しないもの

### MindManager `.mmap`

MindManager形式は主要互換対象ですが、ネイティブ `.mmap` を正しく生成するには仕様・互換性検証が不足します。
現時点では、XMindやMindMeisterなどのアプリ側インポート/エクスポート経由で扱う方針です。

### MindMeister `.mind`

MindMeisterネイティブ形式は、公式ヘルプ上でエクスポート形式として言及されていますが、汎用交換形式として直接生成する根拠が不足します。

### MindNodeネイティブ形式

MindNodeには独自形式がありますが、MindNode公式がOPML、FreeMind、Markdown、XMindのインポート/エクスポートを提供しているため、交換用途ではそれらを優先します。

### PDF / PNG / SVG

見た目固定の配布形式として重要ですが、XMindや他GUIレンダラーの描画に依存します。
CIで安定生成する対象ではなく、リリース時に手動またはGUI自動化で生成する追加成果物として扱います。

## 推奨配布セット

通常配布:

- `templates/project-review-public-template.xmind`
- `exports/project-review-public-template.opml`
- `exports/project-review-public-template.mm`
- `exports/project-review-public-template.md`
- `exports/project-review-public-template.mmd`
- `exports/project-review-public-template.json`
- `exports/project-review-public-template.csv`
- `exports/project-review-public-template.tsv`

リリース時に追加検討:

- PDF
- PNG
- SVG
