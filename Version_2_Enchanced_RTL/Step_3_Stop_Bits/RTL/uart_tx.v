module uart_tx
#(
    parameter DATA_WIDTH = 8,
    parameter STOP_BITS  = 1    // 1 or 2
)
(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  baud_tick,
    input  wire                  tx_start,
    input  wire [DATA_WIDTH-1:0] data_in,

    output reg                   tx,
    output reg                   tx_busy
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
// UART Transmitter FSM
//=====================================================

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin

        state <= IDLE;

        tx <= 1'b1;

        tx_busy <= 1'b0;

        shift_reg <= 0;

        bit_count <= 0;

        stop_count <= 0;

    end

    else
    begin

        case(state)

        //------------------------------------------------
        // IDLE
        //------------------------------------------------

        IDLE:
        begin

            tx <= 1'b1;

            tx_busy <= 1'b0;

            stop_count <= 0;

            if(tx_start)
            begin

                shift_reg <= data_in;

                bit_count <= 0;

                tx_busy <= 1'b1;

                state <= START;

            end

        end

        //------------------------------------------------
        // START BIT
        //------------------------------------------------

        START:
        begin

            if(baud_tick)
            begin

                tx <= 1'b0;

                state <= DATA;

            end

        end

        //------------------------------------------------
        // DATA BITS
        //------------------------------------------------

        DATA:
        begin

            if(baud_tick)
            begin

                tx <= shift_reg[0];

                shift_reg <= shift_reg >> 1;

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

                // UART stop bit is always logic HIGH
                tx <= 1'b1;

                // Count transmitted stop bits
                stop_count <= stop_count + 1;

                // Required number of stop bits transmitted?
                if(stop_count == (STOP_BITS - 1))
                begin

                    tx_busy <= 1'b0;

                    state <= IDLE;

                    stop_count <= 0;

                end

            end

        end

                //------------------------------------------------
        // DEFAULT STATE
        //------------------------------------------------

        default:
        begin

            state <= IDLE;

            tx <= 1'b1;

            tx_busy <= 1'b0;

            stop_count <= 0;

        end

        //------------------------------------------------

        endcase

    end

end

endmodule