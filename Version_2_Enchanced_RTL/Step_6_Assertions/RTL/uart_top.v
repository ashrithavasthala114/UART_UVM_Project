module uart_top
#(
    parameter DATA_WIDTH  = 8,
    parameter STOP_BITS   = 1,
    parameter PARITY_MODE = 0
)
(
    input  wire                   clk,
    input  wire                   rst,

    input  wire                   tx_start,
    input  wire [DATA_WIDTH-1:0]  data_in,

    output wire [DATA_WIDTH-1:0]  data_out,

    output wire                   tx_busy,
    output wire                   rx_done,

    output wire                   parity_error,
    output wire                   framing_error
);

wire baud_tick;

wire tx;
wire rx;

// Internal Loopback
assign rx = tx;

//====================================================
// Baud Generator
//====================================================

baud_generator baud_gen
(
    .clk(clk),
    .rst(rst),
    .baud_tick(baud_tick)
);

//====================================================
// UART Transmitter
//====================================================

uart_tx
#(
    .DATA_WIDTH(DATA_WIDTH),
    .STOP_BITS(STOP_BITS),
    .PARITY_MODE(PARITY_MODE)
)
TX
(
    .clk(clk),
    .rst(rst),

    .baud_tick(baud_tick),

    .tx_start(tx_start),

    .data_in(data_in),

    .tx(tx),

    .tx_busy(tx_busy)
);

//====================================================
// UART Receiver
//====================================================

uart_rx
#(
    .DATA_WIDTH(DATA_WIDTH),
    .STOP_BITS(STOP_BITS),
    .PARITY_MODE(PARITY_MODE)
)
RX
(
    .clk(clk),
    .rst(rst),

    .baud_tick(baud_tick),

    .rx(rx),

    .data_out(data_out),

    .rx_done(rx_done),

    .parity_error(parity_error),

    .framing_error(framing_error)
);

endmodule