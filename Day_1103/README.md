# Day 11/03: ADC + DMA 2채널 입력으로 x/y 카운트

Nucleo-F411RE의 **ADC1 2채널을 DMA로 연속 변환**해서 x·y 아날로그 입력을 읽고, 입력 크기에 따라 x/y 카운트를 올리거나 내려 **I2C LCD에 표시**하는 과제입니다.
입력이 중앙값에서 멀수록 카운트가 빠르게 바뀌어, 조이스틱처럼 방향과 속도를 함께 조절할 수 있습니다.

🎬 동작 영상: [demo.mp4](demo.mp4)

## System Flow

```
PA4 (ADC1_IN4) ─┐                    ┌─ value[0] → x ─┐
                ├─ ADC1 Scan + DMA ──┤                ├─ 카운트 증감 ─ LCD (I2C 0x27)
PB0 (ADC1_IN8) ─┘   (연속 변환)       └─ value[1] → y ─┘   x:0000 / y:0000
```

1. **ADC + DMA**: ADC1을 Scan + Continuous 모드로 두고 IN4(PA4), IN8(PB0)을 차례로 변환합니다. 결과는 DMA2 Stream0이 CPU 개입 없이 `value[]` 배열에 계속 채웁니다.
2. **변환 완료 콜백**: `HAL_ADC_ConvCpltCallback()`에서 플래그만 세우고, 실제 처리는 메인 루프에서 합니다.
3. **카운트 증감**: 12bit ADC 값(0~4095)을 구간으로 나눠 방향과 속도를 정합니다.
4. **LCD 출력**: 1행에 `x:%04d`, 2행에 `y:%04d`로 현재 카운트를 표시합니다.

## 카운트 규칙

| ADC 값 | x 카운트 | y 카운트 | 갱신 간격 |
|---|---|---|---|
| 0 ~ 1000 | −1 | +1 | 100ms (빠르게) |
| 1001 ~ 1999 | −1 | +1 | 1000ms (천천히) |
| 2000 ~ 2100 | 변화 없음 | 변화 없음 | 중앙 데드존 |
| 2101 ~ 3099 | +1 | −1 | 1000ms (천천히) |
| 3100 ~ 4095 | +1 | −1 | 100ms (빠르게) |

갱신 간격은 `HAL_GetTick()`으로 마지막 갱신 시각과 비교해서 지키므로, `HAL_Delay` 없이 논블로킹으로 동작합니다.

## 하드웨어 · 설정

| 항목 | 설정 |
|---|---|
| ADC1 | 12bit, Scan + Continuous, 2 conversions, Sampling 480 cycles |
| 채널 | Rank 1: IN4 (PA4) → x · Rank 2: IN8 (PB0) → y |
| DMA | DMA2 Stream0, Peripheral → Memory, Circular |
| LCD | 16x2 I2C (PCF8574, 0x27), I2C1 |

## 파일 구성

```
Day_1103/Src
├── main.c                 # ADC1 · DMA · I2C1 초기화 (CubeMX 생성)
├── ap_main/ap_main.c      # 메인 루프, x/y 카운트 로직, LCD 출력
├── driver/cds/cds.c       # ADC DMA 시작, 채널 값 읽기
└── driver/lcd/lcd.c       # I2C LCD 드라이버
```
