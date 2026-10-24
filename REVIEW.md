# レビューガイド

このリポジトリは、プロジェクトレビュー用マインドマップテンプレートを複数フォーマットで配布するためのものです。

## レビュー対象

- XMindテンプレート本体
  - `templates/project-review-public-template.xmind`
- 交換フォーマット
  - `exports/project-review-public-template.opml`
  - `exports/project-review-public-template.mm`
  - `exports/project-review-public-template.md`
  - `exports/project-review-public-template.mmd`
  - `exports/project-review-public-template.json`
  - `exports/project-review-public-template.csv`
  - `exports/project-review-public-template.tsv`
- 生成・検証スクリプト
  - `tools/make-project-review-public-template.ps1`
  - `tools/export-template-formats.ps1`
  - `scripts/validate-template.ps1`
  - `scripts/test-local.ps1`
- 互換性調査メモ
  - `docs/format-compatibility-research.md`

## まず見る場所

1. `README.md`
   - 配布物として説明が伝わるか
   - 対応フォーマットの説明が過不足ないか
2. `docs/quick-start.md`
   - 初見ユーザーが5分で試せるか
   - 会議中に何を埋めるべきかが伝わるか
3. `examples/sample-project-review.md`
   - 記入例として実務イメージが湧くか
   - 過度に特定業界へ寄りすぎていないか
4. `templates/project-review-public-template.xmind`
   - XMindで開いたときにレビュー運用に耐える構成か
   - シート名、枝、TODO、リスク、意思決定ログが自然か
5. `exports/project-review-public-template.md`
   - XMindなしでも構造が読めるか
6. `docs/format-compatibility-research.md`
   - デファクト互換の説明として納得できるか

## ローカル検証

```powershell
./scripts/test-local.ps1
```

この検証で確認すること:

- チェックイン済み `.xmind` がXMindパッケージとして成立している
- 生成スクリプトから `.xmind` を再生成できる
- 交換フォーマットを生成できる
- repo内 `exports/` が再生成結果と一致している
- Markdownリンクが切れていない
- 公開対象ファイルにローカル絶対パスが混入していない

## レビュー観点

### テンプレート内容

- 実務レビューで最初に埋めるべき項目が明確か
- 「進捗報告」ではなく「判断・リスク・次アクション」に寄っているか
- TODOに担当、期限、完了条件、証跡が入る設計になっているか
- リスクが影響、確率、対応策、オーナー、期限で管理できるか
- 関係者/RACIが過剰でも不足でもないか

### フォーマット互換

- `.xmind` を一次成果物にする方針でよいか
- `.opml` / `.mm` / `.md` / `.mmd` / `.json` / `.csv` / `.tsv` の配布セットで十分か
- PDF、PNG、SVGをリリース時の手動生成に回す方針でよいか
- Mermaid `.mmd` をbest effort扱いにしている説明が妥当か

### 公開品質

- READMEだけで用途と使い方が伝わるか
- プレビュー画像とサンプルで利用イメージが湧くか
- privateからpublicにしてもローカル情報や機密情報がないか
- GitHub Actionsの検証範囲が公開前チェックとして十分か
- 生成物とチェックイン済み成果物のズレが検知できるか

## 現在の状態

- Repository visibility: private
- Default branch: `main`
- 最新の成功CI: `Validate XMind template`
- 最新コミットは `git log --oneline -1` で確認する

## 既知の割り切り

- MindManager `.mmap` やMindMeisterネイティブ形式は直接生成しない
- PDF、PNG、SVGはGUIレンダラー依存のためCIでは生成しない
- Mermaid mindmapは仕様上best effortとして扱う

## 公開前の最終手順

1. `./scripts/test-local.ps1` を実行する
2. GitHub Actionsが成功していることを確認する
3. `templates/project-review-public-template.xmind` をXMindで開いて目視確認する
4. README、クイックスタート、サンプル、調査メモを確認する
5. 必要ならrelease tagを切る
6. 問題なければrepoをpublicに変更する
