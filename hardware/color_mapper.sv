//-------------------------------------------------------------------------
// ECE 385 Final Project                                                 --
// mse6 and vragau2                                                      --
// Fall 2021                                                             --
//                            CROSSY ROBBERS                             --
//                        VGA Text-AVL Interface                         --
//                                                                       --
//          EDIT THIS DESCRIPTION LATER ONCE STRUCTURE FINALISED         --
//                                                                       --
//                                                                       --
//-------------------------------------------------------------------------

/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/

module vga_text_avl_interface (
    // Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
    // We can put a clock divider here in the future to make this IP more generalizable
    input logic CLK,
	
	 // Avalon Reset Input
	 input logic RESET,
	
	 // Avalon-MM Slave Signals
	 input  logic AVL_READ,					     // Avalon-MM Read
	 input  logic AVL_WRITE,				     // Avalon-MM Write
	 input  logic AVL_CS,					     // Avalon-MM Chip Select
	 input  logic [3:0]  AVL_BYTE_EN,	     // Avalon-MM Byte Enable
	 input  logic [11:0] AVL_ADDR,			  // Avalon-MM Address
	 input  logic [31:0] AVL_WRITEDATA,	     // Avalon-MM Write Data
	 output logic [31:0] AVL_READDATA,	     // Avalon-MM Read Data
	
	 // Exported Conduit (mapped to VGA port)
	 output logic [3:0]  red, green, blue,   // VGA color channels (mapped to output pins in top-level)
	 output logic hs, vs						     // VGA HS/VS
);

    // Declare local variables
    logic [31:0] PALETTE [8];               // Color pallete registers (2 colors per reg, 16 total)
	 logic [31:0] VGA_READDATA;              // RAM read data
	 
	 logic        pixel_clk, blank, sync;    // VGA controller output signals
	 logic [9:0]  drawX, drawY;              // VGA controller output coords
	 logic [10:0] sprite_addr;               // Font ROM input address
	 logic [7:0]  sprite_data;               // Font ROM output data
	 
	 logic [9:0]  tile_x, tile_y;            // Sprite tile positions for drawing logic
	 logic [10:0] index;                     // One dimensional representation of tile_x,tile_y
	 logic        vram_x;                    // VRAM x coordinate to find stored sprite data
	 logic [10:0] vram_y;                    // VRAM y coordinate to find stored sprite data
	 logic        inverted;                  // Sprite invert bit attained from VRAM for drawing logic
	 logic [6:0]  sprite_code;               // Sprite code attained from VRAM for drawing logic
	 logic [4:0]  fgd_idx, bgd_idx;          // Sprite foreground and background indices for palette, from VRAM
    
    // Declare submodules (VGA controller, Font ROM, and RAM)
	 vga_controller vgacontroller (
	     //INPUTS
	     .Clk(CLK),               // 50 MHz clock
        .Reset(RESET),           // reset signal
		  
		  //OUTPUTS
        .hs(hs),                 // Horizontal sync pulse.  Active low.
		  .vs(vs),                 // Vertical sync pulse.  Active low.
		  .pixel_clk(pixel_clk),   // 25 MHz pixel clock output.
		  .blank(blank),           // Blanking interval indicator.  Active low.
		  .sync(sync),             // Composite Sync signal.  Active low.  We don't use it in this lab, but the video DAC on the DE2 board requires an input for it.
		  .DrawX(drawX),           // horizontal coordinate
		  .DrawY(drawY)            // vertical coordinate
    );
	 
	 font_rom rom (
	     //INPUTS
	     .addr(sprite_addr),      // Address of desired sprite
		  
		  //OUTPUTS
		  .data(sprite_data)       // Data of desired sprite
    );
	 
	 ram vram ( //only need to write VRAM from AVL, only need to read VRAM from VGA, so this setup is fine
	     //INPUTS
		  .clock(CLK),
		  .wraddress(AVL_ADDR[10:0]),
		  .byteena_a(AVL_BYTE_EN),
		  .data(AVL_WRITEDATA),
		  .wren(~AVL_ADDR[11] & AVL_WRITE & AVL_CS),
		  .rdaddress(vram_y),
		  
		  //OUTPUTS
		  .q(VGA_READDATA)
	 );
	 
	 
	 // Read and write from AVL interface to Palette
    always_ff @(posedge CLK) begin
	     if (RESET)
		      PALETTE <= '{default:'0}; //'default' keyword says that PALETTE array should be assigned a "default" value (0 in this case)
		  else if (AVL_CS & AVL_ADDR[11]) //if palette
		  begin
		      if (AVL_READ)
                AVL_READDATA <= PALETTE[AVL_ADDR[2:0]];
	    		if (AVL_WRITE)
		    	    PALETTE[AVL_ADDR[2:0]] <= AVL_WRITEDATA;
        end
    end
	 
	 
    // Handle drawing (may either be combinational or sequential - or both).
	 always_comb
	 begin:VRAM_calculations
	     //convert x,y to charx,chary
	     tile_x = drawX >> 3; //shifting right 3 times is the same as dividing by 2^3=8px
		  tile_y = drawY >> 4; //shift right 4 times to divide by 16px
		  //convert charx,chary to vramx,vramy
		  index  = 80 * tile_y + tile_x; //get one dimensional index to convert to vram coords
		  vram_x = index[0]; //index mod 2 to get correct char
        vram_y = index >> 1; //index divide by 2
        inverted    = VGA_READDATA[(16*vram_x + 15)];
        sprite_code = VGA_READDATA[(16*vram_x + 8) +: 7];  //bit-slicing (+:) operator tells us to start from variable bit and count up a constant (so this is from 15*vram_x+8 to 15*vram_x+6 inclusive)
		  fgd_idx     = VGA_READDATA[(16*vram_x + 4) +: 4];  //4->4+3 (4->7) if vram_x is 0, 16+4->16+4+3 (20->23) if vram_x is 1
		  bgd_idx     = VGA_READDATA[16*vram_x +: 4];        //0->0+3 (0->3) if vram_x is 0,  16 ->16+3   (16->19) if vram_x is 1
		  sprite_addr = (drawY[3:0] + 16*sprite_code);       //set the address for the desired sprite from ROM
	 end
       
    always_ff @(posedge pixel_clk)
    begin:RGB_Display
	     if (~blank)
		  begin:blanking
            red   <= 4'h0;
            green <= 4'h0;
            blue  <= 4'h0;
		  end                  //7- to invert, drawX mod 4 to get correct bit
        else if (sprite_data[7 - drawX[2:0]] ^ inverted) //foreground if draw bit and NOT inverted or NOT draw bit and inverted, thus XOR'd
        begin:foreground
		      if (fgd_idx[0]) //if index mod 2 == 1
				begin
                red   <= PALETTE[fgd_idx[3:1]][24:21]; //using [3:1] to avoid dividing by 2 or shifting
                green <= PALETTE[fgd_idx[3:1]][20:17];
                blue  <= PALETTE[fgd_idx[3:1]][16:13];
				end
				else
				begin
                red   <= PALETTE[fgd_idx[3:1]][12:9];
                green <= PALETTE[fgd_idx[3:1]][8:5];
                blue  <= PALETTE[fgd_idx[3:1]][4:1];
				end
        end       
        else 
        begin:background
		      if (bgd_idx[0]) //if index mod 2 == 1
				begin
                red   <= PALETTE[bgd_idx[3:1]][24:21];
                green <= PALETTE[bgd_idx[3:1]][20:17];
                blue  <= PALETTE[bgd_idx[3:1]][16:13];
				end
				else
				begin
                red   <= PALETTE[bgd_idx[3:1]][12:9];
                green <= PALETTE[bgd_idx[3:1]][8:5];
                blue  <= PALETTE[bgd_idx[3:1]][4:1];
				end
        end
    end
	 
endmodule
