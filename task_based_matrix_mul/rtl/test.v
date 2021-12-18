module delay #(
    parameter CYCLES = 1,
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8
) (
    input wire clk,
    input wire rst,
    input wire init,
    input wire wr,
    input wire [ADDR_WIDTH-1:0] addr,
    input wire [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output wire busy
);

reg [DATA_WIDTH-1:0] mem [0:1<<ADDR_WIDTH];

reg [$clog2(CYCLES+1)-1:0] cycle;

reg [ADDR_WIDTH-1:0] addr_reg;
reg [DATA_WIDTH-1:0] data_in_reg;
reg wr_reg;

reg [1:0] state;
//00: idle
//01: counting
//10: ready

assign busy = state == 2'b01;

always @(posedge clk or negedge rst) begin
    if(~rst) begin
        cycle <= 0;
        state <= 0;
    
        wr_reg <= 0;
        addr_reg <= 0;
        data_in_reg <= 0;
        data_out <= 'bz;
    end
    else begin
        case(state)
            2'b0: begin
                if(init) begin
                    state <= 2'b01;
                    addr_reg <= addr;
                    wr_reg <= wr;
                    data_in_reg <= data_in;
                end
            end
            2'b01: begin
                if ( cycle == CYCLES - 1 ) begin
                    state <= 2'b10;
                end
                else begin
                    cycle <= cycle + 1'b1;
                end
            end
            2'b10: begin
                state <= 2'b0;
                data_out <= 'bz;
                cycle <= 0;
            end
            default: state <= 2'b0;
        endcase
    end
end

always @(negedge busy) begin
    data_out <= mem[addr_reg];
end
endmodule
