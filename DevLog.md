
直接可用指令（PowerShell）

cd d:\Work_202506\Git\ESC_SixStep\ST\ESC_SixStep

# 1) Configure
& "C:\ST\STM32CubeIDE_1.18.1\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.cmake.win32_1.1.100.202601091506\tools\bin\cmake.exe" --preset Debug

# 2) Build
& "C:\ST\STM32CubeIDE_1.18.1\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.cmake.win32_1.1.100.202601091506\tools\bin\cmake.exe" --build --preset Debug -j

# 3) Flash (ST-Link, SWD)
& "C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe" -c port=SWD -d ".\build\Debug\ESC_SixStep.elf" -v -rst

---

## 作業準則（2026-03-05 起生效）

1. 修改前先備份
- 進行任何檔案修改前，先建立時間戳備份檔，避免修改失敗時無法還原。
- 備份命名建議：`原檔名.bak_yyyyMMdd_HHmmss`。
- 同一個原檔案的備份數量上限為 5 個。
- 若超過 5 個，刪除最舊的備份檔，僅保留最新 5 個。

2. 詳細記錄到 `DevLog.md`
- 每次重要操作都要記錄：目的、執行指令、結果、問題與處理方式。
- 若有錯誤，需附上關鍵錯誤訊息與修正結論。
- 每次由我完成檔案修改後，需自動新增一筆「操作紀錄」，不需手動填寫模板。

3. 全部使用繁體中文
- 後續回覆與 `DevLog.md` 紀錄，統一使用繁體中文。

---

## 每次操作紀錄模板

> 使用方式：每次操作請複製以下區塊，完整填寫後追加到本檔案底部。

### 操作紀錄
- 日期：`YYYY-MM-DD HH:mm:ss`
- 目的：
- 指令：
```powershell
# 請填入實際執行指令
```
- 結果：
- 問題：
- 處置：

### 操作紀錄
- 日期：`2026-03-05 19:39:18`
- 目的：將 `DevLog.md` 的模板改為修改後自動填寫，並示範一筆自動紀錄。
- 指令：
```powershell
$ts = Get-Date -Format 'yyyyMMdd_HHmmss'; Copy-Item -Path 'DevLog.md' -Destination ("DevLog.md.bak_" + $ts)
Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
```
- 結果：已完成規則更新，並新增本筆自動填寫紀錄。
- 問題：無。
- 處置：後續每次我完成檔案修改後，將自動追加一筆完整操作紀錄。

### 操作紀錄
- 日期：`2026-03-05 19:50:02`
- 目的：修正 `TIM2_IRQHandler` 重複定義造成的連結失敗，並驗證可成功編譯。
- 指令：
```powershell
$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
Copy-Item 'MCSDK_v6.4.1-Full\MotorControl\MCSDK\MCLib\Any\Inc\esc.h' ("MCSDK_v6.4.1-Full\MotorControl\MCSDK\MCLib\Any\Inc\esc.h.bak_" + $ts)
Copy-Item 'MCSDK_v6.4.1-Full\MotorControl\MCSDK\MCLib\Any\Src\esc.c' ("MCSDK_v6.4.1-Full\MotorControl\MCSDK\MCLib\Any\Src\esc.c.bak_" + $ts)
Copy-Item 'Src\stm32g4xx_mc_it.c' ("Src\stm32g4xx_mc_it.c.bak_" + $ts)

$env:Path = "C:\ST\STM32CubeIDE_1.18.1\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.14.3.rel1.win32_1.0.100.202602081740\tools\bin;C:\ST\STM32CubeIDE_1.18.1\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.ninja.win32_1.1.100.202601091506\tools\bin;C:\ST\STM32CubeIDE_1.18.1\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.cmake.win32_1.1.100.202601091506\tools\bin;" + $env:Path
cmake --build --preset Debug -j
```
- 結果：連結成功，產出 `build/Debug/ESC_SixStep.elf`。
- 問題：`main.c` 仍顯示 14 個 IntelliSense 識別項未定義問題（非實際編譯錯誤）。
- 處置：
	1. 將 `esc.c` 的 `TIM2_IRQHandler` 改為 `esc_tim2_pwm_input_irq()`，避免與系統 IRQ symbol 衝突。
	2. 在 `stm32g4xx_mc_it.c` 的 `PERIOD_COMM_IRQHandler()` 內呼叫 `esc_tim2_pwm_input_irq()`，保留 ESC PWM 量測與 watchdog 更新流程。

### 操作紀錄
- 日期：`2026-03-05 19:51:57`
- 目的：清除 `main.c` 的 14 個 IntelliSense 未定義問題，讓 Problems 與實際編譯一致。
- 指令：
```powershell
# 新增 VS Code 設定檔
# .vscode/settings.json
# .vscode/c_cpp_properties.json

# 驗證問題狀態
get_errors(main.c)
```
- 結果：`Src/main.c` 顯示 `No errors found`，14 個問題已清空。
- 問題：無。
- 處置：
	1. 設定 `C_Cpp.default.compileCommands` 指向 `build/Debug/compile_commands.json`。
	2. 設定 ARM GCC `compilerPath` 與 `windows-gcc-arm` IntelliSense 模式。
	3. 保留 `ms-vscode.cmake-tools` 做為 configuration provider。

### 操作紀錄
- 日期：`2026-03-05 19:55:02`
- 目的：將目前專案推送到新建 GitHub 倉庫 `https://github.com/MMLL168/ESC_G431_VS.git`。
- 指令：
```powershell
Set-Location 'D:\Work_202506\Git\ESC_SixStep\ST\ESC_SixStep'
git init -b main
git remote add origin https://github.com/MMLL168/ESC_G431_VS.git
git add .
git commit -m "Initial project import and build fixes"
git push -u origin main
```
- 結果：推送成功，`main` 分支已建立並追蹤 `origin/main`。
- 問題：無。
- 處置：已完成遠端同步，後續可直接使用 `git push` 更新。

### 操作紀錄
- 日期：`2026-03-05 20:00:14`
- 目的：將專案常用操作指令與除錯快捷鍵整理到 `Readme.md`。
- 指令：
```powershell
Set-Location 'D:\Work_202506\Git\ESC_SixStep\ST\ESC_SixStep'
Copy-Item -Path 'Readme.md' -Destination "Readme.md.bak_yyyyMMdd_HHmmss"
```
- 結果：`Readme.md` 已新增編譯、燒錄、單步除錯快捷鍵與建議操作流程。
- 問題：無。
- 處置：後續若工具路徑變更，請同步更新 `Readme.md` 的指令區段。

### 操作紀錄
- 日期：`2026-03-05 20:08:24`
- 目的：修正 Cortex-Debug 啟動錯誤 `Invalid servertype parameters`。
- 指令：
```powershell
Set-Location 'D:\Work_202506\Git\ESC_SixStep\ST\ESC_SixStep'
Copy-Item -Path '.vscode\launch.json' -Destination ".vscode\launch.json.bak_yyyyMMdd_HHmmss"
```
- 結果：已建立並修正 `.vscode/launch.json`，`servertype` 使用合法值 `stlink`。
- 問題：原設定包含不存在的 `svdFile` 路徑。
- 處置：移除 `svdFile`，保留 `executable`、`serverpath`、`gdbPath` 與 `device/interface` 必要欄位。

### 操作紀錄
- 日期：`2026-03-05 20:16:47`
- 目的：將硬體資訊與專案內對應項目整理到 `Notebook.md`，並加入使用者資訊 `Marlon`。
- 指令：
```powershell
Set-Location 'D:\Work_202506\Git\ESC_SixStep\ST\ESC_SixStep'
Copy-Item -Path 'Notebook.md' -Destination "Notebook.md.bak_yyyyMMdd_HHmmss"
Copy-Item -Path 'DevLog.md' -Destination "DevLog.md.bak_yyyyMMdd_HHmmss"
```
- 結果：`Notebook.md` 已完成硬體摘要與項目對照表，並標示使用者為 Marlon。
- 問題：無。
- 處置：後續若 Workbench 參數有更新，請同步更新 `Notebook.md` 的「關鍵設定來源」區塊。

### 操作紀錄
- 日期：`2026-03-05 20:18:29`
- 目的：新增備份保留規則，當備份檔超過 5 個時自動刪除最舊檔案。
- 指令：
```powershell
Set-Location 'D:\Work_202506\Git\ESC_SixStep\ST\ESC_SixStep'
Copy-Item -Path 'DevLog.md' -Destination "DevLog.md.bak_yyyyMMdd_HHmmss"
```
- 結果：`DevLog.md` 已新增備份數量上限與清理策略。
- 問題：無。
- 處置：後續每次備份後，若同檔備份超過 5 個，刪除最舊備份並保留最新 5 個。

### 操作紀錄
- 日期：`2026-03-05 20:22:56`
- 目的：在 `Notebook.md` 新增所有 Pin Define 對應功能表。
- 指令：
```powershell
Set-Location 'D:\Work_202506\Git\ESC_SixStep\ST\ESC_SixStep'
Copy-Item -Path 'Notebook.md' -Destination "Notebook.md.bak_yyyyMMdd_HHmmss"
$files = Get-ChildItem -Path . -Filter 'Notebook.md.bak_*' | Sort-Object LastWriteTime
if ($files.Count -gt 5) {
	$files | Select-Object -First ($files.Count - 5) | Remove-Item -Force
}
```
- 結果：`Notebook.md` 已新增所有 `*_Pin` 的腳位與功能對照（PWM/BEMF/電壓/溫度/UART/SWD/啟停）。
- 問題：無。
- 處置：後續若 CubeMX/Workbench 重新生碼，需同步更新此對照表。

### 操作紀錄
- 日期：`2026-03-05 20:31:00`
- 目的：將 FMU PWM 輸入 Ton 變數意義與油門百分比換算，補充到 `Notebook.md`。
- 指令：
```powershell
Set-Location 'D:\Work_202506\Git\ESC_SixStep\ST\ESC_SixStep'
Copy-Item -Path 'Notebook.md' -Destination "Notebook.md.bak_yyyyMMdd_HHmmss"
$files = Get-ChildItem -Path . -Filter 'Notebook.md.bak_*' | Sort-Object LastWriteTime
if ($files.Count -gt 5) {
	$files | Select-Object -First ($files.Count - 5) | Remove-Item -Force
}
```
- 結果：`Notebook.md` 已新增 Ton 相關變數白話解釋、油門%公式與即時監看建議。
- 問題：無。
- 處置：後續實作若新增濾波或縮放參數，需同步更新這段說明。

### 操作紀錄
- 日期：`2026-03-05 20:36:16`
- 目的：啟用 Cortex-Debug `liveWatch`，讓變數可即時監看。
- 指令：
```powershell
Set-Location 'D:\Work_202506\Git\ESC_SixStep\ST\ESC_SixStep'
Copy-Item -Path '.vscode\launch.json' -Destination ".vscode\launch.json.bak_yyyyMMdd_HHmmss"
$files = Get-ChildItem -Path '.vscode' -Filter 'launch.json.bak_*' | Sort-Object LastWriteTime
if ($files.Count -gt 5) {
	$files | Select-Object -First ($files.Count - 5) | Remove-Item -Force
}
```
- 結果：`.vscode/launch.json` 已新增 `liveWatch.enabled=true`、`samplesPerSecond=8`。
- 問題：無。
- 處置：重新啟動除錯工作階段後，`CORTEX LIVE WATCH` 應可顯示即時值。

### 操作紀錄
- 日期：`2026-03-05 20:41:01`
- 目的：將 ESC PWM 輸入門檻改為 PX4 `1000~2000us`，並修正為依 `TIM2` 實際捕捉計數基準換算。
- 指令：
```powershell
Set-Location 'D:\Work_202506\Git\ESC_SixStep\ST\ESC_SixStep'
Copy-Item -Path 'Inc\parameters_conversion_g4xx.h' -Destination "Inc\parameters_conversion_g4xx.h.bak_yyyyMMdd_HHmmss"
cmake --build --preset Debug -j
```
- 結果：編譯成功，`ESC_SixStep.elf` 更新完成。
- 問題：原本門檻以 `APB1TIM_FREQ` 直接換算，未納入 `LF_TIMER_PSC`，導致門檻量級錯誤。
- 處置：
	1. 新增 `ESC_CMD_TIM_FREQ` 與 `ESC_US_TO_TICKS(us)` 巨集。
	2. 設定 `ESC_TON_MIN=1000us`、`ESC_TON_MAX=2000us`、`ESC_TON_ARMING=800us`（皆轉為 TIM2 ticks）。
	3. 目前預期值：`Ton_arming≈1347`、`Ton_min≈1683`、`Ton_max≈3366`。

### 操作紀錄
- 日期：`2026-03-05 20:48:50`
- 目的：將馬達參數調整為 MT2204-2300KV（確認 14 極/7 極對）。
- 指令：
```powershell
Set-Location 'D:\Work_202506\Git\ESC_SixStep\ST\ESC_SixStep'
Copy-Item -Path 'Inc\pmsm_motor_parameters.h' -Destination "Inc\pmsm_motor_parameters.h.bak_yyyyMMdd_HHmmss"
Copy-Item -Path 'Inc\drive_parameters.h' -Destination "Inc\drive_parameters.h.bak_yyyyMMdd_HHmmss"
Copy-Item -Path 'ESC_SixStep.wbdef' -Destination "ESC_SixStep.wbdef.bak_yyyyMMdd_HHmmss"
cmake --build --preset Debug -j
```
- 結果：編譯成功，`ESC_SixStep.elf` 更新完成。
- 問題：原本參數仍為舊馬達（1700KV）資料。
- 處置：
	1. `RS` 改為 `0.112`。
	2. `MOTOR_VOLTAGE_CONSTANT` 改為 `0.074`（依 2300KV 估算）。
	3. `MOTOR_MAX_SPEED_RPM` 與 `MAX_APPLICATION_SPEED_RPM` 改為 `26000`。
	4. `NOMINAL_CURRENT_A` 改為 `4.0`（保守值）。
	5. `wbdef` 同步更新馬達名稱與對應關鍵欄位。

### 操作紀錄
- 日期：`2026-03-05 20:51:21`
- 目的：建立 MT2204-2300KV 的安全版啟動曲線（降低前段啟動風險）。
- 指令：
```powershell
Set-Location 'D:\Work_202506\Git\ESC_SixStep\ST\ESC_SixStep'
Copy-Item -Path 'Inc\drive_parameters.h' -Destination "Inc\drive_parameters.h.bak_yyyyMMdd_HHmmss"
cmake --build --preset Debug -j
```
- 結果：編譯成功，`ESC_SixStep.elf` 已更新。
- 問題：無。
- 處置：調整如下。
	1. `PHASE1_DURATION: 500 -> 700 ms`、`PHASE1_VOLTAGE_RMS: 0.8 -> 0.6`
	2. `PHASE2_DURATION: 800 -> 1000 ms`、`PHASE2_FINAL_SPEED: 1500 -> 1200 rpm`、`PHASE2_VOLTAGE_RMS: 1.8 -> 1.2`
	3. `PHASE3_DURATION: 500 -> 900 ms`、`PHASE3_FINAL_SPEED: 1500 -> 2200 rpm`、`PHASE3_VOLTAGE_RMS: 1.8 -> 1.6`
	4. `OBS_MINIMUM_SPEED_RPM: 1500 -> 1200`

### 操作紀錄
- 日期：`2026-03-05 20:57:27`
- 目的：清除 `CMakeLists.txt` 在 Problems 顯示的 2 個編譯器找不到錯誤。
- 指令：
```powershell
Set-Location 'D:\Work_202506\Git\ESC_SixStep\ST\ESC_SixStep'

# 1) 更新 VS Code CMake 設定（PATH + CC/CXX + configureSettings）
#    檔案：.vscode/settings.json

# 2) 讓非 preset 路徑也可載入 toolchain
#    檔案：CMakeLists.txt

# 3) 強化 toolchain 自動尋找 full path
#    檔案：cmake/gcc-arm-none-eabi.cmake

& 'C:\ST\STM32CubeIDE_1.18.1\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.cmake.win32_1.1.100.202601091506\tools\bin\cmake.exe' --preset Debug
```
- 結果：`CMakeLists.txt` Problems 由 2 個錯誤降為 0（`No errors found`）。
- 問題：CMake 語言服務在未使用 preset 的情境下，找不到 `arm-none-eabi-gcc/g++`。
- 處置：
	1. 在 `.vscode/settings.json` 增加 `cmake.configureEnvironment`、`cmake.configureSettings`、`cmake.environment`。
	2. 在 `CMakeLists.txt` 增加 `CMAKE_TOOLCHAIN_FILE` 的預設 fallback。
	3. 在 `cmake/gcc-arm-none-eabi.cmake` 加入 `find_program()`，優先使用 full path，找不到再 fallback 到 `arm-none-eabi-*` 名稱。



