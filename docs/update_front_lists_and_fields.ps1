$ErrorActionPreference = 'Stop'

$docPath = 'C:\Users\HP\tours_and_travel_app\docs\Shahid_Umer_And_Musharaf_Tours_Travel_Thesis_ExpeditionExact_v2.docx'

function Find-RangeByText {
    param(
        [Parameter(Mandatory = $true)] $Document,
        [Parameter(Mandatory = $true)] [string] $Text
    )

    $range = $Document.Content
    $find = $range.Find
    $find.ClearFormatting()
    $find.Text = $Text
    $find.Forward = $true
    $find.Wrap = 0
    $find.Format = $false
    $find.MatchCase = $false
    $find.MatchWholeWord = $false

    if (-not $find.Execute()) {
        throw "Text not found: $Text"
    }

    return $range
}

function Get-ParagraphsBetween {
    param(
        [Parameter(Mandatory = $true)] $Document,
        [Parameter(Mandatory = $true)] [string] $StartText,
        [Parameter(Mandatory = $true)] [string] $EndText
    )

    $start = Find-RangeByText -Document $Document -Text $StartText
    $end = Find-RangeByText -Document $Document -Text $EndText
    $range = $Document.Range($start.Paragraphs(1).Range.End, $end.Paragraphs(1).Range.Start)
    return $range.Paragraphs
}

function Replace-SectionLines {
    param(
        [Parameter(Mandatory = $true)] $Document,
        [Parameter(Mandatory = $true)] [string] $StartText,
        [Parameter(Mandatory = $true)] [string] $EndText,
        [Parameter(Mandatory = $true)] [System.Collections.Generic.List[string]] $Lines
    )

    $start = Find-RangeByText -Document $Document -Text $StartText
    $end = Find-RangeByText -Document $Document -Text $EndText

    $replaceRange = $Document.Range($start.Paragraphs(1).Range.End, $end.Paragraphs(1).Range.Start)
    $replaceRange.Text = ''

    if ($Lines.Count -gt 0) {
        $insertText = ($Lines -join "`r") + "`r"
        $end.Range.InsertBefore($insertText)
    }

    $paras = Get-ParagraphsBetween -Document $Document -StartText $StartText -EndText $EndText
    foreach ($p in $paras) {
        $text = $p.Range.Text.Trim([char]13, [char]7, ' ')
        if ($text) {
            $p.Range.Style = $Document.Styles.Item('Body Text')
        }
    }
}

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0

try {
    $doc = $word.Documents.Open($docPath, $false, $false)

    foreach ($toc in $doc.TablesOfContents) { $toc.Update() }
    $doc.Fields.Update() | Out-Null

    $chapter1 = Find-RangeByText -Document $doc -Text 'Chapter 1 Introduction'
    $bodyRange = $doc.Range($chapter1.Start, $doc.Content.End)

    $tableLines = New-Object 'System.Collections.Generic.List[string]'
    $figureLines = New-Object 'System.Collections.Generic.List[string]'

    foreach ($p in $bodyRange.Paragraphs) {
        $text = $p.Range.Text.Trim([char]13, [char]7, ' ')
        if (-not $text) { continue }
        $page = $p.Range.Information(1)
        if ($text -like 'Table *') {
            $tableLines.Add("$text`t$page")
        }
        elseif ($text -like 'Figure *') {
            $figureLines.Add("$text`t$page")
        }
    }

    Replace-SectionLines -Document $doc -StartText 'LIST OF TABLES' -EndText 'LIST OF FIGURES' -Lines $tableLines
    Replace-SectionLines -Document $doc -StartText 'LIST OF FIGURES' -EndText 'Chapter 1 Introduction' -Lines $figureLines

    foreach ($toc in $doc.TablesOfContents) { $toc.Update() }
    $doc.Fields.Update() | Out-Null

    $doc.Save()
    $doc.Close()
    Write-Output "Updated TOC, list of tables, and list of figures in $docPath"
}
finally {
    if ($word -ne $null) {
        $word.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
    }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}
