# Notebook：硬體資訊與專案對應

## 使用者資訊
- 使用者：Marlon

## 硬體資訊摘要
- 控制板：`B-G431B-ESC1`
- MCU：`STM32G431CB`（`UFQFPN48`）
- 控制方式：`SIX_STEP`（六步方波）
- 專案來源：`STM32 Motor Control Workbench / MCSDK`
- MCSDK 版本：`6.4.1`
- CubeMX 版本：`6.17.0`
- 系統時脈：`170 MHz`
- 外部時脈：`HSE 8 MHz`
- PWM：`TIM1`，`20 kHz`
- 速度回授：`Sensorless ADC (BEMF)`
- 低頻計時器：`TIM2`
- 通訊介面：`USART2 + DMA1`（MCP/ASPEP）

## 關鍵設定來源（檔案）

### 1. 專案/板子/控制模式
- `ESC_SixStep.ioc`
	- `MotorControl.BOARD=B-G431B-ESC1`
	- `MotorControl.DRIVE_TYPE=SIX_STEP`
	- `MotorControl.MCU=STM32G431CB`
	- `MotorControl.CLOCK_FREQUENCY=CPU_CLK_170_MHZ`
- `ESC_SixStep.wbdef`
	- `BOARD=B-G431B-ESC1`
	- `M1_DRIVE_TYPE=SIX_STEP`
	- `MCU=STM32G431CB`
	- `MC_WORKBENCH_VERSION=6.4.1`

### 2. 馬達功率級與PWM
- `Src/tim.c`
	- `MX_TIM1_Init()`：三相 PWM 主要計時器
	- `MX_TIM2_Init()`：ESC PWM 輸入量測/低頻流程
- `Inc/parameters_conversion_g4xx.h`
	- `PERIOD_COMM_IRQHandler -> TIM2_IRQHandler` 映射

### 3. 六步控制核心
- `Src/mc_tasks_sixstep.c`：六步控制主要任務
- `Src/pwmc_sixstep.c`：六步 PWM 切相/驅動
- `Src/bemf_ADC_fdbk_sixstep.c`：BEMF 量測與零交越偵測
- `Src/speed_duty_ctrl.c`：速度/占空比控制

### 4. 量測與保護
- `Src/adc.c`：ADC1/ADC2 初始化與通道配置
- `Inc/drive_parameters.h`：驅動參數
- `Inc/power_stage_parameters.h`：功率板參數
- `Src/mc_parameters.c`：參數實作與組合

### 5. 中斷與流程
- `Src/stm32g4xx_it.c`：STM32 基本 IRQ 入口
- `Src/stm32g4xx_mc_it.c`：Motor Control 相關 IRQ 實作
- `MCSDK_v6.4.1-Full/MotorControl/MCSDK/MCLib/Any/Src/esc.c`：ESC PWM 輸入處理

### 6. 建置與輸出
- `CMakePresets.json`：`Debug/Release` preset
- `cmake/gcc-arm-none-eabi.cmake`：ARM GCC 工具鏈
- `CMakeLists.txt`：主專案入口
- 輸出檔：`build/Debug/ESC_SixStep.elf`

## 專案內「項目 -> 檔案」快速對照
| 項目 | 對應檔案 |
|---|---|
| 板卡型號與MCU設定 | `ESC_SixStep.ioc`, `ESC_SixStep.wbdef` |
| 六步控制狀態機 | `Src/mc_tasks_sixstep.c` |
| 切相/PWM 輸出 | `Src/pwmc_sixstep.c`, `Src/tim.c` |
| BEMF 偵測 | `Src/bemf_ADC_fdbk_sixstep.c`, `Src/adc.c` |
| 速度與占空比 | `Src/speed_duty_ctrl.c` |
| IRQ 流程 | `Src/stm32g4xx_it.c`, `Src/stm32g4xx_mc_it.c`, `Inc/parameters_conversion_g4xx.h` |
| ESC 輸入脈寬解析 | `MCSDK_v6.4.1-Full/.../esc.c` |
| 編譯與連結 | `CMakeLists.txt`, `CMakePresets.json`, `cmake/gcc-arm-none-eabi.cmake` |

## 所有 Pin Define 對應功能

來源：`Inc/main.h`（Pin Define）、`Src/adc.c`、`Src/tim.c`、`Src/usart.c`、`Src/gpio.c`

| Pin Define | 實體腳位 | 對應功能 | 週邊/通道 |
|---|---|---|---|
| `M1_PWM_UL_Pin` | `PC13` | U 相低側 PWM | `TIM1_CH1N` |
| `M1_PWM_WL_Pin` | `PB15` | W 相低側 PWM | `TIM1_CH3N` |
| `M1_PWM_UH_Pin` | `PA8` | U 相高側 PWM | `TIM1_CH1` |
| `M1_PWM_VH_Pin` | `PA9` | V 相高側 PWM | `TIM1_CH2` |
| `M1_PWM_WH_Pin` | `PA10` | W 相高側 PWM | `TIM1_CH3` |
| `M1_PWM_VL_Pin` | `PA12` | V 相低側 PWM | `TIM1_CH2N` |
| `M1_PWM_INPUT_Pin` | `PA15` | ESC 命令輸入脈寬量測 | `TIM2_CH1` |
| `M1_BUS_VOLTAGE_Pin` | `PA0` | 母線電壓量測 | `ADC1_IN1` |
| `M1_BEMF_U_Pin` | `PA4` | U 相 BEMF 量測 | `ADC2_IN17` |
| `M1_BEMF_V_Pin` | `PC4` | V 相 BEMF 量測 | `ADC2_IN5` |
| `M1_BEMF_W_Pin` | `PB11` | W 相 BEMF 量測 | `ADC1_IN14` |
| `M1_TEMPERATURE_Pin` | `PB14` | 溫度量測 | `ADC1_IN5` |
| `UART_TX_Pin` | `PB3` | MCU 通訊 TX | `USART2_TX` |
| `UART_RX_Pin` | `PB4` | MCU 通訊 RX | `USART2_RX` |
| `Start_Stop_Pin` | `PC10` | 啟停按鍵中斷輸入 | `EXTI15_10`（下降沿） |
| `M1_BEMF_DIVIDER_Pin` | `PB5` | BEMF 分壓控制輸出 | `GPIO Output` |
| `TMS_Pin` | `PA13` | SWD 除錯資料線 | `SYS_JTMS-SWDIO` |
| `TCK_Pin` | `PA14` | SWD 除錯時脈線 | `SYS_JTCK-SWCLK` |

### 相關中斷 Define
- `Start_Stop_EXTI_IRQn` -> `EXTI15_10_IRQn`（對應 `Start_Stop_Pin`）

## Six-Step BEMF 偵測：ADC 與比較器優缺點

### 目前專案採用
- 目前為 `SENSORLESS_ADC`（BEMF 走 ADC 採樣與數位處理）。

### 方案對照
| 面向 | ADC 偵測 BEMF | 比較器偵測 BEMF |
|---|---|---|
| 反應速度 | 中等，受採樣點/中斷頻率影響 | 快，硬體 crossing 反應延遲低 |
| 抗噪能力 | 可透過數位濾波、平均、門檻補償調整 | 對尖峰較敏感，需良好 blanking/hysteresis |
| 可調性 | 高，可調採樣時點、閾值、濾波 | 中，主要靠硬體與少量比較器參數 |
| 低速穩定性 | 通常較好，可做演算法補償 | 容易受雜訊與開關干擾影響 |
| 高速極限 | 受 ADC 取樣與 CPU 負載限制 | 通常較有優勢 |
| MCU 資源負載 | 較高（ADC + 計算） | 較低（硬體事件導向） |
| 實作複雜度 | 中等（參數多但流程清楚） | 中高（硬體路由、blanking、中斷整合） |
| 除錯可視性 | 高（可看 ADC 數值與中間變數） | 較低（多為事件邏輯） |

### 何時選 ADC
1. 需要較高可調性與可觀測性。
2. 需要在低中速區域優先穩定。
3. 已有成熟 MCSDK ADC 方案，想先快速收斂。

### 何時考慮比較器
1. 追求高速段更低延遲 commutation。
2. MCU 計算資源吃緊，想減輕 ADC/CPU 負載。
3. 願意投入較多硬體與中斷防噪設計（blanking/hysteresis/佈線）。

### 本專案建議
1. 先把 ADC 方案調穩（目前路線）。
2. 若後續在高速段出現明顯偵測延遲瓶頸，再評估切比較器方案。

## FMU PWM 輸入（Ton）白話說明

### 變數意義
- `ESC_M1.Ton_value`
	- 目前量到的 PWM 高電位時間（可視為當下油門位置）。
	- 此值在 TIM2 IRQ 內更新，會隨外部 FMU 輸入即時變化。

- `ESC_ParamsM1.Ton_arming`
	- 解鎖門檻（低油門區），必須先達到/停留在此區，系統才會進入可運轉狀態。

- `ESC_ParamsM1.Ton_min`
	- 最小有效油門門檻；低於此值通常視為停轉或不輸出速度命令。

- `ESC_ParamsM1.Ton_max`
	- 最大有效油門門檻；高於此值視為滿油門上限。

### 油門百分比換算（白話）
- 當 `Ton_value` 位於 `Ton_min ~ Ton_max` 範圍：
	- `Throttle(%) = (Ton_value - Ton_min) / (Ton_max - Ton_min) * 100`
- `Ton_value < Ton_min`：近似 0%
- `Ton_value > Ton_max`：近似 100%

### 即時監看建議（Debug Watch）
1. `ESC_M1.Ton_value`
2. `ESC_M1.watchdog_counter`
3. `ESC_ParamsM1.Ton_arming`
4. `ESC_ParamsM1.Ton_min`
5. `ESC_ParamsM1.Ton_max`

## 測試流程總結（目前建議順序）

### 階段 A：Motor Pilot 基礎驗證（先做）
1. 先確認 UART 連線成功（可讀參數、可看到即時量測）。
2. 確認系統狀態可回到 `IDLE`，且故障可 `Ack Faults` 清除。
3. 以低風險條件檢查基本啟停行為是否正常（不做激烈拉轉）。
4. 確認沒有過流、過壓、過溫、失步等異常警示。

### 階段 B：PA15 外部 PWM 驗證（下一步）
1. 階段 A 都正常後，再切入 `PA15` 外部命令測試。
2. 由外部訊號源（FMU/接收機/訊號產生器）輸入 PWM 到 `PA15`。
3. 確認 `ESC_M1.Ton_value` 會隨輸入脈寬變化。
4. 確認油門行為符合 `Ton_min ~ Ton_max` 的比例變化。

## 下一步流程：PA15 外部 PWM 驗證清單（5 分鐘版）

### 1) 接線與訊號規格
1. 命令腳位：`PA15`（`M1_PWM_INPUT_Pin`）。
2. 訊號電平：`3.3V TTL`。
3. 共地：外部訊號源 GND 與 ESC GND 必須共地。
4. 建議頻率：`400 Hz`（也可先用 `50~400 Hz` 驗證）。

### 2) 脈寬設定（本專案）
1. `ESC_TON_ARMING = 800 us`
2. `ESC_TON_MIN = 1000 us`
3. `ESC_TON_MAX = 2000 us`

### 3) 驗證步驟
1. 上電後先輸入 `800 us`，保持 1~2 秒，確認可解鎖。
2. 調到 `1000 us`，確認維持低油門/停轉邊界。
3. 緩慢增加：`1100 -> 1200 -> 1300 -> 1500 us`，每段停 2~3 秒。
4. 觀察 `ESC_M1.Ton_value`、`watchdog_counter`、轉速反應是否連續。
5. 回到 `1000 us`，確認可平穩降回低油門。

### 4) 異常時處置
1. 若抖動、異音或故障燈，立刻降回 `1000 us` 或斷電。
2. 檢查共地、訊號振幅、頻率是否正確。
3. 若 `Ton_value` 不動，優先檢查是否接錯腳位（必須是 `PA15`）。

## 馬達啟動異常分析交接筆記（可貼到新 AI 聊天室）

### A. 問題現象（時間序）
1. 初期：馬達吸住不轉，電流可上升，Motor Pilot 常見 `FAULT_OVER` + `Speed Feedback`。
2. 中期：可起轉但僅 1~2 圈後停，故障仍以 `Speed Feedback` 為主。
3. 近期：經參數調整後可轉更久，`Speed Feedback` 不一定立即出現，但轉速呈 `0~5xxx RPM` 大幅循環擺動。
4. 示波器曾見：三相有切換，但波形包絡週期性放大/縮小，符合速度估測不穩與控制切換震盪特徵。

### B. 已確認重點
1. 專案為 `STM32G431 + MCSDK 6.4.1 + SIX_STEP + Sensorless ADC(BEMF)`。
2. `TIM2` 同時是 six-step 低頻節拍與先前 ESC 輸入路徑關鍵資源，已做 pure Motor Pilot 路徑隔離。
3. 速度故障觸發點在 `Src/mc_tasks_sixstep.c`：`RUN` 內 `IsSpeedReliable == false` 時會走 `MC_SPEED_FDBK`。
4. `Openloop` 設定會改變 `RUN` 期控制路徑（Duty/Open-loop vs Speed-loop），對穩速行為影響很大。

### C. 這輪已修改（重點）
1. `Src/mc_app_hooks.c`
	- pure Motor Pilot 下關閉 ESC 路徑。
	- 加入一次性自動啟動診斷（上電後自動下 `1800rpm/3000ms` + Start），用於排除 UI 指令因素。
2. `Src/stm32g4xx_mc_it.c`
	- pure Motor Pilot 下不再呼叫 `esc_tim2_pwm_input_irq()`，避免 TIM2 中斷路徑干擾。
3. `Src/tim.c`
	- `TIM2` 由輸入捕捉模式改為 six-step 所需的定時比較模式（內部節拍）。
4. `Inc/drive_parameters.h`
	- 放寬 speed feedback 相關容忍（`M1_SS_MEAS_ERRORS_BEFORE_FAULTS`, `M1_MAX_CONSECUTIVE_BEMF_ERRORS`, `OBS_MINIMUM_SPEED_RPM`）。
	- 調整 rev-up phase（時間/目標速/電壓），強化起步 BEMF 可偵測性。
	- 曾降低速度環 aggressiveness（降低 `SPEED_LOOP_FREQUENCY_HZ`、降低 `PID_SPEED_KP_DEFAULT`、增大 `BEMF_AVERAGING_FIFO_DEPTH`）。
5. `Src/mc_config.c`
	- 將 `.Openloop` 設為 `false`（改回偏閉環速度路徑）。

### D. 目前最可能根因排序
1. `BEMF` 估測在低速到閉環切換區不穩定，速度可靠度判定偶發失真。
2. `Openloop/Speed-loop` 路徑切換與參數組合不匹配，導致週期性 hunting。
3. `PID` 參數次要但重要：在估測噪聲存在時可能放大循環擺動。
4. 硬體端次要風險：量測/接地/驅動邊界條件在特定 duty 區間造成 BEMF 判斷惡化。

### E. 新聊天室建議先問的 5 個問題
1. six-step sensorless 在本馬達（BRS2804-1700）下，`rev-up -> loop closed` 的最佳切換條件該怎麼定？
2. `Openloop=false` 後，`RUN` 期是否還有其他路徑會強制回 `MCM_DUTY_MODE`？
3. 目前 `BEMF` 門檻（PWM/High/Low）是否過寬或過窄，如何系統化掃描？
4. `PID_SPEED_KP/KI` 與 `SPEED_LOOP_FREQUENCY_HZ` 的配對整定流程（先固定估測濾波再調 PI）最佳做法？
5. 如何在不大改架構下，增加最少量 debug 變數就能判斷是「估測錯」還是「控制過衝」？

### F. 建議帶去新聊天室的最小資料包
1. `Src/mc_tasks_sixstep.c`（`START` / `RUN` / `IsSpeedReliable` 區段）。
2. `Src/bemf_ADC_fdbk_sixstep.c`（`BADC_CalcAvrgMecSpeedUnit`, `BADC_CheckDetectionErrors`）。
3. `Src/mc_config.c`（`OpenLoopSixstepCtrl_Handle_t`、`RevUpControlM1`）。
4. `Inc/drive_parameters.h`（BEMF + rev-up + speed loop 參數）。
5. 最新示波器圖（U/V/W 三相）與 Motor Pilot 畫面（含 fault 狀態）。

### G. 目前狀態一句話
已從「完全不轉」推進到「可起轉與切相」，現階段主戰場是「閉環切換區的 BEMF 可靠度 + 速度環穩定度」收斂。



