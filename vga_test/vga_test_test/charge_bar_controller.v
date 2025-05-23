module charge_bar_controller #(
    parameter PHY_WIDTH = 16,
    parameter SEQ_LEN = 20
)(
    input sys_clk,
    input sys_rst_n,
    input [PHY_WIDTH-1:0] charge_bar,
    output reg [PHY_WIDTH-1:0] charge_bar_vga,
    output CA, CB, CC, CD, CE, CF, CG,
    output DP,
    output [7:0] AN
);
    localparam CHARGE_BAR_VGA_WIDTH = 95;
    localparam CHARGE_BAR_SVN_WIDTH = 47;
    wire vga_shift_posedge;
    wire svn_shift_posedge;
    reg [PHY_WIDTH-1:0] charge_bar_d;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            charge_bar_d <= 0;
        end else begin
            charge_bar_d <= charge_bar;
        end
    end
    assign vga_shift_posedge = (charge_bar_d != charge_bar) && (charge_bar % CHARGE_BAR_VGA_WIDTH == 0);
    assign svn_shift_posedge = (charge_bar_d != charge_bar) && (charge_bar % CHARGE_BAR_SVN_WIDTH == 0);

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            charge_bar_vga <= 0;
        end else if (vga_shift_posedge) begin
            charge_bar_vga <= {charge_bar_vga[PHY_WIDTH - 5:0], 4'hB}; // 4'hB is the value of the charge bar
        end
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            charge_bar_svn <= 0;
        end else if (svn_shift_posedge) begin
            charge_bar_svn <= {charge_bar_svn[6:0], 1'b1};
        end
    end

    marquee #(
        .N(CHARGE_BAR_SVN_WIDTH),
        .SEQ_LEN(SEQ_LEN)
    ) marquee_inst(
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

wire [2:0] cnt;
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
        AN <= {AN[6:0], 1'b1};
    end
end

endmodule