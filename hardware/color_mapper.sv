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
    input  logic       Blank, CarPriority, PlayerPriority,
	 input  logic [1:0] Map,
    input  logic [9:0] DrawX, DrawY,
	 input  logic [5:0] TextPixel, PlayerPixel, MoneyPixel, CarPixel, //all of these should be palette indices, not 32 bit ARGB values.
	 output logic [7:0] Red, Green, Blue
);

    // LOCAL LOGIC
	 
	 logic mapPixel;
	 logic [5:0]  tileX, tileY;
	 logic [10:0] tileIdx;
	 logic [5:0]  map_data;
	 logic [5:0]  palette_addr;
	 logic [23:0] palette_data;

	 
	 // OUTPUT LOGIC
	 
	 always_comb
	 begin:RGB_Calculations
	 
	     // Calculate map pixel for the current x,y coordinate
		  
	     //convert x,y to tilex,tiley by shifting right 4 times (same as dividing by 2^4=16px)
	     tileX     = DrawX[9:4]; //same as DrawX >> 4
		  tileY     = DrawY[9:4]; //same as DrawY >> 4
		  //convert tilex,tiley to 1d index multiplied by map number
		  tileIdx   = (Map + 1'b1) * (11'd40 * tileY + tileX); //multiply tileY by 40 because 40 tiles per row
		  mapPixel  = !(TextPixel || PlayerPixel || MoneyPixel || CarPixel);
		  
		  
		  // Calculate whether the current x,y coordinate corresponds to a lamp
		  
		  for (int x = 38; x <= 598; x += 112)     //lamps are 112px apart horizontally, starting from 38
		  begin
		      for (int y = 98; y <= 258; y += 160) //lamps are 160px apart vertically, starting from 98
		      begin
				    mapPixel |= (x     <= DrawX && DrawX <= x + 3) && (y     <= DrawY && DrawY <= y + 29); //check if pixel is in lamp body
		          mapPixel |= (x - 1 <= DrawX && DrawX <= x + 4) && (y + 3 <= DrawY && DrawY <= y + 7 ); //check if pixel is in lamp head sides
		          mapPixel |= (x + 1 <= DrawX && DrawX <= x + 2) && (         y - 1 == DrawY          ); //check if pixel is in lamp head top
		      end
		  end
		  
		  
		  // Determine which color to actually use, based on priority: text > streetlights > players* > cars > moneys        *(players > cars only when their hitbox is lower)
		  
		  if (TextPixel)
		  begin
				palette_addr = TextPixel;
		  end
		  else if (mapPixel)
		  begin
		      palette_addr = map_data;
		  end
		  else if (PlayerPixel || CarPixel)
		  begin
            if (CarPixel && (!PlayerPixel || (CarPriority && !PlayerPriority)))
				    palette_addr = CarPixel;
				else
				    palette_addr = PlayerPixel;
		  end
		  else
				palette_addr = MoneyPixel;
		  
		  
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
	 
	 
    // MODULE INSTANTIATION
	 
	 palette_rom palette (.Color(palette_addr), .Data(palette_data)); //used for getting the colors corresponding to a given index
	 map_rom     map     (.Tile(tileIdx), .PixelX(DrawX[3:0]), .PixelY(DrawY[3:0]), .Data(map_data)); //used for retrieving the palette addr for a given map tile
	 
endmodule
