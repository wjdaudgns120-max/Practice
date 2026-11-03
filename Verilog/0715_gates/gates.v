// '`' wave accent
`timescale 1ns / 1ps //시뮬레이터 해석
//내부 module은 top module을 통해서 i/o가 입출력 되야한다.
// top module: 외부와 통신할 수 있는 I/O를 갖는 module

module gates(
    input a,
    input b,
    output y0,
    output y1,
    output y2,
    output y3,
    output y4,
    output y5,
    output y6
    );
    // assign 연속 할당(연결이라 동시 수행, 살행 순서 X)
    assign y0 = a & b; //AND
    assign y1 = ~(a & b); //NAND
    assign y2 = a | b; //OR
    assign y3 = ~(a | b); //NOR
    assign y4 = a ^ b; //XOR
    assign y5 = ~(a ^ b); //XNOR
    assign y6 = ~b; //NOT

endmodule
