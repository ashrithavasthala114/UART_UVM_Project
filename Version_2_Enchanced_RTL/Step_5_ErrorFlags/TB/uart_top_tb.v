`timescale 1ns/1ns

module uart_top_tb;

//=====================================================
// Parameters
//=====================================================

parameter DATA_WIDTH  = 8;
parameter STOP_BITS   = 1;

// 0 = No Parity
// 1 = Even Parity
// 2 = Odd Parity
parameter PARITY_MODE = 0;

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

wire parity_error;
wire framing_error;

//=====================================================
// Counters
//=====================================================

integer pass_count;

integer fail_count;

//=====================================================
// DUT
//=====================================================

uart_top
#(
    .DATA_WIDTH(DATA_WIDTH),
    .STOP_BITS(STOP_BITS),
    .PARITY_MODE(PARITY_MODE)
)
DUT
(
    .clk(clk),

    .rst(rst),

    .tx_start(tx_start),

    .data_in(data_in),

    .data_out(data_out),

    .tx_busy(tx_busy),

    .rx_done(rx_done),

    .parity_error(parity_error),
    .framing_error(framing_error)
);

//=====================================================
// Clock Generation
//=====================================================

always #5 clk = ~clk;

//=====================================================
// Waveform Dump
//=====================================================

initial
begin

    $dumpfile("dump.vcd");

    $dumpvars(0, uart_top_tb);

end

//=====================================================
// Reset Task
//=====================================================

task reset_dut;

begin

    rst = 1'b1;

    tx_start = 1'b0;

    data_in = 0;

    repeat(5) @(posedge clk);

    rst = 1'b0;

end

endtask

//=====================================================
// Send Byte Task
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

   if((data_out == tx_data) &&
   (parity_error == 0) &&
   (framing_error == 0))
    begin

        pass_count = pass_count + 1;

        $display("------------------------------------------");
        $display("PASS");
        $display("Time         = %0t",$time);
        $display("Sent         = %h",tx_data);
        $display("Received     = %h",data_out);
        $display("Parity Error  = %b", parity_error);
        $display("Framing Error = %b", framing_error);
        $display("------------------------------------------");

    end

    else
    begin

        fail_count = fail_count + 1;

        $display("------------------------------------------");
        $display("FAIL");
        $display("Time         = %0t",$time);
        $display("Sent         = %h",tx_data);
        $display("Received     = %h",data_out);
        $display("Parity Error  = %b", parity_error);
        $display("Framing Error = %b", framing_error);
        $display("------------------------------------------");

    end

    repeat(10) @(posedge clk);

end

endtask

//=====================================================
// Test Sequence
//=====================================================

initial
begin

    clk = 0;

    rst = 0;

    tx_start = 0;

    data_in = 0;

    pass_count = 0;

    fail_count = 0;

    reset_dut();

    $display("");
    $display("==========================================");
    $display(" UART ERROR FLAGS REGRESSION STARTED ");
    $display("==========================================");
    $display("");

    send_byte(8'h00);

    send_byte(8'h55);

    send_byte(8'hAA);

    send_byte(8'hA5);

    send_byte(8'h3C);

    send_byte(8'hF0);

    send_byte(8'hFF);

        $display("");
    $display("==========================================");
    $display(" ERROR FLAGS REGRESSION SUMMARY ");
    $display("==========================================");

    case(PARITY_MODE)

        0:
            $display("PARITY MODE = NONE");

        1:
            $display("PARITY MODE = EVEN");

        2:
            $display("PARITY MODE = ODD");

        default:
            $display("PARITY MODE = UNKNOWN");

    endcase

    $display("STOP_BITS    = %0d", STOP_BITS);
    $display("PASS COUNT   = %0d", pass_count);
    $display("FAIL COUNT   = %0d", fail_count);

    if(fail_count == 0)
        $display("\nALL TEST CASES PASSED");
    else
        $display("\nSOME TEST CASES FAILED");

    $display("");
    $display("==========================================");

    #100;

    $finish;

end

endmodule