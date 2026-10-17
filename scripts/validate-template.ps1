[CmdletBinding()]
param(
  [string]$TemplatePath
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not $TemplatePath) {
  $TemplatePath = Join-Path $repoRoot "templates/project-review-public-template.xmind"
}
$extractPath = Join-Path $env:TEMP ("project-review-xmind-template-verify-" + [guid]::NewGuid().ToString("N"))

if (-not (Test-Path -LiteralPath $TemplatePath)) {
  throw "Template file not found: $TemplatePath"
}

New-Item -ItemType Directory -Path $extractPath | Out-Null

try {
  Expand-Archive -LiteralPath $TemplatePath -DestinationPath $extractPath -Force

  $requiredFiles = @(
    "content.xml",
    "styles.xml",
    "meta.xml",
    "META-INF/manifest.xml"
  )

  foreach ($requiredFile in $requiredFiles) {
    $path = Join-Path $extractPath $requiredFile
    if (-not (Test-Path -LiteralPath $path)) {
      throw "Required XMind package file is missing: $requiredFile"
    }
  }

  [xml]$content = Get-Content -LiteralPath (Join-Path $extractPath "content.xml") -Raw
  [xml]$styles = Get-Content -LiteralPath (Join-Path $extractPath "styles.xml") -Raw
  [xml]$meta = Get-Content -LiteralPath (Join-Path $extractPath "meta.xml") -Raw
  [xml]$manifest = Get-Content -LiteralPath (Join-Path $extractPath "META-INF/manifest.xml") -Raw

  $namespace = New-Object System.Xml.XmlNamespaceManager($content.NameTable)
  $namespace.AddNamespace("x", "urn:xmind:xmap:xmlns:content:2.0")

  $sheets = $content.SelectNodes("//x:sheet", $namespace)
  if ($sheets.Count -ne 7) {
    throw "Expected 7 sheets, found $($sheets.Count)"
  }

  $expectedSheetTitles = @(
    "00 使い方",
    "01 レビュー本体",
    "02 意思決定ログ",
    "03 リスク台帳",
    "04 アクショントラッカー",
    "05 関係者・RACI",
    "06 学び・改善"
  )

  $actualSheetTitles = @($sheets | ForEach-Object { $_.title })
  foreach ($expectedTitle in $expectedSheetTitles) {
    if ($actualSheetTitles -notcontains $expectedTitle) {
      throw "Expected sheet title is missing: $expectedTitle"
    }
  }

  $expectedRootTitles = @(
    "プロジェクトレビュー テンプレート",
    "Project Review Board",
    "Decision Log",
    "Risk Register",
    "Action Tracker",
    "Stakeholders and RACI",
    "Lessons and Template Improvement"
  )

  $rootTitles = @($content.SelectNodes("//x:sheet/x:topic/x:title", $namespace) | ForEach-Object { $_."#text" })
  foreach ($expectedRootTitle in $expectedRootTitles) {
    if ($rootTitles -notcontains $expectedRootTitle) {
      throw "Expected root topic is missing: $expectedRootTitle"
    }
  }

  $allTitles = @($content.SelectNodes("//x:topic/x:title", $namespace) | ForEach-Object { $_."#text" })
  $requiredOperationalTopics = @(
    "00 エグゼクティブサマリー",
    "04 課題・リスク Top 5",
    "05 今日決めること",
    "06 次アクション",
    "決定カードの型",
    "Critical: 今すぐ扱う",
    "TODOの書き方",
    "RACI",
    "レビュー後5分"
  )

  foreach ($requiredTopic in $requiredOperationalTopics) {
    if ($allTitles -notcontains $requiredTopic) {
      throw "Required operational topic is missing: $requiredTopic"
    }
  }

  $placeholderTitles = @($allTitles | Where-Object { $_ -match "\[[^\]]+\]" })
  if ($placeholderTitles.Count -lt 10) {
    throw "Expected at least 10 editable placeholder topics, found $($placeholderTitles.Count)"
  }

  if (-not $styles.DocumentElement) {
    throw "styles.xml did not parse as XML"
  }
  if (-not $meta.DocumentElement) {
    throw "meta.xml did not parse as XML"
  }
  if (-not $manifest.DocumentElement) {
    throw "manifest.xml did not parse as XML"
  }

  Write-Host "Template validation passed: $TemplatePath"
}
finally {
  if (Test-Path -LiteralPath $extractPath) {
    Remove-Item -LiteralPath $extractPath -Recurse -Force
  }
}
