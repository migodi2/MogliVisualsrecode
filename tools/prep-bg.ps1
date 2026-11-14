# Подготовка фонов для MogliVisuals Recode
# Превращает любое фото в чёрно-белую заготовку 1600x1000 (16:10) для лаунчера и сайта.
#
# Использование:
#   powershell -ExecutionPolicy Bypass -File tools\prep-bg.ps1 -Source "C:\путь\фото.jpg" -Id forest2 -Name "Туманный лес"
#
# Что делает:
#   - центральный кроп до 16:10
#   - ресайз до 1600x1000 (HighQualityBicubic)
#   - перевод в чёрно-белое (luminance) с лёгким повышением контраста
#   - сохранение PNG в site\assets\ и MogliVisualsLauncher\ui\assets\
param(
    [Parameter(Mandatory = $true)][string]$Source,
    [Parameter(Mandatory = $true)][string]$Id,
    [string]$Name = "",
    [int]$Width = 1600,
    [int]$Height = 1000
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSCommandPath))
$targets = @(
    (Join-Path $root "site\assets\$Id.png"),
    (Join-Path $root "MogliVisualsLauncher\ui\assets\$Id.png")
)

if (-not (Test-Path $Source)) { throw "Файл не найден: $Source" }

$src = [System.Drawing.Image]::FromFile((Resolve-Path $Source))
$targetRatio = $Width / $Height
$srcRatio = $src.Width / $src.Height
$cropW = $src.Width; $cropH = $src.Height; $cropX = 0; $cropY = 0
if ($srcRatio -gt $targetRatio) {
    $cropW = [int]($src.Height * $targetRatio)
    $cropX = [int](($src.Width - $cropW) / 2)
} else {
    $cropH = [int]($src.Width / $targetRatio)
    $cropY = [int](($src.Height - $cropH) / 2)
}

# 1) кроп + ресайз
$scaled = New-Object System.Drawing.Bitmap $Width, $Height
$g = [System.Drawing.Graphics]::FromImage($scaled)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
$dstRect = New-Object System.Drawing.Rectangle 0, 0, $Width, $Height
$srcRect = New-Object System.Drawing.Rectangle $cropX, $cropY, $cropW, $cropH
$g.DrawImage($src, $dstRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()

# 2) сохраняем (монохром/контраст применяются в CSS приложения — см. переменные --bg-mono/--bg-bright/--bg-contrast)
$gray = $scaled

foreach ($t in $targets) {
    $dir = Split-Path -Parent $t
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $gray.Save($t, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Output ("saved: " + (Split-Path -Leaf $t) + " (" + (Get-Item $t).Length + " bytes)")
}
$gray.Dispose()
$src.Dispose()

$label = if ($Name) { $Name } else { $Id }
Write-Output ""
Write-Output "Done. Add this entry to the BACKGROUNDS array in BOTH index.html files:"
$entry = '  { id: "' + $Id + '", file: "assets/' + $Id + '.png", pos: "50% 40%", bright: ".78", contrast: "1.12", blur: "18px", name: "' + $label + '" },'
Write-Output $entry
