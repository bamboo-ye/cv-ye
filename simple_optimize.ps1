Write-Host "开始图片优化..." -ForegroundColor Green

# 首先检查当前目录
Write-Host "当前目录: $(Get-Location)" -ForegroundColor Cyan

# 检查System.Drawing是否可用
try {
    Add-Type -AssemblyName System.Drawing
    Write-Host "System.Drawing 加载成功" -ForegroundColor Green
} catch {
    Write-Host "System.Drawing 加载失败: $_" -ForegroundColor Red
    exit 1
}

$imagesDir = "d:\cv-ye\images"
$backupDir = "d:\cv-ye\images_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

# 备份原始图片
Write-Host "正在备份原始图片..." -ForegroundColor Yellow
Copy-Item -Path $imagesDir -Destination $backupDir -Recurse -Force
Write-Host "备份完成: $backupDir" -ForegroundColor Green

$totalSaved = 0

# 只处理JPG图片 - 它们通常是最大的
Get-ChildItem -Path "$imagesDir\profile", "$imagesDir\projects" -Filter "*.jpg" -File | ForEach-Object {
    $file = $_
    $originalSize = $file.Length
    Write-Host "`n处理: $($file.Name)" -ForegroundColor Cyan
    Write-Host "  原始大小: $([math]::Round($originalSize/1KB, 2)) KB"
    
    try {
        $img = [System.Drawing.Image]::FromFile($file.FullName)
        Write-Host "  原始尺寸: $($img.Width)x$($img.Height)"
        
        # 计算新尺寸 - 头像最大宽度600px，项目图片最大宽度1200px
        $maxWidth = if ($file.Directory.Name -eq "profile") { 600 } else { 1200 }
        $newWidth = [Math]::Min($img.Width, $maxWidth)
        $newHeight = [int]($img.Height * ($newWidth / $img.Width))
        
        Write-Host "  新尺寸: ${newWidth}x${newHeight}"
        
        # 创建新图片
        $bmp = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
        $gfx = [System.Drawing.Graphics]::FromImage($bmp)
        $gfx.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $gfx.DrawImage($img, 0, 0, $newWidth, $newHeight)
        
        # 保存JPG，质量75%
        $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 75L)
        $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
        
        $bmp.Save($file.FullName, $jpegCodec, $encoderParams)
        
        # 清理
        $gfx.Dispose()
        $bmp.Dispose()
        $img.Dispose()
        
        # 检查新大小
        $newFile = Get-Item $file.FullName
        $newSize = $newFile.Length
        $saved = $originalSize - $newSize
        $savedPercent = [math]::Round(($saved / $originalSize) * 100, 1)
        $totalSaved += $saved
        
        Write-Host "  新大小: $([math]::Round($newSize/1KB, 2)) KB" -ForegroundColor Green
        Write-Host "  节省: $([math]::Round($saved/1KB, 2)) KB (${savedPercent}%)" -ForegroundColor Green
        
    } catch {
        Write-Host "  处理失败: $_" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "总共节省: $([math]::Round($totalSaved/1MB, 2)) MB" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Yellow
Write-Host "优化完成！" -ForegroundColor Green
