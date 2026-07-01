module uart_top
#(
    parameter DATA_WIDTH = 8
)
(
    input wire clk,
    input wire rst,

    input wire tx_start,
    input wire [DATA_WIDTH-1:0] data_in,

    output wire tx_busy,
    output wire rx_done,

    output wire [DATA_WIDTH-1:0] data_out,

    output wire tx
);

//-----------------------------------------------
// Internal Signals
//-----------------------------------------------

wire baud_tick;

//-----------------------------------------------
// Baud Generator
//-----------------------------------------------

baud_generator baud_gen
(
    .clk(clk),
    .rst(rst),
    .baud_tick(baud_tick)
);

//-----------------------------------------------
// UART Transmitter
//-----------------------------------------------

uart_tx
#(
    .DATA_WIDTH(DATA_WIDTH)
)
transmitter
(
    .clk(clk),
    .rst(rst),

    .baud_tick(baud_tick),

    .tx_start(tx_start),

    .data_in(data_in),

    .tx(tx),

    .tx_busy(tx_busy)
);

//-----------------------------------------------
// UART Receiver
//-----------------------------------------------

uart_rx
#(
    .DATA_WIDTH(DATA_WIDTH)
)
receiver
(
    .clk(clk),
    .rst(rst),

    .baud_tick(baud_tick),

    .rx(tx),

    .data_out(data_out),

    .rx_done(rx_done)
);

endmodule