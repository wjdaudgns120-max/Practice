# Practice · Basys3

Digilent Basys3 (Artix-7) FPGA와 Vivado 시뮬레이터로 진행한 Verilog / SystemVerilog 실습 과제입니다. ([← 전체 목차](../../tree/main))

> 같은 내용을 여러 번 실습한 경우 가장 완성도 높은 버전 하나만 남겼고, 포트폴리오 프로젝트에 포함된 실습(UART, FIFO, SR04, DHT11, 시계·스톱워치, RV32I CPU)은 해당 저장소에서 확인할 수 있습니다.
> → [basys3-uart-watch-sensor](https://github.com/wjdaudgns120-max/basys3-uart-watch-sensor) · [rv32i-cpu-project](https://github.com/wjdaudgns120-max/rv32i-cpu-project) · [verificate-fifo-used-uvm](https://github.com/wjdaudgns120-max/verificate-fifo-used-uvm)

## Verilog

| 날짜 | 과제 | 내용 | 핵심 |
|---|---|---|---|
| 07/15 | [gates](Verilog/0715_gates) | AND · NAND · OR · NOR · XOR · XNOR · NOT 게이트를 스위치 입력, LED 출력으로 확인 | `assign`, 제약 파일(XDC) |
| 07/21 | [adder_fnd](Verilog/0721_adder_fnd) | Half Adder → Full Adder → 4bit → 8bit 가산기를 계층적으로 만들고, 결과를 4자리 FND에 표시 | 모듈 계층 구조, 클럭 분주, FND 다이나믹 구동 |
| 07/22 | [mux](Verilog/0722_mux) | 2:1 MUX를 `always @(*)`로 구현 | 조합 회로, `reg` 출력 |
| 07/22 | [counter_10000](Verilog/0722_counter_10000) | 0~9999 Up/Down 카운터. 버튼 L 실행/정지, R 초기화, U 방향 전환. FND로 표시 | 버튼 디바운서, 제어 FSM(STOP/RUN/CLEAR/MODE), 100Hz(10ms) tick 생성 |
| 07/27 | [fsm_moore_mealy](Verilog/0727_fsm_moore_mealy) | `0101` 시퀀스 검출기를 Moore / Mealy 두 방식으로 구현하고 출력 타이밍 비교 | Moore vs Mealy, 상태 레지스터 · 다음 상태 로직 분리 |
| 07/27 | [seq_detector](Verilog/0727_seq_detector) | 같은 비트가 두 번 연속(`00` 또는 `11`) 들어오면 1을 출력하는 Mealy FSM | 5상태 FSM 설계 |
| 08/10 | [register_ram](Verilog/0810_register_ram) | Write Enable이 있는 8bit 레지스터와 1K×8bit 동기식 RAM | 순차 회로, 메모리 배열 추론 |

## SystemVerilog

| 날짜 | 과제 | 내용 | 핵심 |
|---|---|---|---|
| 08/18 | [sv_tb_adder](SystemVerilog/0818_sv_tb_adder) | 8bit 가감산기를 클래스 기반 테스트벤치로 검증 | Transaction · Generator · Driver · Monitor · Scoreboard · Environment, `mailbox`, `event` |
| 08/19 | [sv_register](SystemVerilog/0819_sv_register) | 32bit 레지스터를 클래스 기반 테스트벤치로 검증, `fork-join` 동작 실습 | `always_ff`, `fork-join / join_any / join_none` |
| 08/24 | [sv_oop](SystemVerilog/0824_sv_oop) | SystemVerilog OOP 예제 8개 | 상속과 `super`, `virtual` 함수(정적/동적 바인딩), `static` 멤버, interface · clocking block · modport |
| 09/01 | [dedicated_cpu](SystemVerilog/0901_dedicated_cpu) | 1부터 10까지의 합(55)을 계산하는 전용 CPU. Control Unit(FSM)과 Datapath(MUX · 레지스터 · ALU · 비교기)로 분리 | 제어부/데이터패스 분리 설계, `typedef enum`, `always_comb` |

## 개발 환경

Verilog / SystemVerilog, UVM, Xilinx Vivado, Digilent Basys3 (Artix-7)

> Synopsys VCS로 진행한 UVM 실습(adder · counter · RAM)과 범용 CPU는 [`VCS`](../../tree/VCS) 브랜치에 있습니다.
