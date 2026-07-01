module uart_rx(

    input  wire       clk,
    input  wire       rst,
    input  wire       baud_tick,

    input  wire       rx,

    output reg [7:0]  data_out,
    output reg        rx_done

);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] state;

reg [7:0] shift_reg;

reg [2:0] bit_count;

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin

        state     <= IDLE;
        shift_reg <= 8'd0;
        bit_count <= 3'd0;
        data_out  <= 8'd0;
        rx_done   <= 1'b0;

    end

    else
    begin

        rx_done <= 1'b0;

        case(state)

        //-------------------------------------------------

        IDLE:

        begin

            if(rx == 1'b0)
                state <= START;

        end

        //-------------------------------------------------

        START:

        begin

            if(baud_tick)
            begin

                bit_count <= 3'd0;

                state <= DATA;

            end

        end

        //-------------------------------------------------

        DATA:

        begin

            if(baud_tick)
            begin

                shift_reg[bit_count] <= rx;

                bit_count <= bit_count + 1;

                if(bit_count == 3'd7)
                    state <= STOP;

            end

        end

        //-------------------------------------------------

        STOP:

        begin

            if(baud_tick)
            begin

                data_out <= shift_reg;

                rx_done <= 1'b1;

                state <= IDLE;

            end

        end

        //-------------------------------------------------

        endcase

    end

end

endmodule