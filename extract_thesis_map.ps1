$ErrorActionPreference = 'Stop'

param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputJsonPath
)

$wdActiveEndPageNumber = 3

function Normalize-Text {
    param([string]$Text)

    if ($null -eq $Text) {
        return ''
    }

    $normalized = $Text -replace '[\r\a\v\f]', ' '
    $normalized = $normalized -replace '\s+', ' '
    return $normalized.Trim()
}

$frontMatterTitles = @(
    'APPROVAL FOR SUBMISSION',
    'DECLARATION OF ORGINALITY',
    'Submission and Copyrights',
    'Acknowledgment',
    'ABSTRACT',
    'TABLE OF CONTENTS',
    'LIST OF ABBREVIATIONS',
    'LIST OF TABLES',
    'LIST OF FIGURES'
)

$frontMatter = New-Object System.Collections.Generic.List[object]
$chapters = New-Object System.Collections.Generic.List[object]
$sections = New-Object System.Collections.Generic.List[object]
$tables = New-Object System.Collections.Generic.List[object]
$figures = New-Object System.Collections.Generic.List[object]

$seenFrontMatter = @{}
$chapter1Page = $null
$word = $null
$document = $null

try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0

    $document = $word.Documents.Open($InputPath, $false, $true)

    for ($i = 1; $i -le $document.Paragraphs.Count; $i++) {
        $paragraph = $document.Paragraphs.Item($i)
        try {
            $text = Normalize-Text $paragraph.Range.Text
            if ([string]::IsNullOrWhiteSpace($text)) {
                continue
            }

            if ($text -eq 'Chapter3 Requirement Engineering and Feasibility Study') {
                $text = 'Chapter 3 Requirement Engineering and Feasibility Study'
            }

            $styleName = ''
            try {
                $styleName = $paragraph.Range.Style.NameLocal
            }
            catch {
                $styleName = [string]$paragraph.Range.Style
            }

            $page = [int]$paragraph.Range.Information($wdActiveEndPageNumber)

            if ($frontMatterTitles -contains $text) {
                if (-not $seenFrontMatter.ContainsKey($text)) {
                    $frontMatter.Add([pscustomobject]@{
                        Title = $text
                        Page = $page
                    })
                    $seenFrontMatter[$text] = $true
                }
                continue
            }

            if ($text -match '^Chapter\s*\d+\b' -or $text -eq 'REFERENCES') {
                if ($text -eq 'Chapter 1 Introduction' -and $null -eq $chapter1Page) {
                    $chapter1Page = $page
                }

                $chapters.Add([pscustomobject]@{
                    Title = $text
                    Page = $page
                })
                continue
            }

            if ($styleName -eq 'Heading 2' -and $text -match '^\d+\.\d+\s+') {
                $sections.Add([pscustomobject]@{
                    Title = $text
                    Page = $page
                })
                continue
            }

            if ($text -match '^Table\s+\d+(?:\.\d+)*:') {
                $tables.Add([pscustomobject]@{
                    Title = $text
                    Page = $page
                })
                continue
            }

            if ($text -match '^Figure\s+\d+(?:\.\d+)*:') {
                $figures.Add([pscustomobject]@{
                    Title = $text
                    Page = $page
                })
            }
        }
        finally {
            [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($paragraph)
        }
    }

    if ($null -eq $chapter1Page) {
        throw 'Chapter 1 page could not be determined.'
    }

    $tables = @($tables | Where-Object { $_.Page -ge $chapter1Page })
    $figures = @($figures | Where-Object { $_.Page -ge $chapter1Page })

    $payload = [pscustomobject]@{
        front_matter = @($frontMatter)
        chapters = @($chapters)
        sections = @($sections)
        tables = @($tables)
        figures = @($figures)
        chapter_1_page = $chapter1Page
    }

    $payload | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $OutputJsonPath -Encoding UTF8
    Write-Output "Saved map to $OutputJsonPath"
}
finally {
    if ($document -ne $null) {
        try {
            $document.Close([ref]$false)
        }
        catch {
        }
    }

    if ($word -ne $null) {
        try {
            $word.Quit()
        }
        catch {
        }
    }

    if ($document -ne $null) {
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($document)
    }

    if ($word -ne $null) {
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($word)
    }

    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}
