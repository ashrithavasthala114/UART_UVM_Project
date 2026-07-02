`timescale 1ns/1ps

module uart_top_tb;

//=====================================================
// Parameters
//=====================================================

parameter DATA_WIDTH = 8;
parameter STOP_BITS  = 2;      // Change to 1 or 2 for testing

//=====================================================
// Testbench Signals
//=====================================================

reg clk;
reg rst;

reg tx_start;

reg [DATA_WIDTH-1:0] data_in;

wire [DATA_WIDTH-1:0] data_out;

wire tx_busy;
wire rx_done;

//=====================================================
// Pass / Fail Counters
//=====================================================

integer pass_count;
integer fail_count;

//=====================================================
// Clock Generation
//=====================================================

initial
begin

    clk = 0;

    forever #5 clk = ~clk;      //100 MHz Clock

end;

//=====================================================
// DUT Instantiation
//=====================================================

uart_top
#(
    .DATA_WIDTH(DATA_WIDTH),
    .STOP_BITS(STOP_BITS)
)
DUT
(
    .clk(clk),
    .rst(rst),

    .tx_start(tx_start),

    .data_in(data_in),

    .data_out(data_out),

    .tx_busy(tx_busy),

    .rx_done(rx_done)
);

//=====================================================
// VCD Dump
//=====================================================

initial
begin

    $dumpfile("dump.vcd");

    $dumpvars(0, uart_top_tb);

end;

//=====================================================
// Reset Task
//=====================================================

task reset_dut;

begin

    rst = 1'b1;

    tx_start = 1'b0;

    data_in = 0;

    #100;

    rst = 1'b0;

    #100;

end

endtask

//=====================================================
// Send One UART Byte
//=====================================================

task send_byte;

input [DATA_WIDTH-1:0] tx_data;

begin

    @(posedge clk);

    data_in = tx_data;

    tx_start = 1'b1;

    @(posedge clk);

    tx_start = 1'b0;

    // Wait until receiver finishes
    wait(rx_done);

    @(posedge clk);

end

endtask

//=====================================================
// PASS / FAIL Checker
//=====================================================

task check_data;

input [DATA_WIDTH-1:0] expected_data;

begin

    if(data_out == expected_data)
    begin

        pass_count = pass_count + 1;

        $display("-----------------------------------------");
        $display("PASS");
        $display("Time      = %0t",$time);
        $display("Expected  = %h",expected_data);
        $display("Received  = %h",data_out);
        $display("-----------------------------------------");

    end

    else
    begin

        fail_count = fail_count + 1;

        $display("-----------------------------------------");
        $display("FAIL");
        $display("Time      = %0t",$time);
        $display("Expected  = %h",expected_data);
        $display("Received  = %h",data_out);
        $display("-----------------------------------------");

    end

end

endtask

//=====================================================
// Regression Task
//=====================================================

task run_regression;

begin

    $display("");
    $display("=========================================");
    $display(" UART STOP BIT REGRESSION STARTED ");
    $display("=========================================");
    $display("");

    send_byte(8'h00);
    check_data(8'h00);

    send_byte(8'h55);
    check_data(8'h55);

    send_byte(8'hAA);
    check_data(8'hAA);

    send_byte(8'hA5);
    check_data(8'hA5);

    send_byte(8'h3C);
    check_data(8'h3C);

    send_byte(8'hF0);
    check_data(8'hF0);

    send_byte(8'hFF);
    check_data(8'hFF);

end

endtask

//=====================================================
// Main Test
//=====================================================

initial
begin

    pass_count = 0;

    fail_count = 0;

    reset_dut();

    run_regression();

    $display("");
    $display("=========================================");
    $display(" STOP BIT REGRESSION SUMMARY ");
    $display("=========================================");
    $display("STOP_BITS = %0d", STOP_BITS);
    $display("PASS COUNT = %0d", pass_count);
    $display("FAIL COUNT = %0d", fail_count);

    if(fail_count == 0)
    begin

        $display("");
        $display("ALL TEST CASES PASSED");
        $display("");

    end
    else
    begin

        $display("");
        $display("SOME TEST CASES FAILED");
        $display("");

    end

    $display("=========================================");

    #100;

    $finish;

end

endmodule