module fq_div #(parameter N = 2)(
    input org_clk,
    input sys_rst_n,
    output reg div_n_clk
); 
    reg [63:0] count;

always @(posedge org_clk or negedge sys_rst_n) begin

    if (!sys_rst_n) begin
        div_n_clk <= 1'b0;
    end else if (count == N - 2) begin
        div_n_clk <= 1'b1;
    end else begin
        div_n_clk <= 1'b0;
    end
end
    
always @(posedge org_clk or negedge sys_rst_n) begin
    
    if (!sys_rst_n) begin
        count <= 0;
    end else if (count == N - 1) begin
        count <= 0;
    end else begin
        count <= count + 1;
    end
end

endmodule 