module charge_bar_controller #(
    parameter PHY_WIDTH = 16,
    parameter SEQ_LEN = 20
)(
    input sys_clk,
    input sys_rst_n,
    input [PHY_WIDTH-1:0] charge_bar,
    output CA, CB, CC, CD, CE, CF, CG,
    output DP,
    output [7:0] AN
);
    localparam THRESHOLD_SHIFT = 55;
    localparam MAX_THRESHOLD = THRESHOLD_SHIFT * SEQ_LEN;
    wire svn_shift_posedge;
    reg [PHY_WIDTH-1:0] charge_bar_d;
    reg [PHY_WIDTH-1:0] threshold_reg;
    reg [7:0] charge_bar_svn;


    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            charge_bar_d <= 0;
        end else begin
            charge_bar_d <= charge_bar;
        end
    end
    assign svn_shift_posedge = (charge_bar_d != charge_bar) && (charge_bar > threshold_reg);

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            threshold_reg <= THRESHOLD_SHIFT;
        end else if (svn_shift_posedge) begin
            threshold_reg <= (threshold_reg >= MAX_THRESHOLD) ? THRESHOLD_SHIFT : threshold_reg + THRESHOLD_SHIFT;
        end
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n || charge_bar == 1) begin
            charge_bar_svn <= 0;
        end else if (svn_shift_posedge) begin
            charge_bar_svn <= {charge_bar_svn[6:0], 1'b1};
        end
    end

    marquee marquee_inst(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .seq(charge_bar_svn),
        .CA(CA),
        .CB(CB),
        .CC(CC),
        .CD(CD),
        .CE(CE),
        .CF(CF),
        .CG(CG),
        .DP(DP),
        .AN(AN)
    );

endmodule

module marquee (
    input sys_clk,
    input sys_rst_n,
    input [7:0] seq,
    output CA, 
    output CB,
    output CC, 
    output CD,
    output CE,
    output CF, 
    output CG,
    output DP,
    output [7:0] AN
);

reg [2:0] cnt;
wire clk_high;

fq_div #(5_000) fq_div_10 (
    .sys_rst_n(sys_rst_n),
    .org_clk(sys_clk),
    .div_n_clk(clk_high)
);

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        cnt <= 0;
    end else if (clk_high) begin
        cnt <= cnt + 1;
    end
end

svn_dcdr_n svn1 (
    .in(seq[cnt]),
    .sys_clk(sys_clk),
    .clk(clk_high),
    .sys_rst_n(sys_rst_n),
    .CA(CA),
    .CB(CB),
    .CC(CC),
    .CD(CD),
    .CE(CE),
    .CF(CF),
    .CG(CG),
    .DP(DP),
    .AN(AN)
);

endmodule

module svn_dcdr_n (
    input sys_clk,
    input clk,
    input sys_rst_n,
    input in,
    output CA, CB, CC, CD, CE, CF, CG,
    output DP,
    output reg [7:0] AN
);

assign {CA, CB, CC, CD, CE, CF, CG, DP} = (in) ? 8'b0000_0001 : 8'b1111_1111;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        AN <= 8'b11_111_110;
    end else if (clk) begin
        AN <= {AN[6:0], AN[7]};
    end
end

endmodule