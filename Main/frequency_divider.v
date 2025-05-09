module frequency_divider #(parameter N = 32) ( // N must be even number
    input org_clk,
    input sys_rst_n,
    output reg div_clk
);

reg [$clog2(N + 1)-1:0] count;

always @(posedge org_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        div_clk <= 0;
    end else if (count == N / 2 - 1) begin
        div_clk <= ~div_clk;
    end
end

always @(posedge org_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        count <= 0;
    end else begin
        if (count == N / 2 - 1) begin
            count <= 0;
        end else begin
            count <= count + 1;
        end
    end
end

endmodule