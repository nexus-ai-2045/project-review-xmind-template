[CmdletBinding()]
param(
  [string]$OutputDir,
  [switch]$KeepExpanded
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$baseDir = if ($OutputDir) { $OutputDir } else { Join-Path $repoRoot "templates" }
$outDir = Join-Path $env:TEMP ("project-review-public-template-xmind-" + [guid]::NewGuid().ToString("N"))
$outFile = Join-Path $baseDir "project-review-public-template.xmind"
$timestamp = "1779303600000"

if (-not (Test-Path -LiteralPath $baseDir)) {
  New-Item -ItemType Directory -Path $baseDir | Out-Null
}
New-Item -ItemType Directory -Path $outDir | Out-Null
New-Item -ItemType Directory -Path (Join-Path $outDir "META-INF") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $outDir "Thumbnails") | Out-Null

function Escape-XmlText {
  param([string]$Text)
  if ($null -eq $Text) {
    return ""
  }
  return [System.Security.SecurityElement]::Escape($Text)
}

function Topic {
  param(
    [string]$Id,
    [string]$Title,
    [string]$Marker = "",
    [string[]]$Labels = @(),
    [string]$Notes = "",
    [string]$Children = ""
  )

  $markerXml = ""
  if ($Marker) {
    $markerXml = "<marker-refs><marker-ref marker-id=""$Marker""/></marker-refs>"
  }

  $labelXml = ""
  if ($Labels.Count -gt 0) {
    $labelXml = "<labels>" + (($Labels | ForEach-Object { "<label>$(Escape-XmlText $_)</label>" }) -join "") + "</labels>"
  }

  $notesXml = ""
  if ($Notes) {
    $notesXml = "<notes><plain>$(Escape-XmlText $Notes)</plain></notes>"
  }

  $childrenXml = ""
  if ($Children) {
    $childrenXml = "<children><topics type=""attached"">$Children</topics></children>"
  }

  return "<topic id=""$Id"" modified-by=""Codex"" timestamp=""$timestamp""><title>$(Escape-XmlText $Title)</title>$markerXml$labelXml$notesXml$childrenXml</topic>"
}

function Sheet {
  param(
    [string]$Id,
    [string]$RootId,
    [string]$Title,
    [string]$RootTitle,
    [string]$Structure,
    [string]$Notes,
    [string]$Children
  )

  return @"
  <sheet id="$Id" modified-by="Codex" timestamp="$timestamp">
    <topic id="$RootId" modified-by="Codex" structure-class="$Structure" timestamp="$timestamp">
      <title>$(Escape-XmlText $RootTitle)</title>
      <notes><plain>$(Escape-XmlText $Notes)</plain></notes>
      <children><topics type="attached">$Children</topics></children>
    </topic>
    <title>$(Escape-XmlText $Title)</title>
  </sheet>
"@
}

$readmeChildren = @(
  Topic "readme-purpose" "このテンプレートの目的" "star-red" @("最初に読む") "進捗報告ではなく、意思決定・リスク低減・次アクション確定のためのプロジェクトレビューを標準化する。"
  Topic "readme-when" "使うタイミング" "" @() "" (@(
    Topic "readme-when-weekly" "週次レビュー: 進捗・リスク・TODOを更新"
    Topic "readme-when-gate" "フェーズゲート: 継続 / 変更 / 停止を判断"
    Topic "readme-when-trouble" "炎上予防: 兆候・依存・未決事項を洗い出す"
  ) -join "")
  Topic "readme-flow" "おすすめ進行 45分" "month-may" @() "" (@(
    Topic "readme-flow-1" "5分: 結論サマリーと今日の論点"
    Topic "readme-flow-2" "10分: 進捗・成果物・品質"
    Topic "readme-flow-3" "15分: 課題・リスク・依存関係"
    Topic "readme-flow-4" "10分: 意思決定"
    Topic "readme-flow-5" "5分: TODO・担当・期限・完了条件"
  ) -join "")
  Topic "readme-markers" "マーカー凡例" "symbol-info" @() "" (@(
    Topic "readme-marker-red" "赤旗: 今すぐ扱うリスク / ブロッカー" "flag-red"
    Topic "readme-marker-orange" "橙旗: 注意が必要な遅延・依存" "flag-orange"
    Topic "readme-marker-p1" "P1: 今日決める / 最優先" "priority-1"
    Topic "readme-marker-p2" "P2: 次回までに確認" "priority-2"
    Topic "readme-marker-done" "完了: 証跡確認済み" "task-done"
    Topic "readme-marker-half" "進行中: 完了条件を明記" "task-half"
  ) -join "")
  Topic "readme-quality" "配布前チェック" "task-done" @("テンプレ品質") "" (@(
    Topic "readme-quality-1" "固有名詞・機密情報が残っていない"
    Topic "readme-quality-2" "判断者・担当者・期限の欄がある"
    Topic "readme-quality-3" "リスクとTODOが別管理になっている"
    Topic "readme-quality-4" "次回レビューで更新する場所が明確"
  ) -join "")
) -join ""

$dashboardChildren = @(
  Topic "dash-summary" "00 エグゼクティブサマリー" "star-red" @("最初に埋める") "1分で読めるレビュー結論。会議後にこの枝だけ見ても状況が伝わる状態にする。" (@(
    Topic "dash-status" "総合判定: Green / Yellow / Red" "symbol-question"
    Topic "dash-headline" "一言結論: [現在の状態を一文で]"
    Topic "dash-recommendation" "推奨判断: 継続 / 変更 / 保留 / 停止" "priority-1"
    Topic "dash-main-risk" "最大リスク: [影響と期限]" "flag-red"
    Topic "dash-next-condition" "次に進める条件: [承認・検証・完了条件]"
  ) -join "")
  Topic "dash-context" "01 前提・ゴール" "" @("レビュー観点") "" (@(
    Topic "dash-purpose" "目的: なぜやるのか"
    Topic "dash-success" "成功条件: KPI / 完了定義 / 受入条件"
    Topic "dash-scope-in" "対象範囲: 今回見るもの"
    Topic "dash-scope-out" "対象外: 今回見ないもの"
    Topic "dash-constraints" "制約: 予算 / 期限 / 技術 / 契約"
  ) -join "")
  Topic "dash-progress" "02 進捗・マイルストーン" "task-half" @() "" (@(
    Topic "dash-progress-plan" "計画との差分: 予定通り / 遅れ / 前倒し"
    Topic "dash-progress-done" "完了済み: 成果物 / 証跡 / 確認者" "task-done"
    Topic "dash-progress-doing" "進行中: 担当 / 期限 / 完了条件" "task-half"
    Topic "dash-progress-delay" "遅延・停滞: 原因 / 影響 / リカバリ" "flag-orange"
    Topic "dash-progress-next" "次のマイルストーン: 日付 / 判定条件"
  ) -join "")
  Topic "dash-quality" "03 成果物・品質" "" @() "" (@(
    Topic "dash-deliverables" "成果物一覧: 版 / リンク / オーナー"
    Topic "dash-review-state" "レビュー状態: 未着手 / レビュー中 / 承認済み" "task-quarter"
    Topic "dash-quality-risks" "品質懸念: 欠陥 / 未検証 / 運用不安" "symbol-exclam"
    Topic "dash-evidence" "証跡: テスト結果 / 議事録 / 添付"
  ) -join "")
  Topic "dash-risks" "04 課題・リスク Top 5" "flag-red" @("会議の核") "詳細はリスク台帳シートで管理する。ここには意思決定に効く上位リスクだけ置く。" (@(
    Topic "dash-risk-1" "R1: [内容] 影響 / 確率 / 期限 / 対応方針" "priority-1"
    Topic "dash-risk-2" "R2: [内容] 影響 / 確率 / 期限 / 対応方針" "priority-2"
    Topic "dash-risk-3" "R3: [内容] 影響 / 確率 / 期限 / 対応方針"
    Topic "dash-blockers" "ブロッカー: 誰の判断・支援が必要か" "flag-red"
  ) -join "")
  Topic "dash-decisions" "05 今日決めること" "priority-1" @("意思決定") "" (@(
    Topic "dash-decision-1" "D1: 論点 / 選択肢 / 推奨案 / 決定者" "priority-1"
    Topic "dash-decision-2" "D2: 論点 / 選択肢 / 推奨案 / 決定者" "priority-1"
    Topic "dash-decision-log" "決定後は意思決定ログへ転記" "task-done"
  ) -join "")
  Topic "dash-actions" "06 次アクション" "task-start" @("TODO化") "" (@(
    Topic "dash-action-p1" "P1 TODO: 担当 / 期限 / 完了条件" "priority-1"
    Topic "dash-action-p2" "P2 TODO: 担当 / 期限 / 完了条件" "priority-2"
    Topic "dash-action-watch" "ウォッチ項目: 次回確認すること" "symbol-info"
    Topic "dash-next-review" "次回レビュー: 日時 / 参加者 / 持参物" "month-may"
  ) -join "")
) -join ""

$decisionChildren = @(
  Topic "decision-template" "決定カードの型" "symbol-info" @("コピーして使う") "" (@(
    Topic "decision-template-issue" "論点: 何を決めるか"
    Topic "decision-template-options" "選択肢: A / B / C"
    Topic "decision-template-recommend" "推奨案: 理由つき"
    Topic "decision-template-owner" "決定者: 名前 / 役割" "people-blue"
    Topic "decision-template-deadline" "決定期限: YYYY-MM-DD"
    Topic "decision-template-result" "決定結果: 採用案 / 条件 / 影響" "task-done"
  ) -join "")
  Topic "decision-today" "今日決める" "priority-1" @() "" (@(
    Topic "decision-today-1" "[D-001] 論点 / 推奨案 / 決定者 / 期限" "priority-1"
    Topic "decision-today-2" "[D-002] 論点 / 推奨案 / 決定者 / 期限" "priority-1"
  ) -join "")
  Topic "decision-pending" "保留・持ち帰り" "priority-2" @() "" (@(
    Topic "decision-pending-1" "[D-101] 誰が / 何を確認 / いつ戻す" "priority-2"
    Topic "decision-pending-2" "[D-102] 不足情報 / 入手先 / 期限"
  ) -join "")
  Topic "decision-done" "決定済みログ" "task-done" @() "" (@(
    Topic "decision-done-1" "[D-900] 決定内容 / 日付 / 根拠 / 影響範囲" "task-done"
  ) -join "")
) -join ""

$riskChildren = @(
  Topic "risk-scoring" "評価基準" "symbol-info" @("運用ルール") "" (@(
    Topic "risk-impact" "影響: H=事業/顧客/期限に重大, M=局所影響, L=軽微"
    Topic "risk-probability" "確率: H=起きそう, M=可能性あり, L=低い"
    Topic "risk-response" "対応: 回避 / 軽減 / 転嫁 / 受容"
  ) -join "")
  Topic "risk-critical" "Critical: 今すぐ扱う" "flag-red" @() "" (@(
    Topic "risk-critical-1" "[R-001] 内容 / 影響H / 確率H / オーナー / 期限 / 対応策" "priority-1"
    Topic "risk-critical-2" "[R-002] 内容 / 影響H / 確率M / オーナー / 期限 / 対応策" "priority-1"
  ) -join "")
  Topic "risk-watch" "Watch: 監視する" "flag-orange" @() "" (@(
    Topic "risk-watch-1" "[R-101] トリガー条件 / 監視者 / 次回確認日" "priority-2"
    Topic "risk-watch-2" "[R-102] 依存先 / 代替案 / エスカレーション条件"
  ) -join "")
  Topic "risk-categories" "カテゴリ別チェック" "" @() "" (@(
    Topic "risk-tech" "技術・仕様: 未確定仕様 / 性能 / セキュリティ"
    Topic "risk-schedule" "スケジュール: 遅延 / クリティカルパス / 休暇"
    Topic "risk-resource" "体制・負荷: キーマン依存 / レビュー不足"
    Topic "risk-stakeholder" "関係者: 合意不足 / 承認待ち / 利害衝突"
    Topic "risk-operation" "運用: 移行 / 障害対応 / サポート"
  ) -join "")
  Topic "risk-accepted" "受容済みリスク" "symbol-info" @() "" (@(
    Topic "risk-accepted-1" "[R-900] 受容理由 / 承認者 / 再評価日"
  ) -join "")
) -join ""

$actionChildren = @(
  Topic "action-rules" "TODOの書き方" "symbol-info" @("必須") "" (@(
    Topic "action-rule-owner" "担当者: 個人名または明確な役割"
    Topic "action-rule-due" "期限: YYYY-MM-DD"
    Topic "action-rule-dod" "完了条件: 何がどうなれば完了か"
    Topic "action-rule-evidence" "証跡: リンク / 添付 / 確認者"
  ) -join "")
  Topic "action-now" "P1 今週やる" "priority-1" @() "" (@(
    Topic "action-now-1" "[A-001] 内容 / 担当 / 期限 / 完了条件" "task-start"
    Topic "action-now-2" "[A-002] 内容 / 担当 / 期限 / 完了条件" "task-start"
  ) -join "")
  Topic "action-next" "P2 次回までに確認" "priority-2" @() "" (@(
    Topic "action-next-1" "[A-101] 内容 / 担当 / 期限 / 完了条件" "task-quarter"
    Topic "action-next-2" "[A-102] 内容 / 担当 / 期限 / 完了条件" "task-quarter"
  ) -join "")
  Topic "action-waiting" "Waiting 依存・返答待ち" "flag-orange" @() "" (@(
    Topic "action-waiting-1" "[A-201] 依頼先 / 依頼日 / 返答期限 / 次の手"
  ) -join "")
  Topic "action-done" "Done 完了ログ" "task-done" @() "" (@(
    Topic "action-done-1" "[A-900] 完了内容 / 完了日 / 証跡 / 確認者" "task-done"
  ) -join "")
) -join ""

$stakeholderChildren = @(
  Topic "stakeholder-core" "主要関係者" "people-blue" @() "" (@(
    Topic "stakeholder-owner" "Project Owner: 最終責任 / 予算 / 優先順位"
    Topic "stakeholder-pm" "PM: 進行 / 課題管理 / レビュー運営"
    Topic "stakeholder-lead" "Tech/Design/Business Lead: 専門判断"
    Topic "stakeholder-approver" "Approver: 承認者 / 決裁条件"
  ) -join "")
  Topic "stakeholder-raci" "RACI" "symbol-info" @() "" (@(
    Topic "stakeholder-r" "R Responsible: 実行責任"
    Topic "stakeholder-a" "A Accountable: 最終責任"
    Topic "stakeholder-c" "C Consulted: 相談先"
    Topic "stakeholder-i" "I Informed: 共有先"
  ) -join "")
  Topic "stakeholder-communication" "コミュニケーション設計" "" @() "" (@(
    Topic "stakeholder-meeting" "定例: 頻度 / 参加者 / 判断テーマ"
    Topic "stakeholder-report" "報告: チャネル / 形式 / 締切"
    Topic "stakeholder-escalation" "エスカレーション: 条件 / 連絡先 / SLA" "flag-red"
  ) -join "")
) -join ""

$retroChildren = @(
  Topic "retro-after-review" "レビュー後5分" "month-may" @() "" (@(
    Topic "retro-good" "Keep: 続けること"
    Topic "retro-problem" "Problem: 詰まったこと"
    Topic "retro-try" "Try: 次回変えること"
  ) -join "")
  Topic "retro-template" "テンプレ改善メモ" "star-blue" @() "" (@(
    Topic "retro-template-1" "足りなかった枝"
    Topic "retro-template-2" "使われなかった枝"
    Topic "retro-template-3" "次版で標準化する運用"
  ) -join "")
  Topic "retro-lessons" "ナレッジ化" "" @() "" (@(
    Topic "retro-lesson-1" "[Lesson] 状況 / 学び / 再利用条件"
    Topic "retro-lesson-2" "[Anti-pattern] 兆候 / 対策 / チェック方法"
  ) -join "")
) -join ""

$content = @"
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<xmap-content xmlns="urn:xmind:xmap:xmlns:content:2.0" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:svg="http://www.w3.org/2000/svg" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xlink="http://www.w3.org/1999/xlink" modified-by="Codex" timestamp="$timestamp" version="2.0">
$(Sheet "sheet-readme" "root-readme" "00 使い方" "プロジェクトレビュー テンプレート" "org.xmind.ui.logic.right" "配布用の使い方シート。まずここを読み、レビュー本体・意思決定ログ・リスク台帳・TODO管理へ進む。" $readmeChildren)
$(Sheet "sheet-dashboard" "root-dashboard" "01 レビュー本体" "Project Review Board" "org.xmind.ui.map.unbalanced" "会議の中心シート。結論、リスク、意思決定、次アクションの順に埋める。" $dashboardChildren)
$(Sheet "sheet-decisions" "root-decisions" "02 意思決定ログ" "Decision Log" "org.xmind.ui.logic.right" "判断待ちを会議後に残さないためのログ。決定理由と影響範囲まで残す。" $decisionChildren)
$(Sheet "sheet-risks" "root-risks" "03 リスク台帳" "Risk Register" "org.xmind.ui.logic.right" "リスクは内容だけでなく、影響・確率・対応策・オーナー・期限で管理する。" $riskChildren)
$(Sheet "sheet-actions" "root-actions" "04 アクショントラッカー" "Action Tracker" "org.xmind.ui.logic.right" "TODOは担当・期限・完了条件・証跡までセットで管理する。" $actionChildren)
$(Sheet "sheet-stakeholders" "root-stakeholders" "05 関係者・RACI" "Stakeholders and RACI" "org.xmind.ui.logic.right" "誰が決め、誰が実行し、誰に共有するかを明確にする。" $stakeholderChildren)
$(Sheet "sheet-retro" "root-retro" "06 学び・改善" "Lessons and Template Improvement" "org.xmind.ui.logic.right" "レビューのたびに運用とテンプレートを改善するためのシート。" $retroChildren)
</xmap-content>
"@

$styles = @"
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<xmap-styles xmlns="urn:xmind:xmap:xmlns:style:2.0" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:svg="http://www.w3.org/2000/svg" version="2.0">
  <automatic-styles>
    <style id="summary-style" name="" type="summary"><summary-properties line-color="#5C99D4"/></style>
    <style id="relationship-style" name="" type="relationship"><relationship-properties arrow-begin-class="org.xmind.arrowShape.none" arrow-end-class="org.xmind.arrowShape.triangle" fo:color="#0A5CB9" fo:font-family="Arial" fo:font-size="11pt" fo:font-style="italic" line-color="#0A5CB9" line-pattern="dash" line-width="2pt" shape-class="org.xmind.relationshipShape.curved"/></style>
    <style id="central-style" name="" type="topic"><topic-properties border-line-color="#1F2937" border-line-width="1pt" fo:color="#111827" fo:font-family="Arial" fo:font-size="22pt" fo:font-weight="bold" fo:text-align="center" line-class="org.xmind.branchConnection.straight" line-color="#374151" line-width="1pt" shape-class="org.xmind.topicShape.roundedRect" svg:fill="#F9FAFB"/></style>
    <style id="map-style" name="" type="map"><map-properties background="" color-gradient="none" line-tapered="none" multi-line-colors="none" svg:fill="#FFFFFF" svg:opacity="1.0"/></style>
    <style id="callout-style" name="" type="topic"><topic-properties border-line-width="0pt" fo:color="#FFFFFF" fo:font-family="Arial" fo:font-style="italic" line-class="org.xmind.branchConnection.roundedElbow" svg:fill="#2563EB"/></style>
    <style id="subtopic-style" name="" type="topic"><topic-properties fo:color="#374151" fo:font-family="Arial" fo:font-size="10pt" svg:fill="none"/></style>
    <style id="floating-style" name="" type="topic"><topic-properties border-line-width="1pt" fo:color="#111827" fo:font-family="Arial" fo:font-size="16pt" fo:font-weight="bold" line-class="org.xmind.branchConnection.elbow" line-color="#374151" line-width="1pt" shape-class="org.xmind.topicShape.rect" svg:fill="#FFFFFF"/></style>
    <style id="maintopic-style" name="" type="topic"><topic-properties border-line-color="#374151" border-line-width="1pt" fo:color="#111827" fo:font-family="Arial" fo:font-size="13pt" fo:font-weight="bold" line-width="1pt" svg:fill="#FFFFFF"/></style>
    <style id="boundary-style" name="" type="boundary"><boundary-properties fo:color="#111827" fo:font-family="Arial" fo:font-size="9pt" line-color="#CBD5E1" line-pattern="dash" line-width="2pt" shape-class="org.xmind.boundaryShape.roundedRect" svg:fill="#E5E7EB" svg:opacity=".5"/></style>
    <style id="summarytopic-style" name="" type="topic"><topic-properties border-line-width="0pt" fo:color="#374151" fo:font-family="Arial" fo:font-size="12pt" fo:font-style="italic" line-class="org.xmind.branchConnection.none" shape-class="org.xmind.topicShape.ellipse" svg:fill="none"/></style>
  </automatic-styles>
  <master-styles>
    <style id="public-template-theme" name="Project Review Template" type="theme">
      <theme-properties>
        <default-style style-family="summary" style-id="summary-style"/>
        <default-style style-family="relationship" style-id="relationship-style"/>
        <default-style style-family="centralTopic" style-id="central-style"/>
        <default-style style-family="map" style-id="map-style"/>
        <default-style style-family="calloutTopic" style-id="callout-style"/>
        <default-style style-family="subTopic" style-id="subtopic-style"/>
        <default-style style-family="floatingTopic" style-id="floating-style"/>
        <default-style style-family="mainTopic" style-id="maintopic-style"/>
        <default-style style-family="boundary" style-id="boundary-style"/>
        <default-style style-family="summaryTopic" style-id="summarytopic-style"/>
      </theme-properties>
    </style>
  </master-styles>
  <styles/>
</xmap-styles>
"@

$meta = @"
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<meta xmlns="urn:xmind:xmap:xmlns:meta:2.0" version="2.0">
  <Creator>
    <Name>Codex</Name>
    <Version>Project Review Public Template</Version>
  </Creator>
</meta>
"@

$manifest = @"
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<manifest xmlns="urn:xmind:xmap:xmlns:manifest:1.0" password-hint="">
  <file-entry full-path="content.xml" media-type="text/xml"/>
  <file-entry full-path="META-INF/" media-type=""/>
  <file-entry full-path="META-INF/manifest.xml" media-type="text/xml"/>
  <file-entry full-path="meta.xml" media-type="text/xml"/>
  <file-entry full-path="styles.xml" media-type="text/xml"/>
  <file-entry full-path="Thumbnails/" media-type=""/>
</manifest>
"@

Set-Content -LiteralPath (Join-Path $outDir "content.xml") -Value $content -Encoding UTF8
Set-Content -LiteralPath (Join-Path $outDir "styles.xml") -Value $styles -Encoding UTF8
Set-Content -LiteralPath (Join-Path $outDir "meta.xml") -Value $meta -Encoding UTF8
Set-Content -LiteralPath (Join-Path $outDir "META-INF\manifest.xml") -Value $manifest -Encoding UTF8

if (Test-Path -LiteralPath $outFile) {
  Remove-Item -LiteralPath $outFile -Force
}

$zipFile = "$outFile.zip"
if (Test-Path -LiteralPath $zipFile) {
  Remove-Item -LiteralPath $zipFile -Force
}

Compress-Archive -Path (Join-Path $outDir "*") -DestinationPath $zipFile -Force
Move-Item -LiteralPath $zipFile -Destination $outFile -Force

[xml](Get-Content -LiteralPath (Join-Path $outDir "content.xml") -Raw) | Out-Null
[xml](Get-Content -LiteralPath (Join-Path $outDir "styles.xml") -Raw) | Out-Null
[xml](Get-Content -LiteralPath (Join-Path $outDir "meta.xml") -Raw) | Out-Null
[xml](Get-Content -LiteralPath (Join-Path $outDir "META-INF\manifest.xml") -Raw) | Out-Null

if ($KeepExpanded) {
  $expandedOutDir = Join-Path $baseDir "project-review-public-template-xmind"
  if (Test-Path -LiteralPath $expandedOutDir) {
    Remove-Item -LiteralPath $expandedOutDir -Recurse -Force
  }
  Copy-Item -LiteralPath $outDir -Destination $expandedOutDir -Recurse
  Write-Host "Expanded package: $expandedOutDir"
}

if (Test-Path -LiteralPath $outDir) {
  Remove-Item -LiteralPath $outDir -Recurse -Force
}

Write-Host "Created: $outFile"
