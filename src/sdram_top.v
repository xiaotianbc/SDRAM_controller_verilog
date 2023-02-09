module sdram_top (
        input      clk_raw,     //raw clk input
        input      rst_n,

        // to SDRAM PHY
        output   reg   CSn,
        output   reg   RASn,
        output   reg   CASn,
        output   reg   WEn,

        output   reg   [12:0]SDRAM_ADDR,
        output    [15:0]SDRAM_DQ,
        output    [1:0]SDRAM_BS,
        output    [1:0]SDRAM_DQM,
        output         SDRAM_CLK,
        output         SDRAM_CKE
    );

    //----------------------------------------------------------------------
    //***************     CLK = 50MHz 生成模块 **************************
    //----------------------------------------------------------------------
    wire 	clk;
    wire 	clk_P;      //相位后移180度的时钟

    generate_clk u_generate_clk(
                     //ports
                     .clk_raw   		( clk_raw   		),
                     .clk_50M   		( clk   		),
                     .clk_50M_P 		( clk_P 		)
                 );


    //----------------------------------------------------------------------
    //***************    ArBiter  //仲裁状态机 **************************
    //----------------------------------------------------------------------

    // 网络命名方法： sdram_所属模块名称_网络名称
    //例子：  sdram_init_done_flag, sdram_aref_req, etc..

    localparam STATE_INIT   =   5'b00001;        //上电后初始化状态
    localparam STATE_ARBIT  =   5'b00010;        //仲裁状态
    localparam STATE_AREF   =   5'b00100;        //自动刷新状态
    localparam STATE_WRITE  =   5'b01000;        //写状态
    localparam STATE_READ   =   5'b10000;        //读状态

    // ******************   init 模块网络 *******************
    //cmds: CSn     RASn    CASn    WEn
    wire [3:0]	sdram_init_cmds;
    wire 	sdram_init_done_flag;
    wire [12:0]sdram_init_addrs;
    // ******************  end init 模块网络 ****************

    // ******************   aref 模块网络 *******************
    //cmds: CSn     RASn    CASn    WEn
    wire [3:0]	    sdram_aref_cmds;
    wire [12:0]     sdram_aref_addrs;

    wire 	sdram_aref_done_flag;
    wire     sdram_aref_req;
    reg     sdram_aref_en;
    // ******************  end aref 模块网络 ****************

    reg [4:0] state, next;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state<= STATE_INIT;
        end
        else begin
            state <= next;
        end
    end

    always @(*) begin
        case (state)
            STATE_INIT:
                next=sdram_init_done_flag?STATE_ARBIT:STATE_INIT;
            STATE_ARBIT:
                next=sdram_aref_en?STATE_AREF:STATE_ARBIT;
            STATE_AREF:
                next=sdram_aref_done_flag?STATE_ARBIT:STATE_AREF;
            default:
                next=STATE_ARBIT;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sdram_aref_en<= 0;
        end
        else begin
            if (state ==STATE_ARBIT && sdram_aref_req ) begin
                sdram_aref_en<= 1'b1;
            end
            else begin
                sdram_aref_en<= 1'b0;
            end
        end
    end


    always @(*) begin
        case (state)
            STATE_INIT: begin
                {CSn,RASn,CASn,WEn}=sdram_init_cmds;
                SDRAM_ADDR=sdram_init_addrs;
            end
            STATE_AREF: begin
                {CSn,RASn,CASn,WEn}=sdram_aref_cmds;
                SDRAM_ADDR=sdram_aref_addrs;
            end

            default:  begin
                {CSn,RASn,CASn,WEn}=sdram_aref_cmds;
                SDRAM_ADDR=sdram_aref_addrs;
            end
        endcase
    end


    assign SDRAM_DQM=2'b00;  //暂时不使用DQM

    assign SDRAM_CLK=clk_P; // clk延迟半个时钟周期，让数据稳定

    assign SDRAM_CKE=1'b1;      //enable 高电平有效

    assign SDRAM_BS=2'b00; // bank select

    sdram_init u_sdram_init(
                   //ports
                   .clk             		( clk             		),
                   .rst_n           		( rst_n           		),
                   .sdram_cmds      		( sdram_init_cmds      		),
                   .sdram_addrs     		( sdram_init_addrs     		),
                   .sdram_init_done 		( sdram_init_done_flag 		)
               );




    sdram_aref u_sdram_aref(
                   //ports
                   .clk             		( clk             		),
                   .rst_n           		( rst_n           		),
                   .sdram_cmds      		( sdram_aref_cmds      		),
                   .sdram_addrs     		( sdram_aref_addrs     		),
                   .sdram_aref_req  		( sdram_aref_req  		),
                   .sdram_aref_en   		( sdram_aref_en   		),
                   .sdram_aref_done 		( sdram_aref_done_flag 		),
                   .sdram_init_done_flag    (sdram_init_done_flag)
               );



endmodule //sdram_top
