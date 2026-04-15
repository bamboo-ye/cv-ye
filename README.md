# 叶晓艺个人简历

这是一个使用 HTML 和 CSS 构建的个人简历网站，用于在 GitHub Pages 上展示个人简历。

## 项目结构

```
├── index.html          # 简历主页
├── styles.css          # 样式文件
├── 叶晓艺简历.pdf       # 简历 PDF 文件
├── .gitignore          # Git 忽略文件
└── README.md           # 项目说明文件
```

## 部署方法

1. **创建 GitHub 仓库**
   - 在 GitHub 上创建一个新的仓库，名称建议为 `username.github.io`（其中 username 是你的 GitHub 用户名）
   - 或者创建任意名称的仓库，后续在仓库设置中启用 GitHub Pages

2. **推送代码**
   ```bash
   # 初始化 Git 仓库（如果尚未初始化）
   git init

   # 添加远程仓库
   git remote add origin https://github.com/username/repository.git

   # 添加文件
   git add .

   # 提交代码
   git commit -m "Initial commit"

   # 推送到 GitHub
   git push -u origin main
   ```

3. **启用 GitHub Pages**
   - 进入仓库设置页面
   - 找到 "GitHub Pages" 部分
   - 在 "Source" 下拉菜单中选择 "main" 分支
   - 点击 "Save" 按钮
   - 等待几分钟，GitHub Pages 会自动构建并部署你的网站

4. **访问网站**
   - 网站地址为：`https://username.github.io`（如果使用 username.github.io 仓库）
   - 或者 `https://username.github.io/repository`（如果使用其他名称的仓库）

## 如何修改内容

1. **修改个人信息**
   - 打开 `index.html` 文件
   - 修改 `<header>` 部分的个人信息，包括姓名、职位、联系方式等

2. **修改简历内容**
   - 打开 `index.html` 文件
   - 修改各个 section 的内容，包括个人简介、教育背景、工作经历、技能证书等

3. **更新简历 PDF**
   - 将新的简历 PDF 文件命名为 `叶晓艺简历.pdf`，替换原文件

4. **修改样式**
   - 打开 `styles.css` 文件
   - 根据需要修改颜色、字体、布局等样式

## 技术栈

- HTML5
- CSS3
- Font Awesome 图标库

## 响应式设计

网站采用响应式设计，适配不同屏幕尺寸：
- 桌面端：完整布局
- 平板端：调整布局，保持良好的阅读体验
- 移动端：垂直布局，优化触摸操作

## 特点

- 现代、专业的设计风格
- 清晰的信息层次结构
- 方便的简历 PDF 下载功能
- 响应式布局，适配各种设备
- 平滑的过渡动画效果

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 联系信息

- 邮箱：[your-email@example.com]
- GitHub：[https://github.com/username]
- LinkedIn：[https://linkedin.com/in/username]