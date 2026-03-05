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



