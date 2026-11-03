`timescale 1ns / 1ps
// interface : to connect of object with module, module with module
interface adder_interface ();
    logic [7:0] a;
    logic [7:0] b;
    logic       mode;
    logic [7:0] s;
    logic       c;
endinterface

// stimulus for generate variable object
class transaction;
    rand bit [7:0] a;
    rand bit [7:0] b;
    rand bit       mode;
    logic    [7:0] s;
    logic          c;

    // constraint in_range {
    //     a > 128;
    //     b > 250;
    // }

    // constraint in_rage {a inside {[1 : 127]};}

    // constraint mode_distribute{
    //     if(mode == 0)
    //     b inside {0 , 1, 2, 3, 15, 20, 127};
    //     else
    //     b>128;
    // }

    constraint mode_dist2 {
        mode dist {
            0 :/ 90,
            1 :/ 10
        };
    }

    function void debug_print(string name);
        $display("%t: [%s] a= %d, b = %d, mode = %d, s = %d, c = %d", $time,
                 name, a, b, mode, s, c);
    endfunction

endclass

class generator;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;

    event event2gen;

    function new(mailbox#(transaction) gen2drv_mbox, event event2gen);
        this.gen2drv_mbox = gen2drv_mbox;
        this.event2gen    = event2gen;
    endfunction

    task run(int run_count);
        // forever begin
        repeat(run_count) begin
            tr = new;
            // randomize for tr
            tr.randomize();
            gen2drv_mbox.put(tr);
            // $display("%t: gen tr.a = %d, tr.b = %d, tr.mode = %d", $time, tr.a,
            //          tr.b, tr.mode);
            tr.debug_print("GEN");
            // wait event2gen;
            @(event2gen);
        end
        $display("end generator");
    endtask
endclass

class driver;
    transaction tr;  // drive's transaction
    mailbox #(transaction) gen2drv_mbox;
    virtual adder_interface adder_vif;
    event event2gen;  // create event

    function new(mailbox#(transaction) gen2drv_mbox, event event2gen,
                 virtual adder_interface adder_vif);
        this.gen2drv_mbox = gen2drv_mbox;
        this.event2gen    = event2gen;
        this.adder_vif    = adder_vif;
    endfunction

    task run();
        forever begin
            gen2drv_mbox.get(tr);
            // $display("%t: drv tr.a = %d, tr.b = %d, tr.mode = %d", $time, tr.a,
            //          tr.b, tr.mode);
            tr.debug_print("DRV");
            adder_vif.a = tr.a;
            adder_vif.b = tr.b;
            adder_vif.mode = tr.mode;
            #10;
            -> event2gen;
        end
        $display("end drv");
    endtask

endclass


class monitor;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    virtual adder_interface adder_mon_vif;


    function new(mailbox#(transaction) mon2scb_mbox,
                 virtual adder_interface adder_mon_vif);
        this.mon2scb_mbox  = mon2scb_mbox;
        this.adder_mon_vif = adder_mon_vif;
    endfunction

    // task run
    task run();
        forever begin
            #1;
            tr = new;
            tr.a    = adder_mon_vif.a;
            tr.b    = adder_mon_vif.b;
            tr.mode = adder_mon_vif.mode;
            tr.s    = adder_mon_vif.s;
            tr.c    = adder_mon_vif.c;
            tr.debug_print("MON");
            mon2scb_mbox.put(tr);
            #9;
        end
    endtask

endclass

class scoreboard;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;

    function new(mailbox#(transaction) mon2scb_mbox);
        this.mon2scb_mbox = mon2scb_mbox;
    endfunction

    bit [7:0] compare_sum;
    bit compare_carry;
    int pass_cnt = 0;
    int fail_cnt = 0;
    int total_cnt = 0;

    task run();
        forever begin
            mon2scb_mbox.get(tr);
            tr.debug_print("SCB");
            total_cnt++;
            // scoring
            if (!tr.mode) {compare_carry, compare_sum} = tr.a + tr.b;
            else {compare_carry, compare_sum} = tr.a - tr.b;

            if (compare_sum == tr.s && compare_carry == tr.c) begin
                pass_cnt++;
                $display("%t: scb pass ", $time);
            end else begin
                fail_cnt++;
                // $display(
                //     "%t: scb fail, tr.a = %d, tr.b = %d, tr.mode = %d, tr.c = %d, tr.s = %d ",
                //     $time, tr.a, tr.b, tr.mode, tr.c, tr.s);
                $display("%t: scb fail ", $time);
            end
        end
    endtask
endclass

// To management gen and mon task
class environment;
    generator              gen;
    driver                 drv;
    monitor                mon;
    scoreboard             scb;

    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;

    event                  event2gen;

    function new(virtual adder_interface adder_vif);
        gen2drv_mbox = new;
        mon2scb_mbox = new;
        gen = new(gen2drv_mbox, event2gen);
        drv = new(gen2drv_mbox, event2gen, adder_vif);
        mon = new(mon2scb_mbox, adder_vif);
        scb = new(mon2scb_mbox);
    endfunction

    task run();
        fork
            gen.run(20);
            drv.run();
            mon.run();
            scb.run();
        join_any

        #10;
        $display("---------------------");
        $display("** TOTAL test = %4d**", scb.total_cnt);
        $display("** PASS  test = %4d**", scb.pass_cnt);
        $display("** FAIL  test = %4d**", scb.fail_cnt);
        $display("---------------------");
    endtask
endclass

module tb_adder ();

    // adder interface instance
    adder_interface adder_if ();
    // handler for generator
    environment env;

    adder dut (
        .a(adder_if.a),
        .b(adder_if.b),
        .mode(adder_if.mode),
        .s(adder_if.s),
        .c(adder_if.c)
    );

    initial begin
        env = new(adder_if);
        env.run();
        // gen = new(adder_if);
        // mon = new(adder_if);
        // gen.run();
        // mon.run();
        $stop;
    end
endmodule
