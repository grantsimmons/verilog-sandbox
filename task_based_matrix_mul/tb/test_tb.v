`timescale 1ns / 1ns
module tb;

localparam CYCLES = 2;
localparam ADDR_WIDTH = 8;
localparam ARR_LENGTH = 8;
localparam DATA_WIDTH = 8;

reg clk;
reg rst;

wire init;
reg wr;
wire [7:0]addr;
wire [7:0]data;

wire busy;

delay #(CYCLES) test_del (
    .clk(clk),
    .rst(rst),
    .init(init),
    .wr(wr),
    .addr(addr),
    .data_out(data),
    .busy(busy)
);

ping #(ADDR_WIDTH, ARR_LENGTH, DATA_WIDTH) test_ping (
    .clk(clk),
    .rst(rst),
    .mem_busy(busy),
    .init_out(init),
    .data_in(data),
    .addr_out(addr)
);

    integer k;
    initial begin
    for(k = 0; k < (1<<8); k = k + 1) begin
        test_del.mem[k] = k;
    end
    end

    integer i;
    initial begin
        //init = 0;
        clk = 0;
        rst = 1;
        for(i = 0; i <= 1000; i = i+1) begin //(OPERAND_BITS + 2) * (2 ** (2 * OPERAND_BITS)) + 2548 ~2^8*10 = (657918 - 2^16) ?
            #5; clk = ~clk;
            #5; clk = ~clk;
        end
    end

    integer j;
    initial begin
        #12; rst = 0; #12; rst = 1;
    end

    integer l;
    initial begin
        for(l = 0; l < (1<<8); l = l + 1) begin
            //#(2*CYCLES); init = 1; addr = l; #10; init = 0;
        end
    end

    initial begin
        $dumpfile("data/dumpfile.vcd");
        $dumpvars(0, tb);
    end

    integer x, y;
    always @(negedge busy) begin
        if(rst) begin //rst high => not in reset
            //Dump Matrix
            //$finish();
        end
    end

endmodule
