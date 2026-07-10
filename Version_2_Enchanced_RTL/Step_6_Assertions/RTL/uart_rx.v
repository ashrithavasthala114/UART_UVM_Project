module uart_rx
#(
    parameter DATA_WIDTH  = 8,
    parameter STOP_BITS   = 1,
    parameter PARITY_MODE = 0
)
(
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   baud_tick,
    input  wire                   rx,

    output reg [DATA_WIDTH-1:0]   data_out,
    output reg                    rx_done,
    output reg                    parity_error,
    output reg                    framing_error
);

localparam IDLE   = 3'b000;
localparam START  = 3'b001;
localparam DATA   = 3'b010;
localparam PARITY = 3'b011;
localparam STOP   = 3'b100;

reg [2:0] state;

reg [DATA_WIDTH-1:0] shift_reg;
reg [7:0] bit_count;

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin

        state         <= IDLE;
        shift_reg     <= 0;
        bit_count     <= 0;

        data_out      <= 0;
        rx_done       <= 0;

        parity_error  <= 0;
        framing_error <= 0;

    end

    else
    begin

        rx_done <= 1'b0;

        case(state)

        //------------------------------------------------
        // IDLE
        //------------------------------------------------

        IDLE:
        begin

            framing_error <= 1'b0;

            if(rx == 1'b0)
                state <= START;

        end

        //------------------------------------------------
        // START
        //------------------------------------------------

        START:
        begin

            if(baud_tick)
            begin

                bit_count <= 0;

                state <= DATA;

            end

        end

        //------------------------------------------------
        // DATA
        //------------------------------------------------

        DATA:
        begin

            if(baud_tick)
            begin

                shift_reg[bit_count] <= rx;

                if(bit_count == DATA_WIDTH-1)
                begin

                    if(PARITY_MODE == 0)
                        state <= STOP;
                    else
                        state <= PARITY;

                end
                else
                begin

                    bit_count <= bit_count + 1;

                end

            end

        end

        //------------------------------------------------
        // PARITY
        //------------------------------------------------

        PARITY:
        begin

            if(baud_tick)
            begin

                case(PARITY_MODE)

                    //------------------------------------------------
                    // EVEN PARITY
                    //------------------------------------------------

                    1:
                    begin

                        if(rx == (^shift_reg))
                            parity_error <= 1'b0;
                        else
                            parity_error <= 1'b1;

                    end

                    //------------------------------------------------
                    // ODD PARITY
                    //------------------------------------------------

                    2:
                    begin

                        if(rx == !(^shift_reg))
                            parity_error <= 1'b0;
                        else
                            parity_error <= 1'b1;

                    end

                    //------------------------------------------------

                    default:
                    begin

                        parity_error <= 1'b0;

                    end

                endcase

                state <= STOP;

            end

        end

        //------------------------------------------------
        // STOP
        //------------------------------------------------

        STOP:
        begin

            if(baud_tick)
            begin

                // Framing Error Detection

                if(rx != 1'b1)
                    framing_error <= 1'b1;
                else
                    framing_error <= 1'b0;

                data_out <= shift_reg;

                rx_done <= 1'b1;

                state <= IDLE;

            end

        end

        //------------------------------------------------

        default:
            state <= IDLE;

        endcase

    end

end

endmodule