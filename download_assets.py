import urllib.request
import os
import ssl

# 禁用SSL验证（如果需要）
ssl._create_default_https_context = ssl._create_unverified_context

# 创建目录
os.makedirs('assets/css', exist_ok=True)
os.makedirs('assets/webfonts', exist_ok=True)

# 下载Font Awesome CSS
print("下载 Font Awesome CSS...")
fa_css_url = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
fa_css_path = "assets/css/font-awesome.min.css"

try:
    urllib.request.urlretrieve(fa_css_url, fa_css_path)
    print(f"✅ 已下载: {fa_css_path}")
except Exception as e:
    print(f"❌ 下载失败: {e}")

# Font Awesome 需要的字体文件列表
webfonts = [
    "fa-solid-900.woff2",
    "fa-regular-400.woff2",
    "fa-brands-400.woff2"
]

print("\n下载 Font Awesome 字体文件...")
for font in webfonts:
    font_url = f"https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/webfonts/{font}"
    font_path = f"assets/webfonts/{font}"
    try:
        urllib.request.urlretrieve(font_url, font_path)
        print(f"✅ 已下载: {font_path}")
    except Exception as e:
        print(f"❌ 下载失败 {font}: {e}")

print("\n🎉 所有资源下载完成!")
