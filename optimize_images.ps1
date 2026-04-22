Add-Type -AssemblyName System.Drawing

$imagesDir = "d:\cv-ye\images"
$optimizedDir = "d:\cv-ye\images_optimized"

# 创建优化后的目录
if (-not (Test-Path $optimizedDir)) {
    New-Item -ItemType Directory -Path $optimizedDir -Force | Out-Null
    # 复制目录结构
    Get-ChildItem -Path $imagesDir -Recurse -Directory | ForEach-Object {
        $newDir = $_.FullName.Replace($imagesDir, $optimizedDir)
        if (-not (Test-Path $newDir)) {
            New-Item -ItemType Directory -Path $newDir -Force | Out-Null
        }
    }
}

# 复制视频文件
Get-ChildItem -Path $imagesDir -Recurse -File | Where-Object { $_.Extension -in @('.mp4') } | ForEach-Object {
    $sourcePath = $_.FullName
    $destPath = $sourcePath.Replace($imagesDir, $optimizedDir)
    Copy-Item -Path $sourcePath -Destination $destPath -Force
    Write-Host "复制视频: $($_.Name)" -ForegroundColor Cyan
}

$totalOriginalSize = 0
$totalOptimizedSize = 0

# 处理图片
Get-ChildItem -Path $imagesDir -Recurse -File | Where-Object { $_.Extension -in @('.jpg', '.jpeg', '.png') } | ForEach-Object {
    $sourcePath = $_.FullName
    $destPath = $sourcePath.Replace($imagesDir, $optimizedDir)
    $ext = $_.Extension.ToLower()
    $originalSizeKB = [math]::Round($_.Length / 1KB, 2)
    $totalOriginalSize += $_.Length
    
    try {
        $img = [System.Drawing.Image]::FromFile($sourcePath)
        
        # 计算新尺寸 - 最大宽度或高度为1920px（如果当前更大）
        $maxDim = 1920
        $newWidth = $img.Width
        $newHeight = $img.Height
        
        if ($img.Width -gt $maxDim -or $img.Height -gt $maxDim) {
            if ($img.Width -gt $img.Height) {
                $newWidth = $maxDim
                $newHeight = [int]($img.Height * ($maxDim / $img.Width))
            } else {
                $newHeight = $maxDim
                $newWidth = [int]($img.Width * ($maxDim / $img.Height))
            }
        }
        
        # 创建新的位图
        $newImg = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
        $graphics = [System.Drawing.Graphics]::FromImage($newImg)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.DrawImage($img, 0, 0, $newWidth, $newHeight)
        
        # 保存优化后的图片
        if ($ext -in @('.jpg', '.jpeg')) {
            $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
            $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 80L)
            $codecInfo = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
            $newImg.Save($destPath, $codecInfo, $encoderParams)
        } else {
            # PNG保存 - 使用无损压缩
            $newImg.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)
        }
        
        # 清理资源
        $graphics.Dispose()
        $newImg.Dispose()
        $img.Dispose()
        
        # 获取优化后的大小
        $optimizedFile = Get-Item $destPath
        $optimizedSizeKB = [math]::Round($optimizedFile.Length / 1KB, 2)
        $totalOptimizedSize += $optimizedFile.Length
        $savingsPercent = [math]::Round((1 - ($optimizedSizeKB / $originalSizeKB)) * 100, 1)
        
        Write-Host "处理完成: $($_.Name)" -ForegroundColor Green
        Write-Host "  原始尺寸: $($img.Width)x$($img.Height), 大小: ${originalSizeKB}KB"
        Write-Host "  优化尺寸: ${newWidth}x${newHeight}, 大小: ${optimizedSizeKB}KB, 节省: ${savingsPercent}%" -ForegroundColor Cyan
        
    } catch {
        Write-Host "处理失败: $($_.Name) - $($_.Exception.Message)" -ForegroundColor Red
        # 直接复制原始文件
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        $totalOptimizedSize += $_.Length
    }
}

# 显示总计
$totalOriginalMB = [math]::Round($totalOriginalSize / 1MB, 2)
$totalOptimizedMB = [math]::Round($totalOptimizedSize / 1MB, 2)
$totalSavingsPercent = [math]::Round((1 - ($totalOptimizedSize / $totalOriginalSize)) * 100, 1)

Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "图片优化完成！" -ForegroundColor Green
Write-Host "原始总大小: ${totalOriginalMB}MB" -ForegroundColor Cyan
Write-Host "优化后大小: ${totalOptimizedMB}MB" -ForegroundColor Cyan
Write-Host "总共节省: ${totalSavingsPercent}%" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Yellow

Write-Host "现在将用优化后的图片替换原始图片..." -ForegroundColor Yellow

# 备份原始图片
$backupDir = "d:\cv-ye\images_backup"
if (-not (Test-Path $backupDir)) {
    Copy-Item -Path $imagesDir -Destination $backupDir -Recurse -Force
    Write-Host "原始图片已备份到: $backupDir" -ForegroundColor Green
}

# 替换原始图片
Remove-Item -Path "$imagesDir\*" -Recurse -Force
Copy-Item -Path "$optimizedDir\*" -Destination $imagesDir -Recurse -Force

Write-Host "图片替换完成！" -ForegroundColor Green
