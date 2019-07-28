`timescale 1ns / 1ns
module tb;
    localparam OPERAND_BITS = 4;
    reg clk;
    reg signed [OPERAND_BITS - 1:0] mul1;
    reg signed [OPERAND_BITS - 1:0] mul2;
    wire signed [2 * OPERAND_BITS - 1:0] res_not;
    wire signed [2 * OPERAND_BITS - 1:0] res_true;
    wire ready;
    booth #(.OPERAND_BITS(OPERAND_BITS)) b1(.clk(clk), .mul1(mul1), .mul2(mul2), .res_out(res_not), .ready(ready), .comp(res_true));
    integer i;
    initial begin
        clk = 0;
        for(i = 0; i <= 657918; i = i+1) begin //(OPERAND_BITS + 2) * (2 ** (2 * OPERAND_BITS)) + 2548 ~2^8*10 = (657918 - 2^16) ?
            #5; clk = ~clk;
            #5; clk = ~clk;
        end
    end
    integer j;
    integer k;
    initial begin
        mul1 <= 1;
        mul2 <= 1;
        for(j = 0; j < (2 ** OPERAND_BITS); j = j+1) begin //Iterate all possible combinations
            @(posedge ready) begin
                $display("mul1=%d, mul2=%d, res=%d", mul1, mul2, res_true);
                #15; mul1 <= j;
                for(k = 0; k < (2 ** OPERAND_BITS); k = k+1) begin
                    @(posedge ready) begin
                        $display("mul1=%d, mul2=%d, res=%d", mul1, mul2, res_true);
                        #15; mul2 <= k;
                    end
                end
            end
        end
    end
    initial begin
        $dumpfile("data/dumpfile.vcd");
        $dumpvars(0, tb);
    end
endmodule
