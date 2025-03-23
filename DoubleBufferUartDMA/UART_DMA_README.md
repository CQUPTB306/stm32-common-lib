
# UART DMA 双缓冲通信模块（DoubleBufferUartDMA）

## 📦 简介
本模块基于 STM32 HAL 库实现了一个 **基于 DMA 的 UART 双缓冲（乒乓缓冲）发送机制**，可用于提高串口通信效率并避免阻塞。非常适合用于如 **VOFA+ 上位机波形显示、日志输出、数据打包传输**等场景。

## 🚀 功能特点
- 支持 **非阻塞 DMA 发送**
- 自动 **乒乓缓冲切换（BufferA / BufferB）**
- **正在发送时自动缓存下一帧数据**
- 简洁易用，适配所有 UART DMA 通信场景

## 📁 文件结构
| 文件名 | 说明 |
|--------|------|
| `Uart_DMA.h` | 双缓冲 DMA 模块头文件，定义数据结构与 API |
| `Uart_DMA.c` | 模块实现代码 |

## 🔧 使用方法

### 1️⃣ 引入头文件
```c
#include "Uart_DMA.h"
```

### 2️⃣ 定义结构体实例
```c
DoubleBufferUartDMATypeDef debugUart;
```

### 3️⃣ 初始化模块
```c
DoubleBufferUartDMA_Init(&debugUart);
debugUart.huart = &huart1; // 设置 UART 句柄（例如 huart1）
```

### 4️⃣ 发送数据
```c
uint8_t txData[] = "Hello DMA UART!";
DoubleBufferUartDMA_Send(&debugUart, txData, sizeof(txData));
```

### 5️⃣ 在 UART 发送完成中断中调用回调
```c
void HAL_UART_TxCpltCallback(UART_HandleTypeDef *huart)
{
    if (huart == debugUart.huart)
    {
        TxCallBack_DoubleBufferUartDMA(&debugUart);
    }
}
```

## 📐 结构体说明 `DoubleBufferUartDMATypeDef`
| 字段名 | 说明 |
|--------|------|
| `huart` | UART 句柄 |
| `BufferA / BufferB` | 双缓冲数组（轮换发送） |
| `activeBuffer` | 当前正在发送的缓冲区 |
| `idleBuffer` | 等待发送的数据缓冲区 |
| `idleBufferLength` | 等待发送数据长度 |
| `txBusy` | 是否处于 DMA 发送中 |


```

## 📋 注意事项
- `BUFFER_SIZE` 默认定义为 `128`，可在 `Uart_DMA.h` 修改。
- 如果连续调用发送函数，模块会自动缓存下一帧数据。
- 当前模块不支持并行多帧缓存，如需更复杂发送队列可拓展。

## 🛠 未来可拓展方向
- 支持发送队列 / FIFO 环形缓冲
- 加入发送完成回调函数指针机制
- 支持接收缓冲处理（Rx DMA）

## 💡 适用场景
- VOFA+ 实时波形上传
- 非阻塞日志打印系统
- 串口屏幕通信等高频 UART 任务
