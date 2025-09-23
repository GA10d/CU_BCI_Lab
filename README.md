# README for HW_1_zg2567.docx  
**Zhewen Guo (UNI: zg2567)**

## 项目概述 / Project Overview
本作业在 MATLAB 中对 EEG（脑电图）数据进行分析，包括：
1. 加载并查看数据结构  
2. 绘制原始信号  
3. 去除直流分量  
4. 设计并应用 Alpha 与 Beta 频带滤波器  
5. 计算并比较不同条件下的频带功率  

This homework analyzes EEG (Electroencephalogram) data in MATLAB, including:
1. Loading and inspecting the data structure  
2. Plotting raw signals  
3. Removing DC components  
4. Designing and applying Alpha and Beta band-pass filters  
5. Calculating and comparing band power under different conditions  

---

## 数据结构 / Data Structure
数据存储在 `P_C_S` 结构体中，关键字段：
- `data`: 信号数据，维度为 **1 × 49312 × 4**（1 次实验 × 采样点数 × 通道数）  
- `samplingfrequency`: 采样频率（用于时间轴构建）  
- `channels`: 通道编号  
- `channelname`: 通道名称  

The data is stored in a MATLAB struct `P_C_S`, with key fields:
- `data`: Signal data with dimensions **1 × 49312 × 4** (1 trial × number of samples × number of channels)  
- `samplingfrequency`: Sampling rate (used to construct time axis)  
- `channels`: Channel indices  
- `channelname`: Channel names  

---

## 任务实现 / Task Implementation

### 1. 绘制原始 EEG 信号  
使用 `plot(time, data)` 绘制每个通道的原始信号波形。

### 2. 去除直流分量  
通过减去每个通道信号的均值实现，消除信号基线偏移。  
实验 1 数据已通过 0.5–60 Hz 带通滤波，因此使用实验 2-2 数据演示效果。

### 3. 频带滤波  
使用 FFT 将信号转换到频域，保留目标频带并进行逆变换重构信号：
- **Alpha 波**: 8–13 Hz  
- **Beta 波**: 14–32 Hz  

### 4. 功率计算  
使用公式：
\[
P = \frac{\sum |x[n]|^2}{N}
\]
计算每个频带在 6 种条件（静坐、眨眼、眼球转动、咀嚼、颈部紧张、触摸电极）下的平均功率。

---

## 结果分析 / Results Analysis

### Alpha 波（8–13 Hz）
- 所有条件下 Alpha 波成分较弱  
- 原因：Alpha 波在闭眼放松时最强，睁眼或注意力集中时减弱；实验环境可能存在噪声干扰

### Beta 波（14–32 Hz）
- 在咀嚼和颈部紧张状态下最为明显  
- 原因：Beta 波与专注、活跃思维及肌肉控制相关

### 功率比较（稳定段信号）
| Condition    | Alpha Power | Beta Power |
|--------------|-------------|------------|
| Sitting      | 0.000007    | 0.000129   |
| Blinking     | 0.000002    | 0.000154   |
| Rolling      | 0.000203    | 0.000610   |
| Chewing      | 0.000247    | 0.037455   |
| Tensing      | 0.000006    | 0.011831   |
| Touching     | 0.000111    | 0.018463   |

---

## 代码附录 / Code Appendices
- **附录 2**: 绘制原始 EEG 信号  
- **附录 3**: 去除 DC 分量  
- **附录 4**: FFT 带通滤波函数  

---
