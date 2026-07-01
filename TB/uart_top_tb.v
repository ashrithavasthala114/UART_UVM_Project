`timescale 1ns/1ps

module uart_top_tb;

reg clk;
reg rst;
reg tx_start;
reg [7:0] data_in;

wire [7:0] data_out;
wire tx_busy;
wire rx_done;
wire tx;

//--------------------------------------------------
// Instantiate DUT
//--------------------------------------------------

uart_top DUT (

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
// Clock Generation (50 MHz)
//--------------------------------------------------

initial
begin

    clk = 0;

    forever #10 clk = ~clk;

end

//--------------------------------------------------
// Test Sequence
//--------------------------------------------------

initial
begin

    //------------------------------------------------
    // Initialize Signals
    //------------------------------------------------

    rst = 1;

    tx_start = 0;

    data_in = 8'h00;

    //------------------------------------------------
    // Apply Reset
    //------------------------------------------------

    #100;

    rst = 0;

    #100;

    //------------------------------------------------
    // Test Case 1
    //------------------------------------------------

    data_in = 8'hA5;

    tx_start = 1;

    #20;

    tx_start = 0;

    //------------------------------------------------
    // Wait for Reception
    //------------------------------------------------

    wait(rx_done);

    //------------------------------------------------
    // Self Check
    //------------------------------------------------

    if(data_out == data_in)
begin
    $display("------------------------------------");
    $display("TEST CASE 1 PASSED");
    $display("Sent     = %h", data_in);
    $display("Received = %h", data_out);
    $display("------------------------------------");
end
else
begin
    $display("------------------------------------");
    $display("TEST CASE 1 FAILED");
    $display("Sent     = %h", data_in);
    $display("Received = %h", data_out);
    $display("------------------------------------");
end
    #1000;

    $finish;

end

endmodule