module frame_buffer #(parameter H_WIDTH = 200, V_WIDTH = 600, R_DEPTH = 2,
                      G_DEPTH = 2, B_DEPTH = 2, H_BITS = 9, V_BITS = 10) (
        input wire clk,         //MODULE NOT USABLE FOR SYNTHESIS
        input wire pre_h_porch,
        input wire h_porch,
        input wire [H_BITS - 1:0] h_index,
        input wire [V_BITS - 1:0] v_index,
        output reg [COLOR_BITS - 1:0] color_out
        );
    localparam COLOR_BITS = R_DEPTH + G_DEPTH + B_DEPTH;
    reg [COLOR_BITS - 1:0] mem[0:H_WIDTH * V_WIDTH - 1];
    reg [COLOR_BITS - 1:0] color_count = '0;
    integer i;
    initial begin
        for (i = 0; i <= H_WIDTH * V_WIDTH - 1; i = i + 1) begin 
            mem[i] = color_count;
            color_count = color_count + 1'b1;
        end
        color_out <= mem[0];
    end
    always @(posedge clk) begin // && (v_index * 200 + h_index + 1) % 8 != 7
        if (!pre_h_porch) begin
            color_out <= mem[v_index * 200 + h_index + 1]; //FIX
        end
        if (v_index * 200 + h_index + 1 > H_WIDTH * V_WIDTH - 1) begin
            color_out <= color_out;
        end
    end
endmodule
