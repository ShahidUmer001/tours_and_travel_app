$ErrorActionPreference = 'Stop'

$refPath = 'C:\Users\HP\tours_and_travel_app\docs\Expedition_Reference_Copy.docx'
$srcPath = 'C:\Users\HP\tours_and_travel_app\docs\Shahid_Source_Copy.docx'
$outPath = 'C:\Users\HP\tours_and_travel_app\docs\Shahid_Umer_And_Musharaf_Tours_Travel_Thesis_ExpeditionExact.docx'

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

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0

try {
    Copy-Item -LiteralPath $srcPath -Destination $outPath -Force

    $refDoc = $word.Documents.Open($refPath, $false, $true)
    $outDoc = $word.Documents.Open($outPath, $false, $false)

    $refChapter = Find-RangeByText -Document $refDoc -Text 'Chapter 1 Introduction'
    $outChapter = Find-RangeByText -Document $outDoc -Text 'Chapter 1 Introduction'

    $refFront = $refDoc.Range(0, $refChapter.Start)
    $outFront = $outDoc.Range(0, $outChapter.Start)
    $outFront.FormattedText = $refFront.FormattedText

    $outDoc.Save()
    $outDoc.Close()
    $refDoc.Close()

    Write-Output "Cloned front matter to $outPath"
}
finally {
    if ($word -ne $null) {
        $word.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
    }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}
