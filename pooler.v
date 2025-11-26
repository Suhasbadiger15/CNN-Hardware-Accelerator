`timescale 1ns / 1ps

module pooler #(
    parameter N = 16,   // Bit width
    parameter m = 4,    // Input matrix size
    parameter p = 2     // Pool window size and stride
)(
    input clk,
    input rst,
    input en,
    input [N-1:0] data_in,
    output reg [N-1:0] pool_out,
    output reg valid_out,
    output reg done
);

    localparam TOTAL_INPUTS = m * m;
    localparam OUT_SIZE = (m / p) * (m / p);

    reg [N-1:0] matrix [0:TOTAL_INPUTS-1];
    reg [7:0] in_cnt;
    reg [7:0] out_cnt;
    reg [7:0] row;
    reg [7:0] col;

    // Declare here (not inside always)
    reg [N-1:0] a, b, c, d;
    reg [N-1:0] max1, max2, final_max;
    integer idx;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            in_cnt <= 0;
            out_cnt <= 0;
            pool_out <= 0;
            valid_out <= 0;
            done <= 0;
            row <= 0;
            col <= 0;
        end 
        else if (en) begin
            // Load input matrix
            if (in_cnt < TOTAL_INPUTS) begin
                matrix[in_cnt] <= data_in;
                in_cnt <= in_cnt + 1;
                valid_out <= 0;
                done <= 0;
            end 
            // Pooling phase
            else if (out_cnt < OUT_SIZE) begin
                idx = row * m + col;

                a = matrix[idx];
                b = matrix[idx + 1];
                c = matrix[idx + m];
                d = matrix[idx + m + 1];

                max1 = (a > b) ? a : b;
                max2 = (c > d) ? c : d;
                final_max = (max1 > max2) ? max1 : max2;

                pool_out <= final_max;
                valid_out <= 1;
                out_cnt <= out_cnt + 1;

                // Move pooling window
                col = col + p;
                if (col >= m) begin
                    col <= 0;
                    row <= row + p;
                end

                // Done after last pooled output
                if (out_cnt == OUT_SIZE - 1) begin
                    done <= 1;
                end
            end 
            else begin
                valid_out <= 0;
            end
        end 
        else begin
            valid_out <= 0;
        end
    end
endmodule
