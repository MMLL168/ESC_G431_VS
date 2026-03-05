# ESC_SixStep 操作指令與快捷鍵

## 1) 編譯（Debug）

```powershell
cd D:\Work_202506\Git\ESC_SixStep\ST\ESC_SixStep

$env:Path = "C:\ST\STM32CubeIDE_1.18.1\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.14.3.rel1.win32_1.0.100.202602081740\tools\bin;C:\ST\STM32CubeIDE_1.18.1\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.ninja.win32_1.1.100.202601091506\tools\bin;C:\ST\STM32CubeIDE_1.18.1\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.cmake.win32_1.1.100.202601091506\tools\bin;" + $env:Path

cmake --preset Debug
cmake --build --preset Debug -j
```

輸出檔：`build/Debug/ESC_SixStep.elf`

## 2) 燒錄（ST-Link / SWD）

```powershell
& "C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe" -c port=SWD -d ".\build\Debug\ESC_SixStep.elf" -v -rst
```

若連線不穩可改：

```powershell
& "C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe" -c port=SWD mode=UR -d ".\build\Debug\ESC_SixStep.elf" -v -rst
```

## 3) VS Code 除錯快捷鍵（單步）

- `F5`：開始/繼續除錯
- `Shift + F5`：停止除錯
- `Ctrl + Shift + F5`：重新啟動除錯
- `F9`：切換中斷點
- `F10`：Step Over
- `F11`：Step Into
- `Shift + F11`：Step Out

## 4) 建議流程

1. 先 `cmake --build --preset Debug -j`
2. 再燒錄 `ESC_SixStep.elf`
3. 用 `F5` 進入除錯，搭配 `F10/F11` 單步執行
