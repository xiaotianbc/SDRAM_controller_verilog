//clk = 27MHz时，每个时钟周期间隔为37ns

//目标：设计一个模块，完成sdram的初始化工作
module sdram_init (
        input      clk,
        input      rst_n,

        //cmds: CSn     RASn    CASn    WEn
        output reg [3:0]sdram_cmds,
        output wire [12:0]sdram_addrs,
        output      sdram_init_done
    );

    localparam  CLK_FREQ_MHz = 50;
    localparam  INIT_200US = 200_000/(1000/CLK_FREQ_MHz)+1;

    reg [$clog2(INIT_200US+1)-1:0] init_200us_cnt;

    wire init_start;

    reg [3:0]init_cmd_cnt;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            init_200us_cnt <= 0;
        else if (~init_start) begin
            init_200us_cnt <=init_200us_cnt+1'b1 ;
        end
    end

    assign  init_start= init_200us_cnt>=INIT_200US;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            init_cmd_cnt <= 0;
        end
        else if (init_start && ~sdram_init_done) begin
            init_cmd_cnt<=init_cmd_cnt+1'b1;
        end
    end

    //cmds: CSn     RASn    CASn    WEn
    localparam MODE_REG_SET = 4'b0000;
    localparam NOP = 4'b0111;
    localparam PRECHARGE_ALL_BANK = 4'b0010;
    localparam AUTO_REFRESH = 4'b0001;


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sdram_cmds <= NOP;
        end
        else if (init_start)
        case (init_cmd_cnt)
            1:
                sdram_cmds <= PRECHARGE_ALL_BANK;
            2:
                sdram_cmds <= AUTO_REFRESH;
            6:
                sdram_cmds <= AUTO_REFRESH;
            10:
                sdram_cmds <= MODE_REG_SET;
            default:
                sdram_cmds <= NOP;
        endcase
    end

    //Burst Length = 4, Addressing Mode= Seq, CL=3, Burst write & Burst read
    //注意：这里不能写成init_cmd_cnt==10，因为sdram_cmds是时序逻辑，必须等到下一个时钟沿才能锁存，这样会让sdram_addrs和sdram_cmds错过一个周期
    assign sdram_addrs =
           (sdram_cmds==MODE_REG_SET)? 13'b0000_00_011_0010:
           13'b1111_11111_1111;


    assign sdram_init_done = init_cmd_cnt>=12;

endmodule //sdram_init
