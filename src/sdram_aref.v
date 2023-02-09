// Auto Refresh 自动刷新模块

// 64ms 刷新 8192次
// 单次刷新时间：7.8125us
//

module sdram_aref (
        input      clk,
        input      rst_n,

        //cmds: CSn     RASn    CASn    WEn
        output reg [3:0]sdram_cmds,
        output wire [12:0]sdram_addrs,


        output      sdram_aref_req,
        input       sdram_aref_en,
        output      sdram_aref_done,
        input       sdram_init_done_flag
    );

    parameter CLK_FREQ_MHz = 50;
    // 计数7us所需的时间： 7000/ (1000/ CLK_FREQ_MHz)
    localparam AREF_CNT_MAX=7 * CLK_FREQ_MHz;

    reg [$clog2(AREF_CNT_MAX+1)-1:0] aref_cnt;


    reg flag_aref_working;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            flag_aref_working<= 1'b0;
        end
        else if (sdram_aref_en) begin
            flag_aref_working<= 1'b1;
        end
        else if(sdram_aref_done) begin
            flag_aref_working<= 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            aref_cnt <= 0;
        end
        else if (aref_cnt >= AREF_CNT_MAX)
            aref_cnt <= 0;
        else if (sdram_init_done_flag)
            aref_cnt <= aref_cnt+1'b1;
    end

    assign sdram_aref_req =(aref_cnt >= AREF_CNT_MAX)? 1'b1:1'b0;

    reg [2:0]sdram_aref_cmd_cnt;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sdram_aref_cmd_cnt <= 0;
        end
        else begin
            if (flag_aref_working) begin
                sdram_aref_cmd_cnt <= sdram_aref_cmd_cnt+1'b1;
            end
            else begin
                sdram_aref_cmd_cnt<=0;
            end
        end
    end

    // for ALL BANKS PRECHARGE
    assign sdram_addrs=13'b0_0100_0000_0000;


    //cmds: CSn     RASn    CASn    WEn
    localparam CMD_MODE_REG_SET = 4'b0000;
    localparam CMD_NOP = 4'b0111;
    localparam CMD_PRECHARGE_ALL_BANK = 4'b0010;
    localparam CMD_AUTO_REFRESH = 4'b0001;


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sdram_cmds<= CMD_NOP;
        end
        else
        case (sdram_aref_cmd_cnt)
            1:
                sdram_cmds<= CMD_PRECHARGE_ALL_BANK;
            2:
                sdram_cmds<= CMD_AUTO_REFRESH;
            default:
                sdram_cmds<= CMD_NOP;
        endcase
    end

    //tRC 是两次刷新之间的时间，并不是说刷新完之后要等rRC才能干别的事情
    assign sdram_aref_done = (sdram_aref_cmd_cnt >= 3) ?1'b1:1'b0;

endmodule //sdram_aref
