module counter #(
    parameter MAX_COUNT = 3
) (
    input wire                              clk,
    input wire                              rst,
    output reg [$clog2(MAX_COUNT+1)-1:0]    count, //Encoded count value
    output wire                             done
);

//Indicate that the counter has reached the maximum count
assign done = (count == MAX_COUNT);

always @(posedge clk or negedge rst) begin
    if (~rst) begin
        count <= 0;
    end
    else if (done) begin
        //Start the count over
        count <= 0;
    end
    else begin
        //Increment counter
        count <= count + 1;
    end
end

endmodule
