//-------------------------------------------------------------------------
// ECE 385 Final Project                                                 --
// mse6 and vragau2                                                      --
// Fall 2021                                                             --
//                            CROSSY ROBBERS                             --
//                             Color Mapper                              --
//                                                                       --
//          EDIT THIS DESCRIPTION LATER ONCE STRUCTURE FINALISED         --
//                                                                       --
//                                                                       --
//-------------------------------------------------------------------------


module color_mapper (
    input  logic       Blank, CarPriority,
	 input  logic [1:0] Map,
    input  logic [9:0] DrawX, DrawY,
	 input  logic [5:0] TextPixel, P1Pixel, P2Pixel, MoneyPixel, CarPixel, //all of these should be palette indices, not 32 bit ARGB values.
	 output logic [7:0] Red, Green, Blue
);

    // Declare local variables
	 localparam bit [9:0] lampX    [6] = '{6,118,230,374,486,598};
	 localparam bit       lampY    [2] = '{98,258};
	 localparam bit [9:0] trafficX [2] = '{38,630};
	 localparam bit       trafficY [2] = '{98,258};
	 
	 logic mapPixel, playerPixel;
	 logic [5:0]  tileX, tileY;
	 logic [10:0] tileIdx;
	 logic [5:0]  map_data;
	 logic [5:0]  palette_addr;
	 logic [23:0] palette_data;

    // Module instantiation
	 palette_rom palette (.Color(palette_addr), .Data(palette_data)); //used for getting the colors corresponding to a given index
	 map_rom     map     (.Tile(tileIdx), .PixelX(DrawX[3:0]), .PixelY(DrawY[3:0]), .Data(map_data)); //used for retrieving the palette addr for a given map tile
	 
	 always_comb
	 begin:RGB_Calculations
	 
	     // Calculate map pixel for the current x,y coordinate
		  
	     //convert x,y to tilex,tiley by shifting right 4 times (same as dividing by 2^4=16px)
	     tileX     = DrawX >> 4;
		  tileY     = DrawY >> 4;
		  //convert tilex,tiley to 1d index multiplied by map number
		  tileIdx   = (Map + 1) * (40 * tileY + tileX); //multiply tileY by 40 because 40 tiles per row
		  mapPixel  = !(TextPixel || P1Pixel || P2Pixel || MoneyPixel || CarPixel);
		  
		  
		  // Calculate whether the current x,y coordinate corresponds to a lamp or traffic light
		  
		  for (int x = 0; x < $size(lampX); x++)
		  begin
		      for (int y = 0; y < $size(lampY); y++)
		      begin
				    mapPixel |= (x     <= DrawX && DrawX <= x + 3) && (y     <= DrawY && DrawY <= y + 29); //check if pixel is in lamp body
		          mapPixel |= (x - 1 <= DrawX && DrawX <= x + 4) && (y + 3 <= DrawY && DrawY <= y + 7 ); //check if pixel is in lamp head sides
		          mapPixel |= (x + 1 <= DrawX && DrawX <= x + 2) && (         y - 1 == DrawY          ); //check if pixel is in lamp head top
		      end
		  end
		  for (int x = 0; x < $size(trafficX); x++)
		  begin
		      for (int y = 0; y < $size(trafficY); y++)
		      begin
				    mapPixel |= (x     <= DrawX && DrawX <= x + 3) && (y     <= DrawY && DrawY <= y + 29); //check if pixel is in traffic light body
		          mapPixel |= (x + 1 <= DrawX && DrawX <= x + 5) && (y - 1 <= DrawY && DrawY <= y + 8 ); //check if pixel is in traffic light head core
		          mapPixel |= (x + 3 <= DrawX && DrawX <= x + 4) && (y - 5 <= DrawY && DrawY <= y - 2 ); //check if pixel is in traffic light head top
		          mapPixel |= (         x + 5 == DrawX         ) && (y - 3 <= DrawY && DrawY <= y - 2 ); //check if pixel is in traffic light head top right
		          mapPixel |= (         x + 6 == DrawX         ) && (y - 2 <= DrawY && DrawY <= y + 5 )  //check if pixel is in traffic light head side
					                                                && (y     != DrawY && DrawY != y + 3 );
		      end
		  end
		  
		  
		  // Determine which color to actually use, based on priority: text > streetlights > players* > cars > moneys        *(players > cars only when their hitbox is lower)
		  
		  playerPixel = P1Pixel || P2Pixel;
		  
		  if (TextPixel)
		  begin:Text
				palette_addr = TextPixel;
		  end
		  else if (mapPixel)
		  begin:LightOrMap
		      palette_addr = map_data;
		  end
		  else if (playerPixel || CarPixel)
		  begin:PlayerOrCar
            if (CarPixel && (!playerPixel || CarPriority))
				begin
				    palette_addr = CarPixel;
				end
				else
				begin
				    palette_addr = (P1Pixel) ? P1Pixel : P2Pixel; //player pixels can overlap, so give priority to P1's pixel
				end
		  end
		  else
		  begin:Money
				palette_addr = MoneyPixel;
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
