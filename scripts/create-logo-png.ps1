$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$outPath = Join-Path $root "assets\ai-api-cost-guide-logo.png"

$width = 1200
$height = 630
$bitmap = New-Object System.Drawing.Bitmap $width, $height
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

function New-Brush($hex) {
  return New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml($hex))
}

function New-Pen($hex, $size) {
  $pen = New-Object System.Drawing.Pen ([System.Drawing.ColorTranslator]::FromHtml($hex)), $size
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
  return $pen
}

$bg = New-Brush "#f5f7f8"
$surface = New-Brush "#ffffff"
$ink = New-Brush "#111827"
$muted = New-Brush "#5b6675"
$green = New-Pen "#087568" 11
$warm = New-Brush "#a45612"
$greenBrush = New-Brush "#0f8b7d"
$whitePen = New-Pen "#ffffff" 10
$linePen = New-Object System.Drawing.Pen ([System.Drawing.ColorTranslator]::FromHtml("#d9e1e5")), 3

$graphics.FillRectangle($bg, 0, 0, $width, $height)
$cardRect = New-Object System.Drawing.Rectangle 74, 70, 1052, 490
$cardPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$radius = 28
$cardPath.AddArc($cardRect.X, $cardRect.Y, $radius, $radius, 180, 90)
$cardPath.AddArc($cardRect.Right - $radius, $cardRect.Y, $radius, $radius, 270, 90)
$cardPath.AddArc($cardRect.Right - $radius, $cardRect.Bottom - $radius, $radius, $radius, 0, 90)
$cardPath.AddArc($cardRect.X, $cardRect.Bottom - $radius, $radius, $radius, 90, 90)
$cardPath.CloseFigure()
$graphics.FillPath($surface, $cardPath)
$graphics.DrawPath($linePen, $cardPath)

$markRect = New-Object System.Drawing.Rectangle 132, 154, 142, 142
$markPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$markRadius = 34
$markPath.AddArc($markRect.X, $markRect.Y, $markRadius, $markRadius, 180, 90)
$markPath.AddArc($markRect.Right - $markRadius, $markRect.Y, $markRadius, $markRadius, 270, 90)
$markPath.AddArc($markRect.Right - $markRadius, $markRect.Bottom - $markRadius, $markRadius, $markRadius, 0, 90)
$markPath.AddArc($markRect.X, $markRect.Bottom - $markRadius, $markRadius, $markRadius, 90, 90)
$markPath.CloseFigure()
$graphics.FillPath($ink, $markPath)

$graphics.DrawLines($whitePen, @(
  [System.Drawing.Point]::new(177,198),
  [System.Drawing.Point]::new(157,225),
  [System.Drawing.Point]::new(177,252)
))
$graphics.DrawLines($whitePen, @(
  [System.Drawing.Point]::new(229,198),
  [System.Drawing.Point]::new(249,225),
  [System.Drawing.Point]::new(229,252)
))

$curve = New-Object System.Drawing.Drawing2D.GraphicsPath
$curve.AddBezier(179, 247, 198, 211, 221, 192, 246, 189)
$graphics.DrawPath($green, $curve)
$graphics.FillEllipse($warm, 172, 240, 14, 14)
$graphics.FillEllipse($greenBrush, 239, 182, 14, 14)

$fontLarge = New-Object System.Drawing.Font "Arial", 78, ([System.Drawing.FontStyle]::Bold)
$fontSmall = New-Object System.Drawing.Font "Arial", 29, ([System.Drawing.FontStyle]::Regular)
$graphics.DrawString("AI API", $fontLarge, $ink, 318, 150)
$graphics.DrawString("Cost Guide", $fontLarge, $ink, 318, 238)
$graphics.FillRectangle($greenBrush, 320, 369, 486, 6)
$graphics.DrawString("Compare API pricing. Estimate monthly cost.", $fontSmall, $muted, 318, 405)

$bitmap.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose()
$bitmap.Dispose()

Write-Host $outPath
