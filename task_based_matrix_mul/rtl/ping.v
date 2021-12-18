module ping #(parameter ADDR_WIDTH = 8, parameter ARR_LENGTH = 8, parameter DATA_WIDTH = 8) (
    input wire clk,
    input wire rst,
    input wire mem_busy,
    input wire [7:0] data_in,
    output wire init_out,
    output wire [ADDR_WIDTH-1:0] addr_out
);

reg [2:0] state;

reg init;
reg [ADDR_WIDTH-1:0] addr;
reg [8 * ARR_LENGTH -1:0] data;
reg [8 * ARR_LENGTH -1:0] data2;

reg buffer_mux;

reg [$clog2(ARR_LENGTH+1)-1:0] pos;

wire pos_ready;

assign pos_ready = (pos == ARR_LENGTH) ? 1 : 0;
assign addr_out = (state == 2'b01) ? addr : 'bx;
assign init_out = (state == 2'b01) ? init : 'b0;


always @(posedge clk or negedge rst) begin
    if (~rst) begin
        addr <= -1;
        init <= 'b0;
        state <= 'b0;
        pos <= -1;
        data <= 'bx;
        data2 <= 'bx;
        buffer_mux <= 0;
    end
    else begin
        if(mem_busy) begin
            //stall
            state <= 2'b0;
        end
        else begin
            if(state == 2'b0) begin
                case(buffer_mux)
                    1'b0: data[pos * DATA_WIDTH +: DATA_WIDTH] <= data_in;
                    1'b1: data2[pos * DATA_WIDTH +: DATA_WIDTH] <= data_in;
                endcase
                pos <= pos + 1'b1;
                addr <= addr + 1'b1;
                init <= 1;
                state <= 2'b01;
            end
            if(state == 2'b01) begin
                //read
            end
        end
    end
end

always @(posedge clk) begin
    if (pos_ready) begin
        buffer_mux <= ~buffer_mux;
        pos <= 'b0;
    end
end

endmodule
