module thread #(
    parameter DATA_WIDTH = 8
) (
    input wire clk,
    input wire rst,
    input wire [DATA_WIDTH-1:0] a, //Input value from Matrix A
    input wire [DATA_WIDTH-1:0] b, //Input value from Matrix B
    output reg [DATA_WIDTH-1:0] res //Summation of (Ai * Bi) res for i in range(0,K)
);

always @(posedge clk or negedge rst) begin
    if (~rst) begin
        res <= 0;
    end
    else begin
        //Perform the actual calculation if we're not in reset
        res <= res + (a * b);
        $display("Adding a * b (%d) to res (%d)", a * b, res);
    end
end

endmodule
