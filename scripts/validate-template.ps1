$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$templatePath = Join-Path $repoRoot "templates/project-review-public-template.xmind"
$extractPath = Join-Path $env:TEMP ("project-review-xmind-template-verify-" + [guid]::NewGuid().ToString("N"))

if (-not (Test-Path -LiteralPath $templatePath)) {
  throw "Template file not found: $templatePath"
}

New-Item -ItemType Directory -Path $extractPath | Out-Null

try {
  Expand-Archive -LiteralPath $templatePath -DestinationPath $extractPath -Force

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

  if (-not $styles.DocumentElement) {
    throw "styles.xml did not parse as XML"
  }
  if (-not $meta.DocumentElement) {
    throw "meta.xml did not parse as XML"
  }
  if (-not $manifest.DocumentElement) {
    throw "manifest.xml did not parse as XML"
  }

  Write-Host "Template validation passed: $templatePath"
}
finally {
  if (Test-Path -LiteralPath $extractPath) {
    Remove-Item -LiteralPath $extractPath -Recurse -Force
  }
}
