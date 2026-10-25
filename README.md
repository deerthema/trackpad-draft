<p align="center">
  <img src="Trackpad Draft/Assets.xcassets/AppIcon.appiconset/icon_128x128.png" width="128" alt="TrackpadDraft Icon">
</p>

<h1 align="center">TrackpadDraft</h1>

<p align="center">
  <a href="#english">English</a> | <a href="#中文">中文</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-14%2B-blue?logo=apple" />
  <img src="https://img.shields.io/badge/Swift-6-orange?logo=swift" />
  <img src="https://img.shields.io/badge/license-MIT-green" />
</p>

---

<h2 id="english"></h2>

<p>Turn your Mac trackpad into an always-on floating scratchpad — above every window, even fullscreen ones.</p>

### ✨ Features

| Feature | Description |
|---------|-------------|
| 🖊️ Trackpad Handwriting | Write with your finger on the trackpad; strokes appear in the floating window in real time |
| 🪟 Always-on-Top | Floats above all apps, including fullscreen ones (YouTube, Keynote, etc.) |
| ✏️ Pen / Eraser | Switch tools instantly; adjust pen width and eraser size |
| 🎨 Pen Colors | Choose black, red, orange, green, blue, or purple; your last choice is remembered |
| 📏 Straight Lines | Hold Shift before drawing to preview a straight line from the first touch to the current point |
| 🖱️ Mouse Mode | Tap the window to toggle cursor visibility for easy repositioning |
| 📐 Pan Canvas | Two-finger scroll to pan the canvas — not limited to window size |
| ⌨️ Global Shortcut | Default `⌥⇧D` to show/hide; fully customizable in Settings |
| ⚙️ Flexible Config | Adjust window size (16:10 ratio lock) and background opacity |
| 🔔 Status Bar Icon | Left-click to toggle window; right-click for menu |

### 📸 Screenshots

> *Floating scratchpad window & Settings panel*

<img width="500" height="auto" alt="image" src="https://github.com/user-attachments/assets/d7841e7c-6dbf-4451-a8d7-72c216338b92" />
<br>
<img width="500" height="auto" alt="image" src="https://github.com/user-attachments/assets/a6092658-5c59-4f4f-9a3e-ac05c0cb0d9a" />


### 🚀 Installation

**Download (Recommended)**

Go to [Releases](../../releases), download the latest `.zip`, unzip, and drag `TrackpadDraft.app` to your **Applications** folder.

> ⚠️ On first launch, macOS may warn "Developer cannot be verified". Go to **System Settings → Privacy & Security** and click **Open Anyway**.

### 🎮 Usage

| Action | Result |
|--------|--------|
| `⌥⇧D` | Show / Hide scratchpad |
| One-finger swipe on trackpad | Draw / Write |
| Two-finger swipe on trackpad | Pan canvas |
| Click scratchpad window | Toggle Mouse Mode ↔ Drawing Mode |
| Hold & drag window | Move window position (Mouse Mode) |
| `Esc` | Hide scratchpad |
| `1` | Switch to Pen |
| `2` | Switch to Eraser |
| Hold `Shift`, then draw | Draw a straight line; lift your finger to finish |
| Color row in the toolbar | Choose ink color (Mouse Mode) |
| `Delete` | Clear canvas |
| Right-click status icon | Open Settings / Quit |

To change ink, click the canvas to show the cursor if needed, then click the Color row and choose a swatch. Click the canvas again to resume drawing. Existing strokes keep their original colors, including after undo; only new strokes use the selected ink.

For math diagrams, hold Shift before placing one finger on the trackpad. The pen previews a straight line at any angle until you lift your finger; releasing Shift early does not bend the stroke. The eraser works anywhere along the line. The labeled toolbar stays opaque and adapts to Light/Dark Mode; in small windows, scroll the toolbar to reach every control.

### ⚙️ Settings

Right-click the status bar icon → **Preferences**:

- **Language**: Chinese / English
- **Window Size**: Width / Height, with optional 16:10 aspect ratio lock
- **Opacity**: Adjust background transparency
- **Global Shortcut**: Customize the hotkey

### 🛠️ Tech Stack

- **Language**: Swift 6
- **Frameworks**: SwiftUI + AppKit
- **Touch Input**: NSTouch / NSEvent trackpad API
- **Dependency**: [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts)
- **Build**: Swift Package Manager

---

<h2 id="中文">中文</h2>

<p>把 Mac 触控板变成随时可用的手写草稿纸 —— 浮动在所有窗口之上，包括全屏应用。</p>

### ✨ 功能特性

| 功能 | 说明 |
|------|------|
| 🖊️ 触控板手写 | 用手指在触控板上书写，内容实时显示在浮动窗口上 |
| 🪟 浮动置顶 | 窗口浮于所有应用之上，包括全屏 App（YouTube、Keynote 等）|
| ✏️ 画笔 / 橡皮 | 一键切换工具，可调节笔粗细和橡皮大小 |
| 🎨 画笔颜色 | 可选黑、红、橙、绿、蓝、紫六种颜色，自动记住上次选择 |
| 📏 直线 | 落指前按住 Shift，从起点到手指当前位置实时预览直线 |
| 🖱️ 鼠标模式 | 单击窗口切换鼠标光标显示，方便调整位置、查看内容 |
| 📐 平移画布 | 双指滑动平移画布，内容不受限于窗口大小 |
| ⌨️ 全局快捷键 | 默认 `⌥⇧D` 呼出 / 隐藏，可在设置中自定义 |
| ⚙️ 自由配置 | 窗口大小（16:10 比例锁定）、透明度均可调节 |
| 🔔 状态栏图标 | 左键呼出窗口，右键显示菜单 |

### 📸 使用截图

> *浮动草稿纸窗口 & 设置界面*

<img width="500" height="auto" alt="image" src="https://github.com/user-attachments/assets/d7841e7c-6dbf-4451-a8d7-72c216338b92" />
<br>
<img width="500" height="auto" alt="image" src="https://github.com/user-attachments/assets/1ca78212-efb0-49ac-92f0-16c9d34901db" />


### 🚀 安装

**直接下载（推荐）**

前往 [Releases](../../releases) 下载最新版 `.zip`，解压后将 `TrackpadDraft.app` 拖入 **访达 → 应用程序** 即可。

> ⚠️ 首次打开时 macOS 会提示「无法验证开发者」，请在 **系统设置 → 隐私与安全性** 中点击「仍然打开」。

### 🎮 使用方法

| 操作 | 效果 |
|------|------|
| `⌥⇧D` | 呼出 / 隐藏草稿纸 |
| 单指滑动触控板 | 在草稿纸上写字 / 画图 |
| 双指滑动触控板 | 平移画布 |
| 单击草稿纸窗口 | 切换「鼠标模式」/ 「写字模式」|
| 按住拖动窗口 | 移动草稿纸位置（鼠标模式下）|
| `Esc` | 隐藏草稿纸 |
| `1` | 切换到画笔 |
| `2` | 切换到橡皮 |
| 按住 `Shift` 再书写 | 绘制直线，抬指完成 |
| 工具栏中的“颜色”一行 | 选择画笔颜色（鼠标模式下）|
| `Delete` | 清空画布 |
| 右键状态栏图标 | 打开设置 / 退出 |

更改颜色时，如光标已隐藏，先单击画布显示光标，再点击“颜色”一行选择所需颜色。再次单击画布即可继续书写。已有笔迹及撤销恢复的笔迹保留原色，只有新笔迹使用所选颜色。

绘制数学图形时，先按住 Shift 再将单指放到触控板上。画笔会实时预览任意角度的直线，抬指完成；提前松开 Shift 也不会使该笔变弯。橡皮擦可擦除线段的任意位置。工具栏带文字标签，保持不透明，并适配浅色和深色模式；窗口较小时可滚动工具栏访问全部控件。

### ⚙️ 设置

右键状态栏图标 → **设置**，可配置：

- **界面语言**：中文 / English
- **窗口大小**：宽度 / 高度，可按 16:10 比例联动调节
- **透明度**：调节草稿纸背景透明度
- **全局快捷键**：自定义呼出热键

### 🛠️ 技术栈

- **语言**：Swift 6
- **UI 框架**：SwiftUI + AppKit
- **触控输入**：NSTouch / NSEvent trackpad API
- **依赖**：[KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts)（全局热键）
- **构建**：Swift Package Manager

---

## Development checks

On macOS with Xcode installed and its license accepted, run `bash scripts/test-pen-colors.sh` to check stroke colors, undo/erasing, and saved color preferences. If Command Line Tools is your default developer directory, prefix the command with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`.

## 📄 License

[MIT License](LICENSE) © 2026 TrackpadDraft
