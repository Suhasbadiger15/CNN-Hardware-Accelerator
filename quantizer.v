`timescale 1ns / 1ps
module quantizer #(
    parameter N = 16,   // bit width
    parameter Q = 4     // fractional bits to drop (e.g. 4 => divide by 16)
)(
    input  wire signed [N-1:0] din,
    output reg  signed [N-1:0] dout
);

    // extended width to hold rounding addition safely
    localparam W = N + 1;
    wire signed [W-1:0] rounded;

    // add rounding offset: +2^(Q-1) for positive, -2^(Q-1) for negative
    // compute offset in W bits
    wire signed [W-1:0] round_off = (din >= 0) ? ( ({{(W-(Q)){1'b0}}, 1'b1} << (Q-1)) ) : - ( ({{(W-(Q)){1'b0}}, 1'b1} << (Q-1)) );

    assign rounded = $signed({din[N-1], din}) + round_off; // sign-extend din into W bits

    always @(*) begin
        // arithmetic right shift with rounding
        dout = rounded >>> Q;

        // saturation to signed N-bit range
        if (dout > $signed((1 <<< (N-1)) - 1))
            dout = $signed((1 <<< (N-1)) - 1);
        else if (dout < $signed(-(1 <<< (N-1))))
            dout = $signed(-(1 <<< (N-1)));
    end
endmodule
