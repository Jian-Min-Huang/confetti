# Confetti.app — 設計規格書

## 1. 簡介

Confetti.app 是一個 macOS 命令列原生應用，以透明覆蓋層的形式在全螢幕顯示粒子動畫。通過 Shell Hooks 觸發，為 AI Agent 任務完成提供視覺反饋效果。

## 2. 需求

### 2.1 功能需求

| ID    | 需求                                                         |
| ----- | ------------------------------------------------------------ |
| FR-1  | 透過 `open Confetti.app` 啟動，無需額外設定                  |
| FR-2  | 不顯示 Dock 圖示，不顯示選單列                               |
| FR-3  | 在所有視窗之上顯示全螢幕透明覆蓋層                           |
| FR-4  | 覆蓋層必須能穿透點擊——所有滑鼠事件傳遞至底層視窗             |
| FR-5  | 支援多螢幕——每個螢幕各自播放動畫                             |
| FR-6  | 使用多種 Emoji 作為動畫粒子，預設為 `🎉⚽❤️`                 |
| FR-7  | 支援多種特效樣式：`confetti`、`falling-leaves`、`fireworks`  |
| FR-8  | 接受 `--style <name>` 參數選擇特效樣式                       |
| FR-9  | 接受 `--emojis <list>` 參數自訂粒子 Emoji                    |
| FR-10 | 接受 `--density <level>` 參數控制粒子密度（low/medium/high） |
| FR-11 | 接受 `--speed <multiplier>` 參數調整動畫速度                 |
| FR-12 | 接受 `--duration <seconds>` 參數控制特效播放時間             |
| FR-13 | `--style` 預設值為 `confetti`                                |
| FR-14 | `--emojis` 預設值為 `🎉⚽❤️`                                 |
| FR-15 | `--density` 預設值為 `medium`                                |
| FR-16 | `--speed` 預設值為 `1.0`                                     |
| FR-17 | `--duration` 預設值為 `5` 秒                                 |
| FR-18 | 動畫結束後自動終止                                           |
| FR-19 | 支援按 `Esc` 鍵提前結束動畫                                  |

### 2.2 非功能需求

| ID    | 需求                                   |
| ----- | -------------------------------------- |
| NFR-1 | macOS 13（Ventura）或更新版本          |
| NFR-2 | 零外部依賴                             |
| NFR-3 | GPU 加速渲染，確保動畫流暢             |
| NFR-4 | 自包含二進位——不需要圖片資源檔案       |
| NFR-5 | 完全從命令列建置（不需要 Xcode 專案）  |
| NFR-6 | 持續擴充特效的架構設計                 |
| NFR-7 | CPU 使用率低於 5%（GPU 加速下）        |
| NFR-8 | 記憶體佔用低於 50MB                    |
| NFR-9 | 動畫幀率穩定維持在 60 FPS（4K 解析度） |
