$ErrorActionPreference = 'Stop'

$inputPath = 'C:\Users\HP\Desktop\Final_Year_Project_Tours_&_Travel_Thesis.docx'
$workspaceOutputPath = 'C:\Users\HP\tours_and_travel_app\Final_Year_Project_Tours_&_Travel_Thesis_updated.docx'
$desktopOutputPath = 'C:\Users\HP\Desktop\Final_Year_Project_Tours_&_Travel_Thesis_updated.docx'

$wdFormatDocumentDefault = 16
$wdActiveEndAdjustedPageNumber = 1
$wdActiveEndPageNumber = 3
$wdAlignTabRight = 2
$wdTabLeaderDots = 1

function Normalize-Text {
    param([string]$Text)

    if ($null -eq $Text) {
        return ''
    }

    $normalized = $Text -replace '[\r\a\v\f]', ' '
    $normalized = $normalized -replace '\s+', ' '
    return $normalized.Trim()
}

function ConvertTo-Roman {
    param([int]$Number)

    if ($Number -le 0) {
        return ''
    }

    $map = @(
        @{ Value = 1000; Symbol = 'm' },
        @{ Value = 900; Symbol = 'cm' },
        @{ Value = 500; Symbol = 'd' },
        @{ Value = 400; Symbol = 'cd' },
        @{ Value = 100; Symbol = 'c' },
        @{ Value = 90; Symbol = 'xc' },
        @{ Value = 50; Symbol = 'l' },
        @{ Value = 40; Symbol = 'xl' },
        @{ Value = 10; Symbol = 'x' },
        @{ Value = 9; Symbol = 'ix' },
        @{ Value = 5; Symbol = 'v' },
        @{ Value = 4; Symbol = 'iv' },
        @{ Value = 1; Symbol = 'i' }
    )

    $remaining = $Number
    $roman = ''

    foreach ($entry in $map) {
        while ($remaining -ge $entry.Value) {
            $roman += $entry.Symbol
            $remaining -= $entry.Value
        }
    }

    return $roman
}

function Get-Snapshot {
    param($Document)

    $items = New-Object System.Collections.Generic.List[object]
    $count = $Document.Paragraphs.Count

    for ($i = 1; $i -le $count; $i++) {
        $paragraph = $Document.Paragraphs.Item($i)
        try {
            $styleName = ''
            try {
                $styleName = $paragraph.Range.Style.NameLocal
            }
            catch {
                $styleName = [string]$paragraph.Range.Style
            }

            $items.Add([pscustomobject]@{
                Index = $i
                Text = Normalize-Text $paragraph.Range.Text
                Style = $styleName
                AdjustedPage = [int]$paragraph.Range.Information($wdActiveEndAdjustedPageNumber)
                AbsolutePage = [int]$paragraph.Range.Information($wdActiveEndPageNumber)
            })
        }
        finally {
            [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($paragraph)
        }
    }

    return $items
}

function Find-FirstByText {
    param(
        [System.Collections.Generic.List[object]]$Snapshot,
        [string]$Text
    )

    foreach ($item in $Snapshot) {
        if ($item.Text -eq $Text) {
            return $item
        }
    }

    throw "Could not find paragraph with text: $Text"
}

function Get-FilteredTocEntries {
    param([System.Collections.Generic.List[object]]$Snapshot)

    $chapter1 = Find-FirstByText $Snapshot 'Chapter 1 Introduction'
    $chapter1Page = $chapter1.AbsolutePage

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

    $entries = New-Object System.Collections.Generic.List[object]

    foreach ($title in $frontMatterTitles) {
        $match = Find-FirstByText $Snapshot $title
        $entries.Add([pscustomobject]@{
            Title = $title
            PageText = ConvertTo-Roman $match.AbsolutePage
            StyleName = 'TOC 1'
        })
    }

    foreach ($item in $Snapshot) {
        if ([string]::IsNullOrWhiteSpace($item.Text)) {
            continue
        }

        if ($item.AbsolutePage -lt $chapter1Page) {
            continue
        }

        if ($item.Text -match '^Chapter\s*\d+\b' -or $item.Text -eq 'REFERENCES') {
            $entries.Add([pscustomobject]@{
                Title = $item.Text
                PageText = [string]$item.AdjustedPage
                StyleName = 'TOC 1'
            })
            continue
        }

        if ($item.Style -eq 'Heading 2' -and $item.Text -match '^\d+\.\d+\s+') {
            $entries.Add([pscustomobject]@{
                Title = $item.Text
                PageText = [string]$item.AdjustedPage
                StyleName = 'TOC 2'
            })
        }
    }

    return $entries
}

function Get-CaptionEntries {
    param(
        [System.Collections.Generic.List[object]]$Snapshot,
        [string]$Prefix
    )

    $chapter1 = Find-FirstByText $Snapshot 'Chapter 1 Introduction'
    $chapter1Page = $chapter1.AbsolutePage
    $entries = New-Object System.Collections.Generic.List[object]
    $pattern = '^{0}\s+\d+(?:\.\d+)*:' -f [regex]::Escape($Prefix)

    foreach ($item in $Snapshot) {
        if ($item.AbsolutePage -lt $chapter1Page) {
            continue
        }

        if ($item.Text -match $pattern) {
            $entries.Add([pscustomobject]@{
                Title = $item.Text
                PageText = [string]$item.AdjustedPage
            })
        }
    }

    return $entries
}

function Replace-SectionText {
    param(
        $Document,
        [int]$StartAfterParagraphIndex,
        [int]$EndBeforeParagraphIndex,
        [string[]]$Lines
    )

    $startParagraph = $Document.Paragraphs.Item($StartAfterParagraphIndex)
    $endParagraph = $Document.Paragraphs.Item($EndBeforeParagraphIndex)
    $range = $Document.Range($startParagraph.Range.End, $endParagraph.Range.Start)

    try {
        if ($Lines.Count -eq 0) {
            $range.Text = ''
        }
        else {
            $range.Text = (($Lines -join "`r") + "`r")
        }
    }
    finally {
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($range)
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($startParagraph)
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($endParagraph)
    }
}

function Apply-StylesToInsertedParagraphs {
    param(
        $Document,
        [int]$FirstInsertedParagraphIndex,
        [object[]]$Entries,
        [double]$TabPosition
    )

    for ($i = 0; $i -lt $Entries.Count; $i++) {
        $paragraph = $Document.Paragraphs.Item($FirstInsertedParagraphIndex + $i)
        try {
            $paragraph.Range.Style = $Entries[$i].StyleName
            $paragraph.Range.ParagraphFormat.TabStops.ClearAll()
            [void]$paragraph.Range.ParagraphFormat.TabStops.Add($TabPosition, $wdAlignTabRight, $wdTabLeaderDots)
        }
        finally {
            [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($paragraph)
        }
    }
}

function Apply-ListFormatting {
    param(
        $Document,
        [int]$FirstInsertedParagraphIndex,
        [object[]]$Entries,
        [double]$TabPosition
    )

    for ($i = 0; $i -lt $Entries.Count; $i++) {
        $paragraph = $Document.Paragraphs.Item($FirstInsertedParagraphIndex + $i)
        try {
            $paragraph.Range.Style = 'Body Text'
            $paragraph.Range.ParagraphFormat.TabStops.ClearAll()
            [void]$paragraph.Range.ParagraphFormat.TabStops.Add($TabPosition, $wdAlignTabRight, $wdTabLeaderDots)
        }
        finally {
            [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($paragraph)
        }
    }
}

function Get-DefaultTabPosition {
    return 470
}

function Update-ManualIndexes {
    param($Document)

    $tocTabPosition = Get-DefaultTabPosition
    $listTabPosition = $tocTabPosition

    for ($pass = 1; $pass -le 3; $pass++) {
        $Document.Repaginate()
        $snapshot = Get-Snapshot $Document

        $tocHeading = Find-FirstByText $snapshot 'TABLE OF CONTENTS'
        $abbrHeading = Find-FirstByText $snapshot 'LIST OF ABBREVIATIONS'
        $tablesHeading = Find-FirstByText $snapshot 'LIST OF TABLES'
        $figuresHeading = Find-FirstByText $snapshot 'LIST OF FIGURES'
        $chapter1 = Find-FirstByText $snapshot 'Chapter 1 Introduction'

        $tocEntries = Get-FilteredTocEntries $snapshot
        $tocLines = foreach ($entry in $tocEntries) { '{0}{1}{2}' -f $entry.Title, [char]9, $entry.PageText }
        Replace-SectionText -Document $Document -StartAfterParagraphIndex $tocHeading.Index -EndBeforeParagraphIndex $abbrHeading.Index -Lines $tocLines
        Apply-StylesToInsertedParagraphs -Document $Document -FirstInsertedParagraphIndex ($tocHeading.Index + 1) -Entries @($tocEntries) -TabPosition $tocTabPosition

        $Document.Repaginate()
        $snapshot = Get-Snapshot $Document
        $tablesHeading = Find-FirstByText $snapshot 'LIST OF TABLES'
        $figuresHeading = Find-FirstByText $snapshot 'LIST OF FIGURES'

        $tableEntries = Get-CaptionEntries -Snapshot $snapshot -Prefix 'Table'
        $tableLines = foreach ($entry in $tableEntries) { '{0}{1}{2}' -f $entry.Title, [char]9, $entry.PageText }
        Replace-SectionText -Document $Document -StartAfterParagraphIndex $tablesHeading.Index -EndBeforeParagraphIndex $figuresHeading.Index -Lines $tableLines
        Apply-ListFormatting -Document $Document -FirstInsertedParagraphIndex ($tablesHeading.Index + 1) -Entries @($tableEntries) -TabPosition $listTabPosition

        $Document.Repaginate()
        $snapshot = Get-Snapshot $Document
        $figuresHeading = Find-FirstByText $snapshot 'LIST OF FIGURES'
        $chapter1 = Find-FirstByText $snapshot 'Chapter 1 Introduction'

        $figureEntries = Get-CaptionEntries -Snapshot $snapshot -Prefix 'Figure'
        $figureLines = foreach ($entry in $figureEntries) { '{0}{1}{2}' -f $entry.Title, [char]9, $entry.PageText }
        Replace-SectionText -Document $Document -StartAfterParagraphIndex $figuresHeading.Index -EndBeforeParagraphIndex $chapter1.Index -Lines $figureLines
        Apply-ListFormatting -Document $Document -FirstInsertedParagraphIndex ($figuresHeading.Index + 1) -Entries @($figureEntries) -TabPosition $listTabPosition
    }
}

$word = $null
$document = $null

try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0

    $document = $word.Documents.Open($inputPath, $false, $false)

    foreach ($paragraph in @($document.Paragraphs)) {
        try {
            $text = Normalize-Text $paragraph.Range.Text
            if ($text -eq 'Chapter3 Requirement Engineering and Feasibility Study') {
                $paragraph.Range.Text = 'Chapter 3 Requirement Engineering and Feasibility Study'
                $paragraph.Range.Style = 'Heading 1'
                break
            }
        }
        finally {
            [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($paragraph)
        }
    }

    Update-ManualIndexes -Document $document
    $document.Repaginate()

    $document.SaveAs2($workspaceOutputPath, $wdFormatDocumentDefault)
    Copy-Item -LiteralPath $workspaceOutputPath -Destination $desktopOutputPath -Force

    $snapshot = Get-Snapshot $document
    $tocHeading = Find-FirstByText $snapshot 'TABLE OF CONTENTS'
    $abbrHeading = Find-FirstByText $snapshot 'LIST OF ABBREVIATIONS'
    $tablesHeading = Find-FirstByText $snapshot 'LIST OF TABLES'
    $figuresHeading = Find-FirstByText $snapshot 'LIST OF FIGURES'
    $chapter1 = Find-FirstByText $snapshot 'Chapter 1 Introduction'

    $tableEntries = Get-CaptionEntries -Snapshot $snapshot -Prefix 'Table'
    $figureEntries = Get-CaptionEntries -Snapshot $snapshot -Prefix 'Figure'

    [pscustomobject]@{
        WorkspaceOutput = $workspaceOutputPath
        DesktopOutput = $desktopOutputPath
        TocPage = ConvertTo-Roman $tocHeading.AbsolutePage
        ListOfAbbreviationsPage = ConvertTo-Roman $abbrHeading.AbsolutePage
        ListOfTablesPage = ConvertTo-Roman $tablesHeading.AbsolutePage
        ListOfFiguresPage = ConvertTo-Roman $figuresHeading.AbsolutePage
        Chapter1Page = $chapter1.AdjustedPage
        TableCount = $tableEntries.Count
        FigureCount = $figureEntries.Count
        TotalPages = ($snapshot | Select-Object -Last 1).AbsolutePage
    } | Format-List
}
finally {
    if ($document -ne $null) {
        $document.Close([ref]$false)
    }

    if ($word -ne $null) {
        $word.Quit()
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
