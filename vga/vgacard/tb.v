`timescale 10ns / 10ns
module tb;
    reg clk;
    wire h_sync, h_porch, h_sync_pulse, v_sync, v_porch,
         v_sync_pulse;
    wire [1:0] R, G, B;
    counter c1(.clk(clk), .h_sync_pulse(h_sync_pulse),
            .v_sync_pulse(v_sync_pulse), .R(R), .G(G), .B(B));
    integer i;
    initial begin
        clk = 0;
        if(0) begin //clk test
            for(i = 0; i <= 1000; i = i+1) begin
                #5; clk = ~clk;
                #5; clk = ~clk;
            end
        end
        if(1) begin //chain test
            for(i = 0; i <= 200000; i = i+1) begin
                #5; clk = ~clk;
                #5; clk = ~clk;
            end
        end
    end
    initial begin
        $dumpfile("dumpfile.vcd");
        $dumpvars(0, tb);
    end
    initial begin
        $monitor("At time=%2t, clk=%d, h_sync_pulse=%d, v_sync_pulse=%d",
                $time, clk, h_sync_pulse, v_sync_pulse);
    end
endmodule
