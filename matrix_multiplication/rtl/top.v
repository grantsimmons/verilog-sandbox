module top #(
    parameter K = 3,
    parameter N = 3,
    parameter M = 3,
    parameter DATA_WIDTH = 8,
    parameter NUM_THREADS = N * M
) (
    input wire clk,
    input wire rst
);

//Internal Matrix Memories
reg [DATA_WIDTH-1:0] A [0:M][0:K];
reg [DATA_WIDTH-1:0] B [0:K][0:N];

//K index counter
wire [$clog2(K+1)-1:0] k;
wire done; //Counter reached MAX_COUNT

counter #(.MAX_COUNT(K)) k_cnt (
        .clk(clk),
        .rst(rst),
        .count(k),
        .done(done)
);

//Done Pipe
//Hook for TB to end calculation
reg done_pipe;
always @(posedge clk) begin
    done_pipe <= done;
end

//Generating the thread array
//One thread per output element
//Verilog does not support packed input array?
wire [DATA_WIDTH * M * N - 1:0] thread_outputs;
genvar m, n;

generate
for(m = 0; m < M; m = m + 1) begin
    for(n = 0; n < N; n = n + 1) begin
        thread #(DATA_WIDTH) mat_thread (
            .clk(clk),
            .rst(rst),
            .a(A[m][k]),
            .b(B[k][n]),
            .res(thread_outputs[(m * N + n) * DATA_WIDTH +: DATA_WIDTH])
        );
    end
end
endgenerate

//Output Matrix Register
//Copies when the result has completed
reg  [DATA_WIDTH * M * N - 1:0] final_res;

always @(posedge clk) begin
    if (done) begin
        $display("Done!");
        final_res <= thread_outputs;
    end
end

endmodule
