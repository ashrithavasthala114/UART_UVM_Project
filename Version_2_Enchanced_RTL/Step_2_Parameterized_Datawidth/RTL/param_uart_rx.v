module uart_rx
#(
    parameter DATA_WIDTH = 8
)
(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  baud_tick,

    input  wire                  rx,

    output reg [DATA_WIDTH-1:0]  data_out,
    output reg                   rx_done
);

//------------------------------------------------------
// State Encoding
//------------------------------------------------------

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

//------------------------------------------------------
// Internal Registers
//------------------------------------------------------

reg [1:0] state;

// Shift Register
reg [DATA_WIDTH-1:0] shift_reg;

// Bit Counter
reg [3:0] bit_count;

//------------------------------------------------------
// UART Receiver FSM
//------------------------------------------------------

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin

        state     <= IDLE;
        shift_reg <= 0;
        bit_count <= 0;
        data_out  <= 0;
        rx_done   <= 1'b0;

    end

    else
    begin

        rx_done <= 1'b0;

        case(state)

        //--------------------------------------------------
        // IDLE
        //--------------------------------------------------

        IDLE:
        begin

            if(rx == 1'b0)
                state <= START;

        end

        //--------------------------------------------------
        // START BIT
        //--------------------------------------------------

        START:
        begin

            if(baud_tick)
            begin

                bit_count <= 0;

                state <= DATA;

            end

        end

        //--------------------------------------------------
        // RECEIVE DATA
        //--------------------------------------------------

        DATA:
        begin

            if(baud_tick)
            begin

                shift_reg[bit_count] <= rx;

                if(bit_count == DATA_WIDTH-1)
                begin

                    state <= STOP;

                end
                else
                begin

                    bit_count <= bit_count + 1;

                end

            end

        end

        //--------------------------------------------------
        // STOP BIT
        //--------------------------------------------------

        STOP:
        begin

            if(baud_tick)
            begin

                data_out <= shift_reg;

                rx_done <= 1'b1;

                state <= IDLE;

            end

        end

        //--------------------------------------------------

        endcase

    end

end

endmodule