#!/usr/bin/env python3
import os
import shutil
from datetime import datetime
from PIL import Image

def optimize_images():
    print("=" * 50)
    print("开始优化图片...")
    print("=" * 50)
    
    images_dir = r"d:\cv-ye\images"
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_dir = rf"d:\cv-ye\images_backup_{timestamp}"
    
    # 备份原始图片
    print(f"\n正在备份原始图片到: {backup_dir}")
    shutil.copytree(images_dir, backup_dir)
    print("备份完成！")
    
    total_original = 0
    total_optimized = 0
    processed_count = 0
    
    # 遍历所有图片
    for root, dirs, files in os.walk(images_dir):
        for file in files:
            if file.lower().endswith(('.jpg', '.jpeg', '.png')):
                file_path = os.path.join(root, file)
                original_size = os.path.getsize(file_path)
                total_original += original_size
                
                print(f"\n处理: {file}")
                print(f"  原始大小: {original_size / 1024:.2f} KB")
                
                try:
                    with Image.open(file_path) as img:
                        print(f"  原始尺寸: {img.size[0]}x{img.size[1]}")
                        
                        # 根据目录确定最大尺寸
                        if "profile" in root:
                            max_dim = 600  # 头像小一些
                        else:
                            max_dim = 1600  # 项目和研究图片
                        
                        # 计算新尺寸
                        width, height = img.size
                        if width > max_dim or height > max_dim:
                            if width > height:
                                new_width = max_dim
                                new_height = int(height * (max_dim / width))
                            else:
                                new_height = max_dim
                                new_width = int(width * (max_dim / height))
                            
                            img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
                            print(f"  新尺寸: {new_width}x{new_height}")
                        
                        # 保存优化后的图片
                        ext = os.path.splitext(file)[1].lower()
                        if ext in ('.jpg', '.jpeg'):
                            # JPEG保存，质量75%
                            img.save(file_path, 'JPEG', quality=75, optimize=True)
                        else:
                            # PNG保存
                            img.save(file_path, 'PNG', optimize=True)
                        
                        optimized_size = os.path.getsize(file_path)
                        total_optimized += optimized_size
                        saved = original_size - optimized_size
                        saved_percent = (saved / original_size) * 100
                        
                        print(f"  优化后大小: {optimized_size / 1024:.2f} KB")
                        print(f"  节省: {saved / 1024:.2f} KB ({saved_percent:.1f}%)")
                        processed_count += 1
                        
                except Exception as e:
                    print(f"  处理失败: {e}")
                    # 从备份恢复
                    rel_path = os.path.relpath(file_path, images_dir)
                    backup_path = os.path.join(backup_dir, rel_path)
                    shutil.copy2(backup_path, file_path)
                    total_optimized += original_size
    
    # 打印总结
    print("\n" + "=" * 50)
    print(f"优化完成！共处理 {processed_count} 张图片")
    print(f"原始总大小: {total_original / (1024*1024):.2f} MB")
    print(f"优化后大小: {total_optimized / (1024*1024):.2f} MB")
    total_saved = total_original - total_optimized
    total_saved_percent = (total_saved / total_original) * 100
    print(f"总共节省: {total_saved / (1024*1024):.2f} MB ({total_saved_percent:.1f}%)")
    print("=" * 50)

if __name__ == "__main__":
    optimize_images()
