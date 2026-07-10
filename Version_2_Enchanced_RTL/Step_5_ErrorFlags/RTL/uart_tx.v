module uart_tx
#(
    parameter DATA_WIDTH  = 8,
    parameter STOP_BITS   = 1,

    // 0 = No Parity
    // 1 = Even Parity
    // 2 = Odd Parity
    parameter PARITY_MODE = 0
)
(
    input  wire                   clk,
    input  wire                   rst,

    input  wire                   baud_tick,

    input  wire                   tx_start,

    input  wire [DATA_WIDTH-1:0]  data_in,

    output reg                    tx,

    output reg                    tx_busy
);

//=====================================================
// State Encoding
//=====================================================

localparam IDLE   = 3'd0;
localparam START  = 3'd1;
localparam DATA   = 3'd2;
localparam PARITY = 3'd3;
localparam STOP   = 3'd4;

//=====================================================
// Registers
//=====================================================

reg [2:0] state;

reg [DATA_WIDTH-1:0] shift_reg;

reg [$clog2(DATA_WIDTH):0] bit_count;

reg [$clog2(STOP_BITS+1):0] stop_count;

// Calculated parity bit
reg parity_bit;

//=====================================================
// UART Transmitter
//=====================================================

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin

        state      <= IDLE;

        tx         <= 1'b1;

        tx_busy    <= 1'b0;

        shift_reg  <= 0;

        bit_count  <= 0;

        stop_count <= 0;

        parity_bit <= 0;

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

            tx_busy <= 0;

            stop_count <= 0;

            if(tx_start)
            begin

                shift_reg <= data_in;

                bit_count <= 0;

                tx_busy <= 1;

                // Calculate parity only once
                case(PARITY_MODE)

                    0:
                        parity_bit <= 1'b0;

                    1:
                        parity_bit <= ^data_in;

                    2:
                        parity_bit <= ~(^data_in);

                    default:
                        parity_bit <= 1'b0;

                endcase

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

                bit_count <= bit_count + 1;

                if(bit_count == DATA_WIDTH-1)
                begin

                    if(PARITY_MODE == 0)
                        state <= STOP;
                    else
                        state <= PARITY;

                end

            end

        end

        //------------------------------------------------
        // PARITY BIT
        //------------------------------------------------

        PARITY:
        begin

            if(baud_tick)
            begin

                tx <= parity_bit;

                state <= STOP;

            end

        end
                //------------------------------------------------
        // STOP BIT(S)
        //------------------------------------------------

        STOP:
        begin

            if(baud_tick)
            begin

                tx <= 1'b1;

                stop_count <= stop_count + 1;

                if(stop_count == STOP_BITS-1)
                begin

                    stop_count <= 0;

                    tx_busy <= 0;

                    state <= IDLE;

                end

            end

        end

        //------------------------------------------------

        endcase

    end

end

endmodule