`timescale 1ns / 1ns
module tb;
    reg clk, reset, Ta, Tb;
    wire [1:0] La;
    wire [1:0] Lb;
    trafficfsm t1(.clk(clk), .reset(reset), .Ta(Ta), .Tb(Tb), .La(La), .Lb(Lb));
    integer i;
    initial begin
        clk = 0;
        reset = 0;
        Ta = 0;
        Tb = 0;
        if(1) begin //clk test
            for(i = 0; i <= 1000; i = i+1) begin
                #5; clk = ~clk;
                #5; clk = ~clk;
            end
        end
    end
    initial begin
        reset = 1;
        Ta = 0; Tb = 0; #12;
        Tb = 1; #10;
        Tb = 0; #20;
        Ta = 1; #15;
        Ta = 0; #5;
        Ta = 1; Tb = 0; #10;
        Tb = 0; #20;
        Tb = 1; #25;
        reset = 0; #5; 
        reset = 1; #10;

    end
    initial begin
        $dumpfile("data/dumpfile.vcd");
        $dumpvars(0, tb);
        $monitor("At time=%2t, clk=%d, reset=%d, Ta=%d, Tb=%d, La=%d, Lb=%d",
                $time, clk, reset, Ta, Tb, La, Lb);
    end
endmodule
