`timescale 1ns / 1ns
module tb;

localparam DATA_WIDTH = 8;
localparam K = 3;
localparam M = 3;
localparam N = 3;

reg clk;
reg rst;

top #(
    .DATA_WIDTH(DATA_WIDTH),
    .MEM_SIZE(MEM_SIZE),
    .NUM_THREADS(9),
    .K(K),
    .M(M),
    .N(N)
) dut (
    .clk(clk),
    .rst(rst)
);

    integer itr_n, itr_m, itr_k;
    initial begin
        for(itr_m = 0; itr_m < M; itr_m = itr_m + 1) begin
            for(itr_n = 0; itr_n < N; itr_n = itr_n + 1) begin
                for(itr_k = 0; itr_k < K; itr_k = itr_k + 1) begin
                    dut.A[itr_m][itr_k] = itr_m + itr_n + itr_k;
                    dut.B[itr_k][itr_n] = itr_m + itr_n + itr_k;
                end
            end
        end

        $display("A:");
        for(itr_m = 0; itr_m < M; itr_m = itr_m + 1) begin
            for(itr_k = 0; itr_k < K; itr_k = itr_k + 1) begin
                $display("%d",dut.A[itr_m][itr_k]);
            end
        end

        $display("B:");
        for(itr_k = 0; itr_k < K; itr_k = itr_k + 1) begin
            for(itr_n = 0; itr_n < N; itr_n = itr_n + 1) begin
                $display("%d",dut.B[itr_k][itr_n]);
            end
        end
    end

    integer i;
    initial begin
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
        //for(j = 0; j <= BIT_WIDTH+10; j = j+1) begin //Iterate all possible combinations
            //$display("shift=%d, val=%b, res=%b", shift, val, out);
        //end
    end
    initial begin
        $dumpfile("data/dumpfile.vcd");
        $dumpvars(0, tb);
    end
    always @(negedge dut.done_pipe) begin
        if(rst) begin //rst high => not in reset
            $finish();
        end
    end

    final begin
        $display("Final results:");
        for(itr_m = 0; itr_m < M; itr_m = itr_m + 1) begin
            for(itr_n = 0; itr_n < N; itr_n = itr_n + 1) begin
                $write("%d ",dut.final_res[(itr_m * N + itr_n) * DATA_WIDTH +: DATA_WIDTH]);
            end
            $display("");
        end
    end


endmodule
