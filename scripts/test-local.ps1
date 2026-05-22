$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

Write-Host "1/5 Validate checked-in template"
& (Join-Path $PSScriptRoot "validate-template.ps1")

Write-Host "2/5 Validate generated template in a temporary directory"
$tempOutput = Join-Path $env:TEMP ("project-review-xmind-template-build-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempOutput | Out-Null
try {
  & (Join-Path $repoRoot "tools/make-project-review-public-template.ps1") -OutputDir $tempOutput
  & (Join-Path $PSScriptRoot "validate-template.ps1") -TemplatePath (Join-Path $tempOutput "project-review-public-template.xmind")
}
finally {
  if (Test-Path -LiteralPath $tempOutput) {
    Remove-Item -LiteralPath $tempOutput -Recurse -Force
  }
}

Write-Host "3/5 Validate generated exchange formats"
$tempExports = Join-Path $env:TEMP ("project-review-xmind-template-exports-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempExports | Out-Null
try {
  & (Join-Path $repoRoot "tools/export-template-formats.ps1") -OutputDir $tempExports

  $expectedExports = @(
    "project-review-public-template.md",
    "project-review-public-template.opml",
    "project-review-public-template.mm",
    "project-review-public-template.mmd",
    "project-review-public-template.json",
    "project-review-public-template.csv",
    "project-review-public-template.tsv"
  )

  foreach ($expectedExport in $expectedExports) {
    $path = Join-Path $tempExports $expectedExport
    if (-not (Test-Path -LiteralPath $path)) {
      throw "Expected export is missing: $expectedExport"
    }
    if ((Get-Item -LiteralPath $path).Length -le 0) {
      throw "Expected export is empty: $expectedExport"
    }
  }

  [xml](Get-Content -LiteralPath (Join-Path $tempExports "project-review-public-template.opml") -Raw) | Out-Null
  [xml](Get-Content -LiteralPath (Join-Path $tempExports "project-review-public-template.mm") -Raw) | Out-Null
  Get-Content -LiteralPath (Join-Path $tempExports "project-review-public-template.json") -Raw | ConvertFrom-Json | Out-Null

  $markdown = Get-Content -LiteralPath (Join-Path $tempExports "project-review-public-template.md") -Raw
  if ($markdown -notmatch "## 01 レビュー本体") {
    throw "Markdown export is missing the review body sheet"
  }

  $mermaid = Get-Content -LiteralPath (Join-Path $tempExports "project-review-public-template.mmd") -Raw
  if ($mermaid -notmatch "^mindmap") {
    throw "Mermaid export does not start with mindmap"
  }

  $csvRows = Import-Csv -LiteralPath (Join-Path $tempExports "project-review-public-template.csv")
  if ($csvRows.Count -lt 50) {
    throw "CSV export has too few rows: $($csvRows.Count)"
  }

  $checkedInExports = Join-Path $repoRoot "exports"
  if (Test-Path -LiteralPath $checkedInExports) {
    foreach ($expectedExport in $expectedExports) {
      $generatedPath = Join-Path $tempExports $expectedExport
      $checkedInPath = Join-Path $checkedInExports $expectedExport
      if (-not (Test-Path -LiteralPath $checkedInPath)) {
        throw "Checked-in export is missing: $expectedExport"
      }

      $generatedContent = (Get-Content -LiteralPath $generatedPath -Raw) -replace "`r`n", "`n"
      $checkedInContent = (Get-Content -LiteralPath $checkedInPath -Raw) -replace "`r`n", "`n"
      if ($generatedContent -ne $checkedInContent) {
        throw "Checked-in export is stale: $expectedExport. Run ./tools/export-template-formats.ps1"
      }
    }
  }
}
finally {
  if (Test-Path -LiteralPath $tempExports) {
    Remove-Item -LiteralPath $tempExports -Recurse -Force
  }
}

Write-Host "4/5 Check local Markdown links"
$markdownFiles = Get-ChildItem -LiteralPath $repoRoot -Recurse -File -Include "*.md" | Where-Object {
  $_.FullName -notmatch "\\.git\\"
}

foreach ($markdownFile in $markdownFiles) {
  $content = Get-Content -LiteralPath $markdownFile.FullName -Raw
  $matches = [regex]::Matches($content, "\[[^\]]+\]\(([^)]+)\)")
  foreach ($match in $matches) {
    $target = $match.Groups[1].Value
    if ($target -match "^[a-zA-Z][a-zA-Z0-9+.-]*:") {
      continue
    }
    if ($target.StartsWith("#")) {
      continue
    }

    $targetPath = $target.Split("#")[0]
    if (-not $targetPath) {
      continue
    }

    $resolvedPath = Join-Path $markdownFile.DirectoryName $targetPath
    if (-not (Test-Path -LiteralPath $resolvedPath)) {
      throw "Broken Markdown link in $($markdownFile.FullName): $target"
    }
  }
}

$previewSvg = Join-Path $repoRoot "assets/preview.svg"
if (Test-Path -LiteralPath $previewSvg) {
  [xml](Get-Content -LiteralPath $previewSvg -Raw) | Out-Null
}

Write-Host "5/5 Check for local absolute paths in publishable files"
$publishableFiles = Get-ChildItem -LiteralPath $repoRoot -Recurse -File | Where-Object {
  $_.FullName -notmatch "\\.git\\" -and
  $_.FullName -notmatch "\\templates\\project-review-public-template-xmind\\" -and
  (
    $_.Extension -in @(".md", ".ps1", ".yml", ".yaml", ".gitignore", ".svg") -or
    $_.Name -in @("LICENSE")
  )
}

foreach ($file in $publishableFiles) {
  $content = Get-Content -LiteralPath $file.FullName -Raw
  if ($content -match "C:\\Users\\") {
    throw "Local absolute path found in publishable file: $($file.FullName)"
  }
}

Write-Host "Local test suite passed."
