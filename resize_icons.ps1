# PowerShell script to create launcher icons from assets/logo.png
# This version uses the FULL image and just resizes it properly
Add-Type -AssemblyName System.Drawing

# Load the logo from assets folder
$sourcePath = "c:\Users\mathe\Desktop\project\ping\assets\logo.png"
$sourceImage = [System.Drawing.Image]::FromFile($sourcePath)

Write-Host "Source image size: $($sourceImage.Width) x $($sourceImage.Height)"

# Function to resize image with high quality - NO CROPPING
function Resize-Image {
    param($image, $targetSize)
    
    $output = New-Object System.Drawing.Bitmap($targetSize, $targetSize)
    $graphics = [System.Drawing.Graphics]::FromImage($output)
    
    # Set high quality rendering
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    
    # Draw the entire source image to fit the target size
    $graphics.DrawImage($image, 0, 0, $targetSize, $targetSize)
    $graphics.Dispose()
    
    return $output
}

# Resize for each density
$sizes = @{
    "mipmap-mdpi"    = 48
    "mipmap-hdpi"    = 72
    "mipmap-xhdpi"   = 96
    "mipmap-xxhdpi"  = 144
    "mipmap-xxxhdpi" = 192
}

$baseDir = "c:\Users\mathe\Desktop\project\ping\android\app\src\main\res"

foreach ($folder in $sizes.Keys) {
    $size = $sizes[$folder]
    $resized = Resize-Image $sourceImage $size
    $outputPath = Join-Path $baseDir "$folder\ic_launcher.png"
    $resized.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $resized.Dispose()
    Write-Host "Created $outputPath ($size x $size)"
}

$sourceImage.Dispose()

Write-Host "`nAll launcher icons created - using full logo image, no cropping!"
