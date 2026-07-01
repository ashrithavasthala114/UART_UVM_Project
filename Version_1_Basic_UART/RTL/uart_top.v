module uart_top(

    input wire clk,
    input wire rst,

    input wire tx_start,

    input wire [7:0] data_in,

    output wire [7:0] data_out,

    output wire tx_busy,

    output wire rx_done,

    output wire tx

);

wire baud_tick;

wire serial_line;

baud_generator baud_gen(

    .clk(clk),

    .rst(rst),

    .baud_tick(baud_tick)

);

uart_tx transmitter(

    .clk(clk),

    .rst(rst),

    .baud_tick(baud_tick),

    .tx_start(tx_start),

    .data_in(data_in),

    .tx(serial_line),

    .tx_busy(tx_busy)

);

uart_rx receiver(

    .clk(clk),

    .rst(rst),

    .baud_tick(baud_tick),

    .rx(serial_line),

    .data_out(data_out),

    .rx_done(rx_done)

);

assign tx = serial_line;

endmodule