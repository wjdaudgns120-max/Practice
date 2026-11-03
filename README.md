# Practice · VCS

Synopsys VCS / Verdi 환경에서 진행한 SystemVerilog · UVM 실습 과제입니다. ([← 전체 목차](../../tree/main))

| 날짜 | 과제 | 내용 | 핵심 |
|---|---|---|---|
| 08/26 | [uvm_adder](0826_uvm_adder) | 8bit 가산기를 UVM 환경으로 검증 (랜덤 시퀀스 100개) | `seq_item`, sequence, driver, monitor(analysis port), scoreboard, agent, env, test, `uvm_config_db` |
| 08/26 | [uvm_counter](0826_uvm_counter) | 3bit 카운터와 8주기 tick 출력을 UVM으로 검증. 일반 시퀀스와 reset 시퀀스를 나눠 실행 | 다중 시퀀스, 카운트값 · tick 별도 PASS/FAIL 집계 |
| 08/31 | [uvm_ram](0831_uvm_ram) | 256×8bit RAM을 UVM으로 검증 (랜덤 트랜잭션 10,000개), 기능 커버리지 측정 | `uvm_subscriber` 기반 coverage, `covergroup` / `coverpoint` (`iff`), 코드 커버리지(`-cm`) |
| 09/02 | [gp_cpu](0902_gp_cpu) | 1~10 합 계산을 4×8bit 레지스터 파일 + ALU 구조의 범용 CPU로 설계 (Basys3 브랜치의 [전용 CPU](../../tree/Basys3/SystemVerilog/0901_dedicated_cpu) 다음 단계) | 레지스터 파일(읽기 포트 2 · 쓰기 포트 1), 7상태 제어 FSM |

## 실행

각 폴더에서 실행합니다.

```bash
make          # 컴파일 (adder는 make run으로 컴파일 + 실행)
make simv     # 시뮬레이션 실행
make verdi    # 파형 확인
make clean
```

## 개발 환경

SystemVerilog, UVM 1.2, Synopsys VCS / Verdi
