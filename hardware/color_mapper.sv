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
    input  logic        Blank, CarTopHalf,
    input  logic [9:0]  DrawX, DrawY,
	 input  logic [5:0]  TextPixel, P1Pixel, P2Pixel, MoneyPixel, CarPixel, //all of these should be palette indices, not 32 bit ARGB values.
	 output logic [7:0]  Red, Green, Blue
);

    // Declare local variables
	 parameter bit [9:0] lampX    [6] = '{6,118,230,374,486,598};
	 parameter bit       lampY    [2] = '{98,258};
	 parameter bit [9:0] trafficX [2] = '{38,630};
	 parameter bit       trafficY [2] = '{98,258};
	 
	 logic mapPixel, playerPixel;
	 logic [5:0]  tile_x, tile_y;
	 logic [10:0] map_addr;
	 logic [55:0] map_data;
	 logic [11:0] tile_addr;
	 logic [47:0] tile_data;
	 logic [2:0]  tile_color;
	 logic [5:0]  palette_addr;
	 logic [23:0] palette_data;

    // Module instantiation
	 map_rom     map     (.addr(map_addr),     .data(map_data)    ); //used for finding the tile and palette indices of a given tile
	 tile_rom    tiles   (.addr(tile_addr),    .data(tile_data)   ); //used for getting the bitmap of a given tile
	 palette_rom palette (.addr(palette_addr), .data(palette_data)); //used for getting the colors corresponding to a given tile
	 
	 always_comb
	 begin:RGB_Calculations
	 
	     // Calculate map pixel for the current x,y coordinate
		  
	     //convert x,y to tilex,tiley by shifting right 4 times (same as dividing by 2^4=16px)
	     tile_x     = DrawX >> 4;
		  tile_y     = DrawY >> 4;
		  //convert tilex,tiley to 1d index (map_addr)
		  map_addr   = 40 * tile_y + tile_x;               //multiply tiley by 40 because 40 tiles per row
        tile_addr  = 16 * map_data[7:0] + DrawY[3:0];    //multiply tile_code by 16 and add y mod 16 to get tile_addr
		  //get tile pixel color by inverting the desired pixel then multiplying by 3 since we use 3 bits per pixel
		  tile_color = tile_data[3*(15-DrawX[3:0]) +: 3]; //bit-slicing (+:) operator to select 3 bits starting from position of desired 3 bits
		  mapPixel   = !(TextPixel || P1Pixel || P2Pixel || MoneyPixel || CarPixel);
		  
		  
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
		      palette_addr = map_data[6*tile_color+8 +: 6];   //multiply color by 6 because we use 6 bits per color, then bit-slice to get correct bits
		  end
		  else if (playerPixel || CarPixel)
		  begin:PlayerOrCar
            if (CarPixel && (!playerPixel || CarTopHalf))
				begin
				    palette_addr = CarPixel;
				end
				else
				begin
				    palette_addr = (P1Pixel) ? P1Pixel : P2Pixel; //player pixels can overlap, so give priority to P1's pixel
				end
		  end
		  else
		  begin:money
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
