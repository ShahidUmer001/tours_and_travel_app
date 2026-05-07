Option Explicit

Const wdExportFormatPDF = 17

Dim inputPath, outputPath
inputPath = WScript.Arguments.Item(0)
outputPath = WScript.Arguments.Item(1)

Dim wordApp, doc
Set wordApp = CreateObject("Word.Application")
wordApp.Visible = False
wordApp.DisplayAlerts = 0

Set doc = wordApp.Documents.Open(inputPath, False, True)
doc.ExportAsFixedFormat outputPath, wdExportFormatPDF
doc.Close False
wordApp.Quit
