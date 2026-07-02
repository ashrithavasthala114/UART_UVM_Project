module uart_rx
#(
    parameter DATA_WIDTH = 8,
    parameter STOP_BITS  = 1      //1 or 2
)
(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  baud_tick,

    input  wire                  rx,

    output reg [DATA_WIDTH-1:0]  data_out,
    output reg                   rx_done
);

//=====================================================
// State Encoding
//=====================================================

localparam IDLE  = 2'd0;
localparam START = 2'd1;
localparam DATA  = 2'd2;
localparam STOP  = 2'd3;

//=====================================================
// Registers
//=====================================================

reg [1:0] state;

reg [DATA_WIDTH-1:0] shift_reg;

reg [3:0] bit_count;

reg [1:0] stop_count;

//=====================================================
// UART Receiver FSM
//=====================================================

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin

        state <= IDLE;

        shift_reg <= 0;

        bit_count <= 0;

        stop_count <= 0;

        data_out <= 0;

        rx_done <= 0;

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

            stop_count <= 0;

            if(rx == 1'b0)
                state <= START;

        end

        //------------------------------------------------
        // START BIT
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
        // RECEIVE DATA
        //------------------------------------------------

        DATA:
        begin

            if(baud_tick)
            begin

                shift_reg[bit_count] <= rx;

                if(bit_count == DATA_WIDTH-1)
                    state <= STOP;
                else
                    bit_count <= bit_count + 1;

            end

        end

                //------------------------------------------------
        // STOP BIT(S)
        //------------------------------------------------

        STOP:
        begin

            if(baud_tick)
            begin

                // Stop bit must be HIGH
                if(rx == 1'b1)
                begin

                    stop_count <= stop_count + 1;

                    if(stop_count == (STOP_BITS-1))
                    begin

                        data_out <= shift_reg;

                        rx_done <= 1'b1;

                        stop_count <= 0;

                        state <= IDLE;

                    end

                end

                else
                begin

                    // Invalid stop bit
                    stop_count <= 0;

                    state <= IDLE;

                end

            end

        end

                //------------------------------------------------
        // DEFAULT
        //------------------------------------------------

        default:
        begin

            state <= IDLE;

            bit_count <= 0;

            stop_count <= 0;

            rx_done <= 0;

        end

        //------------------------------------------------

        endcase

    end

end

endmodule