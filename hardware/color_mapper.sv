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

module color_mapper (
    input  logic       Blank,
    input  logic [9:0] DrawX, DrawY, P1X, P1Y, P2X, P2Y,
	 output logic [7:0] Red, Green, Blue
);

    // Declare local variables
	 logic [5:0]  tile_x, tile_y;
	 logic [10:0] map_addr;
	 logic [55:0] map_data;
	 logic [11:0] tile_addr;
	 logic [47:0] tile_data;
	 logic [2:0]  tile_color;
	 logic [5:0]  palette_addr;
	 logic [23:0] palette_data;

    // Module instantiation
	 map_rom map (
	     //INPUTS
	     .addr(map_addr),      // Address of desired tile
		  
		  //OUTPUTS
		  .data(map_data)       // Data of desired tile
	 );
	 
	 tile_rom tiles (
	     //INPUTS
	     .addr(tile_addr),     // Address of desired tile
		  
		  //OUTPUTS
		  .data(tile_data)      // Data of desired tile
    );
	 
	 palette_rom palette (
	     //INPUTS
	     .addr(palette_addr),  // Address of desired tile
		  
		  //OUTPUTS
		  .data(palette_data)   // Data of desired tile
	 );
	 
	 always_comb
	 begin:RGB_Calculations
	 
	     // Calculate all possible colors for this this x,y
		  
	     //convert x,y to tilex,tiley by shifting right 4 times (same as dividing by 2^4=16px)
	     tile_x = DrawX >> 4;
		  tile_y = DrawY >> 4;
		  //convert tilex,tiley to 1d index (map_addr)
		  map_addr  = 40 * tile_y + tile_x;               //multiply tiley by 40 because 40 tiles per row
        tile_addr = 16 * map_data[47:40] + DrawY[3:0];  //multiply tile_code by 16 and add y mod 16 to get tile_addr
		  //get tile pixel color by inverting the desired pixel then multiplying by 3 since we use 3 bits per pixel
		  tile_color = tile_data[3*(15-DrawX[3:0]) +: 3]; //bit-slicing (+:) operator to select 3 bits starting from position of desired 3 bits
		  
		  
		  // Determine which color to actually use
		  
		  if (1'b0) //if lamp pixel OR (map pixel && !(player || car))
		  begin:Map
		      palette_addr = 6'b0;//map_data[tile_color ]; //paint map pixel
		  end
		  else
		  begin:PlayerOrCar
            if (1'b0) //if !car OR [(player AND car) and (player feet tileY > car wheels tileY)]
				begin
				    palette_addr = 6'b0; //paint player pixel
				end
				else //else, must be car or car is lower than player
				begin
				    palette_addr = 6'b0; //paint car pixel
				end
		  end
		  
		  
		  // Assign RGB outputs based on previous calculations
		  
		  if (~Blank)
		  begin:Blanking
            Red   = 8'h0;
            Green = 8'h0;
            Blue  = 8'h0;
		  end
        else
        begin:Color
		      Red   = palette_data[23:16];
		      Green = palette_data[15:8];
		      Blue  = palette_data[7:0];
        end
		  
	 end
	 
endmodule
