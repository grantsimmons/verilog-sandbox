module counter #(parameter H_WIDTH = 200, V_WIDTH = 600, HF_PORCH = 10, 
                 H_PULSE = 32, HB_PORCH = 22, VF_PORCH = 1, V_PULSE = 4, 
                 VB_PORCH = 23, R_DEPTH = 2, G_DEPTH = 2, B_DEPTH = 2) (
        input wire clk,
        //input wire [R_DEPTH + G_DEPTH + B_DEPTH - 1:0] color_in, //For external memory
        output wire h_sync_pulse, //Horizontal timing pulse
        output wire v_sync_pulse, //Vertical timing pulse
        output wire [R_DEPTH - 1:0] R, //2-bit Red out
        output wire [G_DEPTH - 1:0] G, //Blue out
        output wire [B_DEPTH - 1:0] B  //Green out
        );
    localparam H_BITS = $clog2(H_WIDTH + HF_PORCH + H_PULSE + HB_PORCH),
            V_BITS = $clog2(V_WIDTH + VF_PORCH + V_PULSE + VB_PORCH);
    reg h_porch = 0; //Indicates invisible section of horizontal scan
    reg h_sync = 1;
    assign h_sync_pulse = ~h_sync;
    reg v_porch = 0; //Indicates invisible section of vertical scan
    reg v_sync = 1;
    assign v_sync_pulse = ~v_sync;
    reg [H_BITS - 1:0] h_count = 0; //Counts horizontal pixels (Vis: 0-200, Full: 0-264)
    reg [V_BITS - 1:0] v_count = 0; //Counts vertical pixels (Vis: 0-600, Full: 0-628)
    wire [R_DEPTH + G_DEPTH + B_DEPTH - 1:0] color_out;  //Bus of color values from frame buffer
    frame_buffer #(.H_WIDTH(H_WIDTH), .V_WIDTH(V_WIDTH), .R_DEPTH(R_DEPTH),
                   .G_DEPTH(G_DEPTH), .B_DEPTH(B_DEPTH))
            f1(.clk(clk), .h_porch(h_porch), .h_index(h_count), 
            .v_index(v_count), .color_out(color_out)); //Holds next frame
    assign R = color_out[R_DEPTH + G_DEPTH + B_DEPTH - 1-:R_DEPTH]; //2 bits of color_out for each R, G, B
    assign G = color_out[G_DEPTH + B_DEPTH - 1-:G_DEPTH];
    assign B = color_out[B_DEPTH - 1:0];
    always @(posedge clk) begin
        //R <= color_out[5:4]; //Delays color by a cycle
        //G <= color_out[3:2];
        //B <= color_out[1:0];
        h_count <= h_count + 1'b1; //Increment pixel counter
        if (h_count >= H_WIDTH - 1) begin  //Display for 200 Pixels
            h_porch <= 1;          //Indicate front porch beginning
            if (h_count >= H_WIDTH + HF_PORCH - 1 && h_count < H_WIDTH + HF_PORCH + H_PULSE - 1) begin //Horiz. timing value
                h_sync <= 0;       //Set h_sync_pulse high between 210-242
            end
            if (h_count >= H_WIDTH + HF_PORCH + H_PULSE - 1) begin
                h_sync <= 1;       //End timing pulse
            end
            if (h_count == H_WIDTH + HF_PORCH + H_PULSE + HB_PORCH - 1) begin
                h_count <= 0;      //BUG: Even B value skipped due to 
                h_porch <= 0;      //immediate reassignment to 9'b000000001
                h_sync <= 1;       //at next clk edge
            end
        end
        else begin
            h_sync <= 1;
        end
    end

    always @(negedge h_porch) begin
        v_count <= v_count + 1'b1;
        if (v_count >= V_WIDTH - 1) begin
            v_porch <= 1;
            if (v_count >= V_WIDTH + VF_PORCH - 1 && v_count < V_WIDTH + VF_PORCH + V_PULSE - 1) begin
                v_sync <= 0;
            end
            if (v_count >= V_WIDTH + VF_PORCH + V_PULSE - 1) begin
                v_sync <= 1;
            end
            if (v_count == V_WIDTH + VF_PORCH + V_PULSE + VB_PORCH - 1) begin
                v_count <= 0;
                v_porch <= 0;
                v_sync <= 1;
            end
        end
        else begin
            v_sync <= 1;
        end
    end
endmodule
