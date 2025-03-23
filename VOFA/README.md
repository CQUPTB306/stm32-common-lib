# VOFA+ STM32 通信库

## 介绍

`VOFA` 是一个用于 STM32 与 `VOFA+` 上位机进行通信的库，支持 DMA 接收和 UART 发送数据。 该库提供了两种数据发送格式：

- `JustFloat`：以二进制格式发送浮点数据，适用于 VOFA+ JustFloat 波形显示模式。
- `FireWater`：以字符串格式发送数据，适用于 VOFA+ FireWater 脚本解析。

此外，该库支持变量注册功能，可以通过 `VOFA+` 直接修改 STM32 变量的值。

## 主要功能

- **VOFA\_Init**: 初始化 UART 和 DMA，配置 DMA 空闲中断接收。
- **VOFA\_SendJustFloat**: 发送 `JustFloat` 格式的浮点数据。
- **VOFA\_SendFireWater**: 发送 `FireWater` 格式的字符串数据。
- **VOFA\_RegisterCtrledData**: 注册可被 `VOFA+` 控制的变量。
- **VOFA\_RxCallBack**: 处理 `VOFA+` 发送的控制指令，解析变量并更新。

## 使用方法

### 1. 定义回调函数

```c
void HAL_UART_TxCpltCallback(UART_HandleTypeDef *huart) 
{
  if (huart == VOFA_UART) 
  {
    TxCallBack_DoubleBufferUartDMA(&uartToVOFA);
  }
}
``` # 如果使用双循环dma则定义

```c
void HAL_UARTEx_RxEventCallback(UART_HandleTypeDef *huart, uint16_t Size)
{
  if (huart == VOFA_UART)
  {
    VOFA_RxCallBack();
  }
}
``` # 如果有用vofa+修改变量值的需求则定义


### 2. 初始化 VOFA

在 `main.c` 里调用 `VOFA_Init()` 进行初始化。

```c
VOFA_Init();
```

### 3. 发送 JustFloat 数据

使用 `VOFA_SendJustFloat` 发送多个浮点数据。

```c
float val1 = 1.23, val2 = 4.56;
VOFA_SendJustFloat(2, val1, val2);
```

### 4. 发送 FireWater 数据

使用 `VOFA_SendFireWater` 发送格式化字符串。

```c
VOFA_SendFireWater("Voltage: %f V, Current: %f A", voltage, current);
```

### 5. 注册可控变量

通过 `VOFA_RegisterCtrledData` 允许 `VOFA+` 修改 STM32 变量。

```c
float motor_speed;
VOFA_RegisterCtrledData("speed", &motor_speed);
```

当 `VOFA+` 发送 `speed: 100.0`，STM32 变量 `motor_speed` 会自动更新为 `100.0`。

## 依赖

- STM32 HAL 库
- `Uart_DMA.h` 头文件 (支持 DMA 双缓冲接收)

## 适用平台

该库适用于 STM32F1/F4 系列 MCU，使用 HAL 库进行 UART 及 DMA 操作。

## 许可证

MIT 许可证

