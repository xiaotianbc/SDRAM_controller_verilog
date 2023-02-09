// 生成50MHz的时钟，区分仿真环境和实际环境
`define SIM


module generate_clk (
        input      clk_raw,
        output     clk_50M,clk_50M_P
    );

    `ifndef SIM
            wire lock_o;
    wire clkoutd_o;
    wire clkoutd3_o;
    wire gw_vcc=1'b1;
    wire gw_gnd=1'b0;

    rPLL rpll_inst (
             .CLKOUT(clk_50M),
             .LOCK(lock_o),
             .CLKOUTP(clk_50M_P),
             .CLKOUTD(clkoutd_o),
             .CLKOUTD3(clkoutd3_o),
             .RESET(gw_gnd),
             .RESET_P(gw_gnd),
             .CLKIN(clk27M),
             .CLKFB(gw_gnd),
             .FBDSEL({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
             .IDSEL({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
             .ODSEL({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
             .PSDA({gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
             .DUTYDA({gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
             .FDLY({gw_vcc,gw_vcc,gw_vcc,gw_vcc})
         );

    //Freq CLKOUT = CLKIN * (FBDIV_SEL+1) / (IDIV_SEL+1)
    //Freq 50 MHz = 27 * (12+1) / (6+1)

    defparam rpll_inst.FCLKIN = "27";
    defparam rpll_inst.DYN_IDIV_SEL = "false";
    defparam rpll_inst.IDIV_SEL = 6;
    defparam rpll_inst.DYN_FBDIV_SEL = "false";
    defparam rpll_inst.FBDIV_SEL = 12;
    defparam rpll_inst.DYN_ODIV_SEL = "false";
    defparam rpll_inst.ODIV_SEL = 16;
    defparam rpll_inst.PSDA_SEL = "1000";
    defparam rpll_inst.DYN_DA_EN = "false";
    defparam rpll_inst.DUTYDA_SEL = "1000";
    defparam rpll_inst.CLKOUT_FT_DIR = 1'b1;
    defparam rpll_inst.CLKOUTP_FT_DIR = 1'b1;
    defparam rpll_inst.CLKOUT_DLY_STEP = 0;
    defparam rpll_inst.CLKOUTP_DLY_STEP = 0;
    defparam rpll_inst.CLKFB_SEL = "internal";
    defparam rpll_inst.CLKOUT_BYPASS = "false";
    defparam rpll_inst.CLKOUTP_BYPASS = "false";
    defparam rpll_inst.CLKOUTD_BYPASS = "false";
    defparam rpll_inst.DYN_SDIV_SEL = 2;
    defparam rpll_inst.CLKOUTD_SRC = "CLKOUT";
    defparam rpll_inst.CLKOUTD3_SRC = "CLKOUT";
    defparam rpll_inst.DEVICE = "GW2A-18C";


`else
    assign clk_50M=clk_raw;
    assign clk_50M_P=~clk_raw;
`endif

endmodule //generate_clk
