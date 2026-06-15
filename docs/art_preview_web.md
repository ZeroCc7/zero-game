# 美术资源快速预览工具

本工具用于手动生成原图后，快速预览和整理游戏美术资源。

入口脚本：

```text
tools/art_preview_web.py
```

## 启动

```powershell
& 'C:\Users\Z\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' `
  G:\code\zero-game\tools\art_preview_web.py 8765
```

打开：

```text
http://127.0.0.1:8765
```

## 功能

- 上传 AI 生成的原始 PNG/JPG/WebP。
- 配置 rows、cols、cell size、fit scale。
- 自动抠掉 `#FF00FF` 洋红背景。
- 输出透明单帧 PNG。
- 输出 `sheet-transparent.png`。
- 输出普通 GIF。
- 输出 `1-2-3-4-3-2-1` ping-pong GIF。
- 页面内预览 GIF、spritesheet、raw、所有单帧。
- 自动扫描已有资源：
  - `assets/_sprite_runs`
  - `assets/art/units`

## 推荐参数

待机 4 帧：

```text
rows = 2
cols = 2
cell_size = 512 或 768
fit_scale = 0.88
align = bottom
component = largest
shared_scale = 开
pingpong = 开
```

8 帧：

```text
rows = 2
cols = 4
```

正式进游戏优先用：

```text
sheet-transparent.png
frames/*.png
```

GIF 只用于人眼快速预览，不建议作为游戏运行素材。

