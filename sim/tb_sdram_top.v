`timescale 1ns/100ps
module tb_sdram_top();
    reg clk;
    reg rst_n;


    //Instance
    wire 	CSn;
    wire 	RASn;
    wire 	CASn;
    wire 	WEn;
    wire [12:0]	SDRAM_ADDR;
    wire [15:0]	SDRAM_DQ;
    wire [1:0]	SDRAM_BS;
    wire [1:0]	SDRAM_DQM;
    wire 	SDRAM_CLK;
    wire 	SDRAM_CKE;


    always #10 clk=~clk;  // freq=50MHz

    initial begin
        rst_n=0;
        clk=1;
        # 100
          rst_n=1;
    end

    sdram_top u_sdram_top(
                  //ports
                  .clk_raw(clk),     //50MHz
                  .rst_n      		( rst_n      		),
                  .CSn        		( CSn        		),
                  .RASn       		( RASn       		),
                  .CASn       		( CASn       		),
                  .WEn        		( WEn        		),
                  .SDRAM_ADDR 		( SDRAM_ADDR 		),
                  .SDRAM_DQ   		( SDRAM_DQ   		),
                  .SDRAM_BS   		( SDRAM_BS   		),
                  .SDRAM_DQM  		( SDRAM_DQM  		),
                  .SDRAM_CLK  		( SDRAM_CLK  		),
                  .SDRAM_CKE  		( SDRAM_CKE  		)
              );

    sdram_model_plus #(
                         .addr_bits     		( 13          		),
                         .data_bits     		( 16          		),
                         .col_bits      		( 9           		),
                         .mem_sizes     		( 1024*1024*2-1 	))
                     u_sdram_model_plus(
                         //ports
                         .Dq    		( SDRAM_DQ    		),
                         .Addr  		( SDRAM_ADDR  		),
                         .Ba    		( SDRAM_BS    		),
                         .Clk   		( SDRAM_CLK   		),
                         .Cke   		( SDRAM_CKE   		),
                         .Cs_n  		( CSn  		),
                         .Ras_n 		( RASn 		),
                         .Cas_n 		( CASn 		),
                         .We_n  		( WEn  		),
                         .Dqm   		( SDRAM_DQM   		),
                         .Debug 		( 1'b1 		)
                     );


endmodule  //TOP
