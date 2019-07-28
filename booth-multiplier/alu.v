module alu (
        input wire clk,
        input wire [1:0] op,
        input wire [3:0] val1,
        input wire [3:0] val2,
        output reg [4:0] res
        );
    
    //typedef enum reg { ADD, SUB } operation;
    always @(posedge clk) begin
        case(op)
            //ADD: res <= val1 + val2;
            //SUB: res <= val1 - val2;
            01: res <= val1 + val2;
            10: res <= val1 - val2;
        endcase
    end
endmodule
