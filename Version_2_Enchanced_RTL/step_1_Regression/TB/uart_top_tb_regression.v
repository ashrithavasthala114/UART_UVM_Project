`timescale 1ns/1ps

module uart_top_tb;

//--------------------------------------------------
// Testbench Signals
//--------------------------------------------------

reg         clk;
reg         rst;
reg         tx_start;
reg  [7:0]  data_in;

wire [7:0]  data_out;
wire        tx_busy;
wire        rx_done;
wire        tx;

//--------------------------------------------------
// Statistics
//--------------------------------------------------

integer pass_count;
integer fail_count;

//--------------------------------------------------
// Instantiate DUT
//--------------------------------------------------

uart_top DUT
(
    .clk(clk),
    .rst(rst),
    .tx_start(tx_start),
    .data_in(data_in),

    .data_out(data_out),
    .tx_busy(tx_busy),
    .rx_done(rx_done),
    .tx(tx)
);

//--------------------------------------------------
// Clock Generation
//--------------------------------------------------

initial
begin
    clk = 0;
    forever #10 clk = ~clk;
end

//--------------------------------------------------
// Waveform Dump
//--------------------------------------------------

initial
begin
    $dumpfile("dump.vcd");
    $dumpvars(0, uart_top_tb);
end

//--------------------------------------------------
// Task : Send One UART Byte
//--------------------------------------------------

task send_byte;

input [7:0] tx_data;

begin

    // Wait until transmitter is free
    wait(tx_busy == 0);

    // Apply data
    data_in = tx_data;

    // Generate one-cycle transmit pulse
    tx_start = 1;
    @(posedge clk);
    tx_start = 0;

    // Wait until receiver finishes
    wait(rx_done == 1);

    // Small delay for stability
    #20;

    // Compare transmitted and received data
    if(data_out == tx_data)
    begin
        pass_count = pass_count + 1;

        $display("------------------------------------------");
        $display("PASS");
        $display("Time      : %0t", $time);
        $display("Sent      : %h", tx_data);
        $display("Received  : %h", data_out);
        $display("------------------------------------------");
    end
    else
    begin
        fail_count = fail_count + 1;

        $display("------------------------------------------");
        $display("FAIL");
        $display("Time      : %0t", $time);
        $display("Sent      : %h", tx_data);
        $display("Received  : %h", data_out);
        $display("------------------------------------------");
    end

    // Wait before next transfer
    #200;

end

endtask

//--------------------------------------------------
// Main Test
//--------------------------------------------------

initial
begin

    //--------------------------------------------------
    // Initialize
    //--------------------------------------------------

    rst        = 1;
    tx_start   = 0;
    data_in    = 8'h00;

    pass_count = 0;
    fail_count = 0;

    //--------------------------------------------------
    // Reset
    //--------------------------------------------------

    #100;

    rst = 0;

    #100;

    $display("");
    $display("==========================================");
    $display(" UART REGRESSION TEST STARTED ");
    $display("==========================================");
    $display("");

    //--------------------------------------------------
    // Regression Test Cases
    //--------------------------------------------------

    send_byte(8'h00);

    send_byte(8'h55);

    send_byte(8'hAA);

    send_byte(8'hA5);

    send_byte(8'h3C);

    send_byte(8'hF0);

    send_byte(8'hFF);

    //--------------------------------------------------
    // Summary
    //--------------------------------------------------

    $display("");
    $display("==========================================");
    $display(" REGRESSION SUMMARY ");
    $display("==========================================");

    $display("PASS COUNT = %0d", pass_count);

    $display("FAIL COUNT = %0d", fail_count);

    if(fail_count == 0)
        $display("ALL TEST CASES PASSED");
    else
        $display("SOME TEST CASES FAILED");

    $display("==========================================");

    #500;

    $finish;

end

endmodule