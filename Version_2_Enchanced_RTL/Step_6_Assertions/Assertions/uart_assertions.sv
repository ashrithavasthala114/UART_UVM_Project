module uart_assertions
(
    input logic clk,
    input logic rst,

    input logic tx_start,
    input logic tx_busy,

    input logic rx_done,

    input logic parity_error,
    input logic framing_error
);

    //------------------------------------------------
    // Assertion 1
    // TX should become busy after tx_start
    //------------------------------------------------

    property p_tx_start_busy;

        @(posedge clk)

        disable iff(rst)

        tx_start |=> tx_busy;

    endproperty

    assert property(p_tx_start_busy)
    else
        $error("ASSERTION FAILED : TX did not become busy");
     

         //------------------------------------------------
    // Assertion 2
    // TX Busy should eventually deassert
    //------------------------------------------------

    property p_tx_busy_clears;

        @(posedge clk)

        disable iff(rst)

        tx_busy |-> ##[1:5000] !tx_busy;

    endproperty

    assert property(p_tx_busy_clears)
    else
        $error("ASSERTION FAILED : TX Busy never cleared");

            //------------------------------------------------
    // Assertion 3
    // Errors should not occur together
    //------------------------------------------------

    property p_no_double_error;

        @(posedge clk)

        disable iff(rst)

        !(parity_error && framing_error);

    endproperty

    assert property(p_no_double_error)
    else
        $error("ASSERTION FAILED : Both errors active");

            //------------------------------------------------
    // Assertion 4
    // Valid RX should not have framing error
    //------------------------------------------------

    property p_rx_done_no_framing_error;

        @(posedge clk)

        disable iff(rst)

        rx_done |-> !framing_error;

    endproperty

    assert property(p_rx_done_no_framing_error)
    else
        $error("ASSERTION FAILED : Framing Error on RX Done");
        endmodule