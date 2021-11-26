//-------------------------------------------------------------------------
// ECE 385 Final Project                                                 --
// mse6 and vragau2                                                      --
// Fall 2021                                                             --
//                            CROSSY ROBBERS                             --
//                           Top-level Entity                            --
//                                                                       --
//          This file connects all of the modules for our game.          --
//                                                                       --
//                                                                       --
//-------------------------------------------------------------------------


module crossy_robbers (

      ///////// Clocks /////////
      input    MAX10_CLK1_50,

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,

		
      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 
		
);

//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [7:0] red, green, blue;
	logic [7:0] keycode;
	
   logic Reset_h, blank, sync, pixel_clk;
	logic [9:0] draw_x, draw_y;

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ;
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]);

	//Our A/D converter is only 12 bit
	assign VGA_R = red[7:4];
	assign VGA_G = green[7:4];
	assign VGA_B = blue[7:4];

	//assign signs = 2'b00;
	//assign hex_num_4 = 4'h4;
	//assign hex_num_3 = 4'h3;
	//assign hex_num_1 = 4'h1;
	//assign hex_num_0 = 4'h0;
	
	crossy_robbers_soc cr0 (
		.clk_clk                           (MAX10_CLK1_50),   //clk.clk
		.reset_reset_n                     (1'b1),            //reset.reset_n
		.altpll_0_locked_conduit_export    (),    			   //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (), 				   //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),     			   //altpll_0_areset_conduit.export
		.key_external_connection_export    (KEY),    		   //key_external_connection.export

		//SDRAM
		.sdram_clk_clk    (DRAM_CLK),            				   //clk_sdram.clk
	   .sdram_wire_addr  (DRAM_ADDR),               			//sdram_wire.addr
		.sdram_wire_ba    (DRAM_BA),                			   //.ba
		.sdram_wire_cas_n (DRAM_CAS_N),              		   //.cas_n
		.sdram_wire_cke   (DRAM_CKE),                 			//.cke
		.sdram_wire_cs_n  (DRAM_CS_N),                		   //.cs_n
		.sdram_wire_dq    (DRAM_DQ),                  			//.dq
		.sdram_wire_dqm   ({DRAM_UDQM,DRAM_LDQM}),            //.dqm
		.sdram_wire_ras_n (DRAM_RAS_N),              		   //.ras_n
		.sdram_wire_we_n  (DRAM_WE_N),                		   //.we_n

		//USB SPI	
		.spi0_SS_n (SPI0_CS_N),
		.spi0_MOSI (SPI0_MOSI),
		.spi0_MISO (SPI0_MISO),
		.spi0_SCLK (SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export (USB_RST),
		.usb_irq_export (USB_IRQ),
		.usb_gpx_export (USB_GPX),
		
		//LEDs and HEX
		.hex_digits_export ({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		.leds_export       ({hundreds, signs, LEDR}),
		.keycode_export    (keycode)
	 );
	 
	 vga_controller vgacontroller (
	     //INPUTS
	     .Clk(MAX10_CLK1_50),     // 50 MHz clock
        .Reset(Reset_h),         // reset signal
		  
		  //OUTPUTS
        .hs(VGA_HS),             // Horizontal sync pulse.  Active low.
		  .vs(VGA_VS),             // Vertical sync pulse.  Active low.
		  .pixel_clk(pixel_clk),   // 25 MHz pixel clock output.
		  .blank(blank),           // Blanking interval indicator.  Active low.
		  .sync(sync),             // Composite Sync signal.  Active low.  We don't use it in this lab, but the video DAC on the DE2 board requires an input for it.
		  .DrawX(draw_x),          // horizontal coordinate
		  .DrawY(draw_y)           // vertical coordinate
    );
	 
	 /*player p1 (
	     //INPUTS
	     .frame_clk(VGA_VS),      //using vs as frame clock because it cycles when a full frame has been drawn (width then height)
		  .keycode(keycode),
		  .isPlayerOne(1'b1),
					
        //OUTPUTS
        .PlayerX(p1_x),
		  .PlayerY(p1_y),
		  .PlayerScore(p1_score)
    );
	 player p2 (
	     //INPUTS
	     .frame_clk(VGA_VS),      //using vs as frame clock because it cycles when a full frame has been drawn (width then height)
		  .keycode(keycode),
		  .isPlayerOne(1'b0),
					
        //OUTPUTS
        .PlayerX(p2_x),
		  .PlayerY(p2_y),
		  .PlayerScore(p2_score)
    );*/
	 
	 color_mapper colormapper (
	     //INPUTS
		  .Blank(blank),
		  .DrawX(draw_x), 
		  .DrawY(draw_y), 
	     /*.P1X(p1_x),
		  .P1Y(p1_y),
	     .P2X(p2_x),
		  .P2Y(p2_y),*/
		  
        //OUTPUTS
		  .Red(red), 
		  .Green(green), 
		  .Blue(blue)
    );

endmodule
