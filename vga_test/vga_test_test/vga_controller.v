
module vga_controller(
    input sys_clk,   // from Basys 3
    input sys_rst_n,        // system !sys_rst_n
    output video_on,    // ON while pixel counts for x and y and within display area
    output hsync,       // horizontal sync
    output vsync,       // vertical sync
    output p_tick,      // the 25MHz pixel/second rate signal, pixel tick
    output [9:0] x,     // pixel count/position of pixel x, max 0-799
    output [9:0] y      // pixel count/position of pixel y, max 0-524
    );
    
    // VGA parameters
    parameter HD = 640;             // horizontal display area width in pixels
    parameter HF = 16;              // horizontal front porch width in pixels
    parameter HB = 48;              // horizontal back porch width in pixels
    parameter HR = 96;              // horizontal retrace width in pixels
    parameter HMAX = HD+HF+HB+HR-1; // max value of horizontal counter = 799
    parameter VD = 480;             // vertical display area length in pixels 
    parameter VF = 10;              // vertical front porch length in pixels  
    parameter VB = 33;              // vertical back porch length in pixels   
    parameter VR = 2;               // vertical retrace length in pixels  
    parameter VMAX = VD+VF+VB+VR-1; // max value of vertical counter = 524   
    
    // Generate 25MHz from 100MHz clock
    reg [1:0] r_25MHz;
    wire w_25MHz;
    
    always @(posedge sys_clk or negedge sys_rst_n)
        if(!sys_rst_n) begin
            r_25MHz <= 0;
        end else begin
            r_25MHz <= r_25MHz + 1;
        end
    
    assign w_25MHz = (r_25MHz == 0) ? 1 : 0; // assert tick 1/4 of the time

    // Counter Registers, two each for buffering to avoid glitches
    reg [9:0] h_count_reg, h_count_next;
    reg [9:0] v_count_reg, v_count_next;
    
    // Output Buffers
    reg v_sync_reg, h_sync_reg;
    wire v_sync_next, h_sync_next;
    
    // Register Control (to update counters and sync signals)
    always @(posedge sys_clk or negedge sys_rst_n)  // Use 25MHz clock for updates
        if(!sys_rst_n) begin
            v_count_reg <= 0;
            h_count_reg <= 0;
            v_sync_reg  <= 1'b0;
            h_sync_reg  <= 1'b0;
        end else begin
            v_count_reg <= v_count_next;
            h_count_reg <= h_count_next;
            v_sync_reg  <= v_sync_next;
            h_sync_reg  <= h_sync_next;
        end
         
    // Logic for horizontal counter
    always @(posedge sys_clk or negedge sys_rst_n)      // pixel tick
        if(!sys_rst_n) begin
            h_count_next <= 0;
        end else if (w_25MHz) begin
            if(h_count_reg == HMAX) begin                 // end of horizontal scan
                h_count_next <= 0;
            end else begin
                h_count_next <= h_count_reg + 1;
            end
        end
  
    // Logic for vertical counter
    always @(posedge sys_clk or negedge sys_rst_n)      // pixel tick
        if(!sys_rst_n) begin
            v_count_next <= 0;
        end else if (w_25MHz) begin
            if(h_count_reg == HMAX) begin                 // end of horizontal scan
                if((v_count_reg == VMAX)) begin           // end of vertical scan
                    v_count_next <= 0;
                end else begin
                    v_count_next <= v_count_reg + 1;
                end
            end
        end
        
    // h_sync_next asserted within the horizontal retrace area
    assign h_sync_next = (h_count_reg >= (HD+HB) && h_count_reg <= (HD+HB+HR-1));
    
    // v_sync_next asserted within the vertical retrace area
    assign v_sync_next = (v_count_reg >= (VD+VB) && v_count_reg <= (VD+VB+VR-1));
    
    // Video ON/OFF - only ON while pixel counts are within the display area
    assign video_on = (h_count_reg < HD) && (v_count_reg < VD); // 0-639 and 0-479 respectively
            
    // Outputs
    assign hsync  = h_sync_reg;
    assign vsync  = v_sync_reg;
    assign x      = (h_count_reg > HD) ? h_count_reg : HD - h_count_reg;
    assign y      = (v_count_reg > VD) ? v_count_reg : VD - v_count_reg;
    assign p_tick = w_25MHz;
            
endmodule
