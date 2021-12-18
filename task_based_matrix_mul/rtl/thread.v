`timescale 1ns/1ns

module thread #(
    parameter DATA_WIDTH = 8,
    parameter M_ID = -1,
    parameter N_ID = -1,
    parameter OUTPUT_DATA_WIDTH = 2 * DATA_WIDTH,
    parameter ADDER_WIDTH = 1
) (
    input wire clk,
    input wire rst,
    input wire [DATA_WIDTH-1:0] a [0:ADDER_WIDTH-1], //Input value from Matrix A
    input wire [DATA_WIDTH-1:0] b [0:ADDER_WIDTH-1], //Input value from Matrix B
    output reg [OUTPUT_DATA_WIDTH-1:0] res //Summation of (Ai * Bi) res for i in range(0,K)
);

reg [OUTPUT_DATA_WIDTH-1:0] result;
reg [OUTPUT_DATA_WIDTH-1:0] temp_data;

integer add;
always @(*) begin
    temp_data = 0;
    for(add = 0; add < ADDER_WIDTH; add = add + 1) begin
        temp_data = temp_data + a[add] * b[add];
        $display("(M = %d, N = %d) Adding a[%d] * b[%d] (%d * %d) = (%d) to temp_data (%d)", M_ID, N_ID, add, add, a[add], b[add], a[add] * b[add], temp_data);
    end
    result = temp_data;
    $display("result (%d) = temp_data", result);
end

always @(posedge clk or negedge rst) begin
    if (~rst) begin
        res <= 0;
        result <= 0;
    end
    else begin
        res <= result;
        //$display("Adding a * b (%d) to res (%d)", a * b, res);
    end
end

endmodule
