module vga_controller(
    input sys_clk,          
    input sys_rst_n,        
    output reg video_on,    
    output reg hsync,       
    output reg vsync,       
    output reg p_tick,      
    output reg [9:0] x,     
    output reg [9:0] y      
);

    // VGA 640x480 @ 60Hz timing parameters
    localparam HD = 640;    // horizontal display area
    localparam HF = 16;     // horizontal front porch
    localparam HB = 48;     // horizontal back porch  
    localparam HR = 96;     // horizontal retrace (sync pulse)
    localparam HMAX = 799;  // total horizontal pixels - 1
    
    localparam VD = 480;    // vertical display area
    localparam VF = 10;     // vertical front porch
    localparam VB = 33;     // vertical back porch
    localparam VR = 2;      // vertical retrace (sync pulse)
    localparam VMAX = 524;  // total vertical lines - 1

    // Clock divider for 25MHz pixel clock
    reg [1:0] clk_div;
    
    // Pixel counters
    reg [9:0] h_count;
    reg [9:0] v_count;
    
    
    // Clock divider
    always @(posedge sys_clk) begin
        if (!sys_rst_n) begin
            clk_div <= 2'b00;
        end else begin
            clk_div <= clk_div + 1;
        end
    end
    
    // Pixel tick generation
    always @(posedge sys_clk) begin
        if (!sys_rst_n) begin
            p_tick <= 1'b0;
        end else begin
            p_tick <= (clk_div == 2'b11);
        end
    end
    
    // Counters
    always @(posedge sys_clk) begin
        if (!sys_rst_n) begin
            h_count <= 10'd0;
            v_count <= 10'd0;
        end else if (clk_div == 2'b11) begin
            if (h_count == HMAX) begin
                h_count <= 10'd0;
                if (v_count == VMAX)
                    v_count <= 10'd0;
                else
                    v_count <= v_count + 1;
            end else begin
                h_count <= h_count + 1;
            end
        end
    end
    
    // Sync signals
    always @(posedge sys_clk) begin
        if (!sys_rst_n) begin
            hsync <= 1'b1;
            vsync <= 1'b1;
        end else begin
            hsync <= ~((h_count >= (HD + HF)) && (h_count < (HD + HF + HR)));
            vsync <= ~((v_count >= (VD + VF)) && (v_count < (VD + VF + VR)));
        end
    end
    
    // Video output control
    always @(posedge sys_clk) begin
        if (!sys_rst_n) begin
            video_on <= 1'b0;
            x <= 10'd0;
            y <= 10'd0;
        end else begin
            video_on <= (h_count < HD) && (v_count < VD);
            x <= (h_count + 1 < HD) ? HD - h_count - 1 : 10'd0;
            y <= (v_count + 1 < VD) ? VD - v_count - 1 : 10'd0;
        end
    end

endmodule