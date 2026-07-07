module uart_rx
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

    input  wire                   rx,

    output reg [DATA_WIDTH-1:0]   data_out,

    output reg                    rx_done,

    output reg                    parity_error
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

// Received parity bit
reg received_parity;

// Calculated parity
reg expected_parity;

//=====================================================
// UART Receiver
//=====================================================

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin

        state <= IDLE;

        shift_reg <= 0;

        bit_count <= 0;

        stop_count <= 0;

        received_parity <= 0;

        expected_parity <= 0;

        data_out <= 0;

        rx_done <= 0;

        parity_error <= 0;

    end

    else
    begin

        rx_done <= 0;

        case(state)

                //------------------------------------------------
        // IDLE
        //------------------------------------------------

        IDLE:
        begin

            parity_error <= 0;

            stop_count <= 0;

            if(rx == 1'b0)
            begin

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

                bit_count <= 0;

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
        // PARITY BIT
        //------------------------------------------------

                

        PARITY:
        begin

            if(baud_tick)
            begin

                // Store received parity bit
                received_parity <= rx;

                // Calculate parity AFTER all data bits are received
                case(PARITY_MODE)

                    // Even Parity
                    1:
                    begin

                        if(rx == (^shift_reg))
                            parity_error <= 1'b0;
                        else
                            parity_error <= 1'b1;

                    end

                    // Odd Parity
                    2:
                    begin

                        if(rx == ~(^shift_reg))
                            parity_error <= 1'b0;
                        else
                            parity_error <= 1'b1;

                    end

                    // No Parity
                    default:
                    begin

                        parity_error <= 1'b0;

                    end

                endcase

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

            parity_error <= 0;

        end

        //------------------------------------------------

        endcase

    end

end

endmodule