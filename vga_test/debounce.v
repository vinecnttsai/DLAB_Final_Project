module debounce #(parameter N = 100000, parameter WIDTH = 1) (
    input sys_clk,
    input sys_rst_n,
    input [WIDTH-1:0] org,
    output reg [WIDTH-1:0] debounced
);

    reg [WIDTH-1:0] org_sync0, org_sync1;  // 兩級同步器
    reg [$clog2(N)-1:0] cnt;               // 一個總 counter
    reg enable;

    // 兩級同步器
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            org_sync0 <= {WIDTH{1'b0}};
            org_sync1 <= {WIDTH{1'b0}};
        end else begin
            org_sync0 <= org;
            org_sync1 <= org_sync0;
        end
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            enable <= 0;
        end else if (org_sync1 != debounced) begin
            enable <= 1;
        end else if (cnt == N-1) begin
            enable <= 0;
        end
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            cnt <= 0;
        end else if (enable) begin
            cnt <= cnt + 1;
        end else begin
            cnt <= 0;
        end
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            debounced <= {WIDTH{1'b0}};
        end else if (cnt == N-1) begin
            debounced <= org_sync1;
        end
    end

endmodule