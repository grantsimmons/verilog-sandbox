module top #(
    parameter K = 3,
    parameter N = 3,
    parameter M = 3,

    parameter K_BLOCK_SIZE = 3,
    parameter N_BLOCK_SIZE = 1,
    parameter M_BLOCK_SIZE = 3,

    parameter DATA_WIDTH = 8,
    parameter OUTPUT_DATA_WIDTH = 2 * DATA_WIDTH,
    parameter NUM_THREADS = N_BLOCK_SIZE * M_BLOCK_SIZE
) (
    input wire clk,
    input wire rst
);

//Internal Matrix Memories
reg [DATA_WIDTH-1:0] A [0:M][0:K];
reg [DATA_WIDTH-1:0] B [0:K][0:N];

//Block index counters
localparam K_GRID_SIZE = ((K - 1) / K_BLOCK_SIZE) + 1; //Ceil of K/K_BLOCK
localparam M_GRID_SIZE = ((M - 1) / M_BLOCK_SIZE) + 1; //Ceil of M/M_BLOCK
localparam N_GRID_SIZE = ((N - 1) / N_BLOCK_SIZE) + 1; //Ceil of N/N_BLOCK

wire [$clog2(K_GRID_SIZE + 1)-1:0] k_block_idx;
wire [$clog2(K_GRID_SIZE + 1)-1:0] k_block_idx_last;
wire [$clog2(M_GRID_SIZE + 1)-1:0] m_block_idx;
wire [$clog2(M_GRID_SIZE + 1)-1:0] m_block_idx_last;
wire [$clog2(N_GRID_SIZE + 1)-1:0] n_block_idx;
wire [$clog2(N_GRID_SIZE + 1)-1:0] n_block_idx_last;

wire k_block_done; //Counter reached MAX_COUNT
wire m_block_done;
wire n_block_done;

reg k_done_gater;
reg m_done_gater;
reg n_done_gater;

always @(negedge clk) begin
    k_done_gater <= k_block_done;
    m_done_gater <= m_block_done;
    n_done_gater <= n_block_done;
end

counter #(.MAX_COUNT(N_GRID_SIZE)) n_cnt (
    .clk(clk),
    .gater(1'b1), //Increment every clock cycle
    .rst(rst),
    .count(n_block_idx),
    .count_last(n_block_idx_last),
    .done(n_block_done)
);


counter #(.MAX_COUNT(K_GRID_SIZE)) k_block_cnt (
        .clk(clk),
        .gater(n_done_gater),
        .rst(rst),
        .count(k_block_idx),
        .count_last(k_block_idx_last),
        .done(k_block_done)
);

counter #(.MAX_COUNT(M_GRID_SIZE)) m_cnt (
    .clk(clk),
    .gater(n_done_gater & k_done_gater),
    .rst(rst),
    .count(m_block_idx),
    .count_last(m_block_idx_last),
    .done(m_block_done)
);

//Done Pipe
//Hook for TB to end calculation
reg done_pipe;
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        done_pipe <= 0;
    end
    else if (done_pipe) begin
        done_pipe <= 0;
    end
    else begin
        done_pipe <= (k_block_done & m_block_done & n_block_done);
    end
end

//Generating the thread array
//One thread per output element
//Verilog does not support packed input array?
wire [OUTPUT_DATA_WIDTH * M_BLOCK_SIZE * N_BLOCK_SIZE - 1:0] thread_outputs;

genvar m_local, n_local, k_local;

generate
for(m_local = 0; m_local < M_BLOCK_SIZE; m_local = m_local + 1) begin
    for(n_local = 0; n_local < N_BLOCK_SIZE; n_local = n_local + 1) begin

        wire [DATA_WIDTH-1:0] a_input [0:K_BLOCK_SIZE-1];
        wire [DATA_WIDTH-1:0] b_input [0:K_BLOCK_SIZE-1];

        //M_BLOCK_SIZE = 3
        //N_BLOCK_SIZE = 2
        //Thread 1: m_local = 0, n_local = 0 first row of A, first column of B
        //  Corresponds to output element 0,0
        //Thread 2: m_local = 0, n_local = 1 first row of A, second col of B
        //  Corresponds to output element 0,1

        for(k_local = 0; k_local < K_BLOCK_SIZE; k_local = k_local + 1) begin
            assign a_input[k_local] = A[m_block_idx * M_BLOCK_SIZE + m_local][k_block_idx * K_BLOCK_SIZE + k_local];
            assign b_input[k_local] = B[k_block_idx * K_BLOCK_SIZE + k_local][n_block_idx * N_BLOCK_SIZE + n_local];
        end

        wire [DATA_WIDTH-1:0] res_temp;

        thread #(.DATA_WIDTH(DATA_WIDTH), .M_ID(m_local), .N_ID(n_local), .OUTPUT_DATA_WIDTH(OUTPUT_DATA_WIDTH), .ADDER_WIDTH(K_BLOCK_SIZE)) mat_thread (
            .clk(clk),
            .rst(rst),
            .a(a_input),
            .b(b_input),
            .res(thread_outputs[((m_local * N_BLOCK_SIZE) + n_local) * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH])
        );

    end
end
endgenerate

reg [OUTPUT_DATA_WIDTH * M * N - 1:0] result;

integer m_fine_res, n_fine_res;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        result <= 0;
    end
    else begin
        $display("Writing index (last) n = %d, k = %d, m = %d", n_block_idx_last, k_block_idx_last, m_block_idx_last);
        for(m_fine_res = 0; m_fine_res < M_BLOCK_SIZE; m_fine_res = m_fine_res + 1) begin
            for(n_fine_res = 0; n_fine_res < N_BLOCK_SIZE; n_fine_res = n_fine_res + 1) begin
                result[((m_block_idx_last * M_BLOCK_SIZE + m_fine_res) * N + (n_block_idx_last * N_BLOCK_SIZE) + n_fine_res) * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] <=
                    result[((m_block_idx_last * M_BLOCK_SIZE + m_fine_res) * N + (n_block_idx_last * N_BLOCK_SIZE) + n_fine_res) * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] 
                    + thread_outputs[((m_fine_res * N_BLOCK_SIZE) + n_fine_res) * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH];
                $write("[%0t] add %d ",$time, thread_outputs[((m_fine_res * N_BLOCK_SIZE) + n_fine_res) * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH]);
            end
            $display("");
        end
    end
end

endmodule
