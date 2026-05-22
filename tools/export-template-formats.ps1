[CmdletBinding()]
param(
  [string]$TemplatePath,
  [string]$OutputDir
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not $TemplatePath) {
  $TemplatePath = Join-Path $repoRoot "templates/project-review-public-template.xmind"
}
if (-not $OutputDir) {
  $OutputDir = Join-Path $repoRoot "exports"
}

if (-not (Test-Path -LiteralPath $TemplatePath)) {
  throw "Template file not found: $TemplatePath"
}

if (-not (Test-Path -LiteralPath $OutputDir)) {
  New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$extractPath = Join-Path $env:TEMP ("project-review-xmind-export-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $extractPath | Out-Null

function Escape-XmlText {
  param([string]$Text)
  return [System.Security.SecurityElement]::Escape($Text)
}

function Escape-CsvField {
  param([string]$Text)
  if ($null -eq $Text) {
    return ""
  }
  return '"' + ($Text -replace '"', '""') + '"'
}

function Escape-MermaidLabel {
  param([string]$Text)
  return (($Text -replace '"', "'") -replace "`r?`n", " ")
}

function Get-DirectAttachedTopics {
  param(
    [System.Xml.XmlElement]$Topic,
    [System.Xml.XmlNamespaceManager]$Namespace
  )

  $topicsNode = $Topic.SelectSingleNode("x:children/x:topics[@type='attached']", $Namespace)
  if (-not $topicsNode) {
    return @()
  }
  return @($topicsNode.SelectNodes("x:topic", $Namespace))
}

function Convert-Topic {
  param(
    [System.Xml.XmlElement]$Topic,
    [System.Xml.XmlNamespaceManager]$Namespace
  )

  $titleNode = $Topic.SelectSingleNode("x:title", $Namespace)
  $title = if ($titleNode) { $titleNode.InnerText } else { "" }

  $children = @()
  foreach ($child in (Get-DirectAttachedTopics -Topic $Topic -Namespace $Namespace)) {
    $children += Convert-Topic -Topic $child -Namespace $Namespace
  }

  return [ordered]@{
    title = $title
    children = $children
  }
}

function Write-MarkdownTopic {
  param(
    [System.Collections.IDictionary]$Topic,
    [int]$Depth,
    [System.Collections.Generic.List[string]]$Lines
  )

  $prefix = "  " * [Math]::Max(0, $Depth - 1)
  $Lines.Add("$prefix- $($Topic.title)")
  foreach ($child in $Topic.children) {
    Write-MarkdownTopic -Topic $child -Depth ($Depth + 1) -Lines $Lines
  }
}

function Write-OpmlTopic {
  param(
    [System.Collections.IDictionary]$Topic,
    [int]$Depth,
    [System.Collections.Generic.List[string]]$Lines
  )

  $indent = "  " * $Depth
  $text = Escape-XmlText $Topic.title
  if ($Topic.children.Count -eq 0) {
    $Lines.Add("$indent<outline text=""$text""/>")
    return
  }

  $Lines.Add("$indent<outline text=""$text"">")
  foreach ($child in $Topic.children) {
    Write-OpmlTopic -Topic $child -Depth ($Depth + 1) -Lines $Lines
  }
  $Lines.Add("$indent</outline>")
}

function Write-FreeMindTopic {
  param(
    [System.Collections.IDictionary]$Topic,
    [int]$Depth,
    [System.Collections.Generic.List[string]]$Lines
  )

  $indent = "  " * $Depth
  $text = Escape-XmlText $Topic.title
  if ($Topic.children.Count -eq 0) {
    $Lines.Add("$indent<node TEXT=""$text""/>")
    return
  }

  $Lines.Add("$indent<node TEXT=""$text"">")
  foreach ($child in $Topic.children) {
    Write-FreeMindTopic -Topic $child -Depth ($Depth + 1) -Lines $Lines
  }
  $Lines.Add("$indent</node>")
}

function Write-MermaidTopic {
  param(
    [System.Collections.IDictionary]$Topic,
    [int]$Depth,
    [System.Collections.Generic.List[string]]$Lines
  )

  $indent = "  " * $Depth
  $label = Escape-MermaidLabel $Topic.title
  $Lines.Add("$indent$label")
  foreach ($child in $Topic.children) {
    Write-MermaidTopic -Topic $child -Depth ($Depth + 1) -Lines $Lines
  }
}

function Flatten-Topic {
  param(
    [System.Collections.IDictionary]$Topic,
    [string]$Sheet,
    [string]$Path,
    [int]$Depth,
    [System.Collections.Generic.List[object]]$Rows
  )

  $currentPath = if ($Path) { "$Path > $($Topic.title)" } else { $Topic.title }
  $Rows.Add([ordered]@{
    sheet = $Sheet
    depth = $Depth
    title = $Topic.title
    path = $currentPath
  })

  foreach ($child in $Topic.children) {
    Flatten-Topic -Topic $child -Sheet $Sheet -Path $currentPath -Depth ($Depth + 1) -Rows $Rows
  }
}

try {
  Expand-Archive -LiteralPath $TemplatePath -DestinationPath $extractPath -Force
  [xml]$content = Get-Content -LiteralPath (Join-Path $extractPath "content.xml") -Raw

  $namespace = New-Object System.Xml.XmlNamespaceManager($content.NameTable)
  $namespace.AddNamespace("x", "urn:xmind:xmap:xmlns:content:2.0")

  $sheets = @()
  foreach ($sheet in @($content.SelectNodes("//x:sheet", $namespace))) {
    $sheetTitle = $sheet.SelectSingleNode("x:title", $namespace).InnerText
    $rootTopic = $sheet.SelectSingleNode("x:topic", $namespace)
    $sheets += [ordered]@{
      title = $sheetTitle
      root = Convert-Topic -Topic $rootTopic -Namespace $namespace
    }
  }

  $baseName = "project-review-public-template"

  $jsonPath = Join-Path $OutputDir "$baseName.json"
  [ordered]@{
    format = "project-review-mindmap"
    sheets = $sheets
  } | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

  $mdLines = [System.Collections.Generic.List[string]]::new()
  $mdLines.Add("# Project Review Public Template")
  $mdLines.Add("")
  foreach ($sheet in $sheets) {
    $mdLines.Add("## $($sheet.title)")
    $mdLines.Add("")
    Write-MarkdownTopic -Topic $sheet.root -Depth 1 -Lines $mdLines
    $mdLines.Add("")
  }
  Set-Content -LiteralPath (Join-Path $OutputDir "$baseName.md") -Value $mdLines -Encoding UTF8

  $opmlLines = [System.Collections.Generic.List[string]]::new()
  $opmlLines.Add('<?xml version="1.0" encoding="UTF-8"?>')
  $opmlLines.Add('<opml version="2.0">')
  $opmlLines.Add('  <head><title>Project Review Public Template</title></head>')
  $opmlLines.Add('  <body>')
  foreach ($sheet in $sheets) {
    $sheetTopic = [ordered]@{ title = $sheet.title; children = @($sheet.root) }
    Write-OpmlTopic -Topic $sheetTopic -Depth 2 -Lines $opmlLines
  }
  $opmlLines.Add('  </body>')
  $opmlLines.Add('</opml>')
  Set-Content -LiteralPath (Join-Path $OutputDir "$baseName.opml") -Value $opmlLines -Encoding UTF8

  $mmRoot = [ordered]@{
    title = "Project Review Public Template"
    children = @($sheets | ForEach-Object { [ordered]@{ title = $_.title; children = @($_.root) } })
  }
  $mmLines = [System.Collections.Generic.List[string]]::new()
  $mmLines.Add('<?xml version="1.0" encoding="UTF-8"?>')
  $mmLines.Add('<map version="1.0.1">')
  Write-FreeMindTopic -Topic $mmRoot -Depth 1 -Lines $mmLines
  $mmLines.Add('</map>')
  Set-Content -LiteralPath (Join-Path $OutputDir "$baseName.mm") -Value $mmLines -Encoding UTF8

  $mmdLines = [System.Collections.Generic.List[string]]::new()
  $mmdLines.Add("mindmap")
  $mmdRoot = [ordered]@{
    title = "Project Review Public Template"
    children = @($sheets | ForEach-Object { [ordered]@{ title = $_.title; children = @($_.root) } })
  }
  Write-MermaidTopic -Topic $mmdRoot -Depth 1 -Lines $mmdLines
  Set-Content -LiteralPath (Join-Path $OutputDir "$baseName.mmd") -Value $mmdLines -Encoding UTF8

  $rows = [System.Collections.Generic.List[object]]::new()
  foreach ($sheet in $sheets) {
    Flatten-Topic -Topic $sheet.root -Sheet $sheet.title -Path "" -Depth 0 -Rows $rows
  }

  $csvLines = [System.Collections.Generic.List[string]]::new()
  $csvLines.Add("sheet,depth,title,path")
  foreach ($row in $rows) {
    $csvLines.Add(((Escape-CsvField $row.sheet), $row.depth, (Escape-CsvField $row.title), (Escape-CsvField $row.path)) -join ",")
  }
  Set-Content -LiteralPath (Join-Path $OutputDir "$baseName.csv") -Value $csvLines -Encoding UTF8

  $tsvLines = [System.Collections.Generic.List[string]]::new()
  $tsvLines.Add("sheet`tdepth`ttitle`tpath")
  foreach ($row in $rows) {
    $title = ($row.title -replace "`t", " " -replace "`r?`n", " ")
    $path = ($row.path -replace "`t", " " -replace "`r?`n", " ")
    $tsvLines.Add("$($row.sheet)`t$($row.depth)`t$title`t$path")
  }
  Set-Content -LiteralPath (Join-Path $OutputDir "$baseName.tsv") -Value $tsvLines -Encoding UTF8

  Write-Host "Exported formats to: $OutputDir"
}
finally {
  if (Test-Path -LiteralPath $extractPath) {
    Remove-Item -LiteralPath $extractPath -Recurse -Force
  }
}
