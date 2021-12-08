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

module game ( //TODO: ADD DIFFICULTY (0-2) AND MAP SELECTION (0-3) - SCALING ALREADY IMPLEMENTED
    input  logic        FrameClk, Reset, Continue,
	 input  logic [1:0]  Difficulty,
    input  logic [7:0]  Keycode,
    input  logic [9:0]  DrawX, DrawY,
	 input  logic [39:0] Random,
	 output logic        CarPriority,
	 output logic [1:0]  Map,
	 output logic [5:0]  TextPixel, P1Pixel, P2Pixel, MoneyPixel, CarPixel,
	 output logic [9:0]  LED
);

    // GAME LOGIC

    localparam [15:0] round_duration = 7142; //round duration in frames, ie (int)59.52*seconds
	 logic [15:0] timer;

    enum logic [1:0] { Menu, Game, End } curr_state, next_state; // Internal state logic
		
    always_ff @ (posedge FrameClk)
    begin
        if (Reset)
            curr_state <= Menu;
        else
		  begin
            curr_state <= next_state;
				if (curr_state == Game)
		          timer <= timer + 1'b1;
				else
				    timer <= 15'b0;
		  end
    end
   
    always_comb
    begin 
        // Default next state is staying at current state
        next_state = curr_state;
		  
		  // Assign next state
		  unique case (curr_state)
		      Menu,
				End: // Split this later if adding more states e.g. map selection after Menu
				begin
		          if (Continue) 
		              next_state = Game;
				end
		      Game:
				begin
					 if (timer == round_duration)
						  next_state = End;
				end
		      default : next_state = Menu;
		  endcase
		
        // Calculate CarPriority and CarPixel
		  CarPriority = 1'b1;
	     if (c1Priority)
		  begin
		      carTile   = c2Tile   |  c3Tile  |  c4Tile  |  c5Tile  |  c6Tile  |  c7Tile  |   c8Tile;
		      carPixelX = c2PixelX | c3PixelX | c4PixelX | c5PixelX | c6PixelX | c7PixelX | c8PixelX;
		      carPixelY = c2PixelY | c3PixelY | c4PixelY | c5PixelY | c6PixelY | c7PixelY | c8PixelY;
		      carPriTile   = c1Tile;
				carPriPixelX = c1PixelX;
				carPriPixelY = c1PixelY;
		  end
		  else if (c2Priority)
		  begin
		      carTile   = c1Tile   |  c3Tile  |  c4Tile  |  c5Tile  |  c6Tile  |  c7Tile  |   c8Tile;
		      carPixelX = c1PixelX | c3PixelX | c4PixelX | c5PixelX | c6PixelX | c7PixelX | c8PixelX;
		      carPixelY = c1PixelY | c3PixelY | c4PixelY | c5PixelY | c6PixelY | c7PixelY | c8PixelY;
		      carPriTile   = c2Tile;
				carPriPixelX = c2PixelX;
				carPriPixelY = c2PixelY;
		  end
	     else if (c3Priority)
		  begin
		      carTile   = c1Tile   |  c2Tile  |  c4Tile  |  c5Tile  |  c6Tile  |  c7Tile  |   c8Tile;
		      carPixelX = c1PixelX | c2PixelX | c4PixelX | c5PixelX | c6PixelX | c7PixelX | c8PixelX;
		      carPixelY = c1PixelY | c2PixelY | c4PixelY | c5PixelY | c6PixelY | c7PixelY | c8PixelY;
		      carPriTile   = c3Tile;
				carPriPixelX = c3PixelX;
				carPriPixelY = c3PixelY;
		  end
		  else if (c4Priority)
		  begin
		      carTile   = c1Tile   |  c2Tile  |  c3Tile  |  c5Tile  |  c6Tile  |  c7Tile  |   c8Tile;
		      carPixelX = c1PixelX | c2PixelX | c3PixelX | c5PixelX | c6PixelX | c7PixelX | c8PixelX;
		      carPixelY = c1PixelY | c2PixelY | c3PixelY | c5PixelY | c6PixelY | c7PixelY | c8PixelY;
		      carPriTile   = c4Tile;
				carPriPixelX = c4PixelX;
				carPriPixelY = c4PixelY;
		  end
	     else if (c5Priority)
		  begin
		      carTile   = c1Tile   |  c2Tile  |  c3Tile  |  c4Tile  |  c6Tile  |  c7Tile  |   c8Tile;
		      carPixelX = c1PixelX | c2PixelX | c3PixelX | c4PixelX | c6PixelX | c7PixelX | c8PixelX;
		      carPixelY = c1PixelY | c2PixelY | c3PixelY | c4PixelY | c6PixelY | c7PixelY | c8PixelY;
		      carPriTile   = c5Tile;
				carPriPixelX = c5PixelX;
				carPriPixelY = c5PixelY;
		  end
		  else if (c6Priority)
		  begin
		      carTile   = c1Tile   |  c2Tile  |  c3Tile  |  c4Tile  |  c5Tile  |  c7Tile  |   c8Tile;
		      carPixelX = c1PixelX | c2PixelX | c3PixelX | c4PixelX | c5PixelX | c7PixelX | c8PixelX;
		      carPixelY = c1PixelY | c2PixelY | c3PixelY | c4PixelY | c5PixelY | c7PixelY | c8PixelY;
		      carPriTile   = c6Tile;
				carPriPixelX = c6PixelX;
				carPriPixelY = c6PixelY;
		  end
	     else if (c7Priority)
		  begin
		      carTile   = c1Tile   |  c2Tile  |  c3Tile  |  c4Tile  |  c5Tile  |  c6Tile  |   c8Tile;
		      carPixelX = c1PixelX | c2PixelX | c3PixelX | c4PixelX | c5PixelX | c6PixelX | c8PixelX;
		      carPixelY = c1PixelY | c2PixelY | c3PixelY | c4PixelY | c5PixelY | c6PixelY | c8PixelY;
		      carPriTile   = c7Tile;
				carPriPixelX = c7PixelX;
				carPriPixelY = c7PixelY;
		  end
		  else if (c8Priority)
		  begin
		      carTile   = c1Tile   |  c2Tile  |  c3Tile  |  c4Tile  |  c5Tile  |  c6Tile  |   c7Tile;
		      carPixelX = c1PixelX | c2PixelX | c3PixelX | c4PixelX | c5PixelX | c6PixelX | c7PixelX;
		      carPixelY = c1PixelY | c2PixelY | c3PixelY | c4PixelY | c5PixelY | c6PixelY | c7PixelY;
		      carPriTile   = c8Tile;
				carPriPixelX = c8PixelX;
				carPriPixelY = c8PixelY;
		  end
		  else  //not priority, so dont care about priority var values
		  begin
		      carTile   = c1Tile   |  c2Tile  |  c3Tile  |  c4Tile  |  c5Tile  |  c6Tile  |  c7Tile  |   c8Tile;
		      carPixelX = c1PixelX | c2PixelX | c3PixelX | c4PixelX | c5PixelX | c6PixelX | c7PixelX | c8PixelX;
		      carPixelY = c1PixelY | c2PixelY | c3PixelY | c4PixelY | c5PixelY | c6PixelY | c7PixelY | c8PixelY;
		      carPriTile   = 4'b0;
				carPriPixelX = 6'b0;
				carPriPixelY = 5'b0;
		      CarPriority = 1'b0;
		  end
		  
		  if (c1Pixel | c2Pixel | c3Pixel | c4Pixel | c5Pixel | c6Pixel | c7Pixel | c8Pixel)
		  begin
		      if (CarPriority && carPri_data)
		          CarPixel = carPri_data;
			   else
				    CarPixel = car_data;
		  end
		  else
		      CarPixel = 6'b0;
				
		  // Calculate other output values
		  SpawnEnable = (curr_state == Game);
		  Map = 2'b0;
		  LED = 10'b1111111111 << ((10*timer) / round_duration);
    end 
	 
	 
	 // COMPONENT LOGIC

    logic SpawnEnable;
	 logic [5:0] car_data, carPri_data;
	 logic [9:0] p1X, p1Y, p2X, p2Y;
	
	 logic c1Priority, c2Priority, c3Priority, c4Priority, c5Priority, c6Priority, c7Priority, c8Priority;
	 logic carPixel, c1Pixel, c2Pixel, c3Pixel, c4Pixel, c5Pixel, c6Pixel, c7Pixel, c8Pixel;
	 logic [3:0] carTile, carPriTile, c1Tile, c2Tile, c3Tile, c4Tile, c5Tile, c6Tile, c7Tile, c8Tile;
	 logic [5:0] carPixelX, carPriPixelX, c1PixelX, c2PixelX, c3PixelX, c4PixelX, c5PixelX, c6PixelX, c7PixelX, c8PixelX;
	 logic [4:0] carPixelY, carPriPixelY, c1PixelY, c2PixelY, c3PixelY, c4PixelY, c5PixelY, c6PixelY, c7PixelY, c8PixelY;
	 
	 //Text
	 //text title   ();
	 //text p1win   ();
	 //text p2win   ();
	 //text rematch ();
	 
	 //Players
	 player p1 (.PlayerOne(1'b1), .PlayerX(p1X), .PlayerY(p1Y), .PlayerPixel(P1Pixel), .*);
	 player p2 (.PlayerOne(1'b0), .PlayerX(p2X), .PlayerY(p2Y), .PlayerPixel(P2Pixel), .*);
	 
	 //Cars - Car Speed is set to be inversely proportional to the Car Count to avoid super fast clusters of cars, but this could be tweaked or made into a difficulty thing
	 lane #(.TileY(23)) lane1 (.SpawnEnable(SpawnEnable && Difficulty), .CarPixel(c1Pixel), .CarPriority(c1Priority), .Direction(Random[0]), .CarType(Random[ 9:8 ]), .CarCount(Random[25:24] + 1), .CarSpeed(4 - Random[25:24] + Difficulty),
	                           .Tile(c1Tile), .PixelX(c1PixelX), .PixelY(c1PixelY), .*);
										
	 lane #(.TileY(22)) lane2 (.SpawnEnable(       SpawnEnable       ), .CarPixel(c2Pixel), .CarPriority(c2Priority), .Direction(Random[1]), .CarType(Random[11:10]), .CarCount(Random[27:26] + 1), .CarSpeed(4 - Random[27:26] + Difficulty),
	                           .Tile(c2Tile), .PixelX(c2PixelX), .PixelY(c2PixelY), .*);
										
	 lane #(.TileY(21)) lane3 (.SpawnEnable(SpawnEnable && Difficulty), .CarPixel(c3Pixel), .CarPriority(c3Priority), .Direction(Random[2]), .CarType(Random[13:11]), .CarCount(Random[29:28] + 1), .CarSpeed(4 - Random[29:28] + Difficulty),
	                           .Tile(c3Tile), .PixelX(c3PixelX), .PixelY(c3PixelY), .*);
										
	 lane #(.TileY(20)) lane4 (.SpawnEnable(       SpawnEnable       ), .CarPixel(c4Pixel), .CarPriority(c4Priority), .Direction(Random[3]), .CarType(Random[15:14]), .CarCount(Random[31:30] + 1), .CarSpeed(4 - Random[31:30] + Difficulty),
	                           .Tile(c4Tile), .PixelX(c4PixelX), .PixelY(c4PixelY), .*);
										
	 lane #(.TileY(13)) lane5 (.SpawnEnable(SpawnEnable && Difficulty), .CarPixel(c5Pixel), .CarPriority(c5Priority), .Direction(Random[4]), .CarType(Random[17:16]), .CarCount(Random[33:32] + 1), .CarSpeed(4 - Random[33:32] + Difficulty),
	                           .Tile(c5Tile), .PixelX(c5PixelX), .PixelY(c5PixelY), .*);
										
	 lane #(.TileY(12)) lane6 (.SpawnEnable(       SpawnEnable       ), .CarPixel(c6Pixel), .CarPriority(c6Priority), .Direction(Random[5]), .CarType(Random[19:18]), .CarCount(Random[35:34] + 1), .CarSpeed(4 - Random[35:34] + Difficulty),
	                           .Tile(c6Tile), .PixelX(c6PixelX), .PixelY(c6PixelY), .*);
										
	 lane #(.TileY(11)) lane7 (.SpawnEnable(SpawnEnable && Difficulty), .CarPixel(c7Pixel), .CarPriority(c7Priority), .Direction(Random[6]), .CarType(Random[21:20]), .CarCount(Random[37:36] + 1), .CarSpeed(4 - Random[37:36] + Difficulty),
	                           .Tile(c7Tile), .PixelX(c7PixelX), .PixelY(c7PixelY), .*);
										
	 lane #(.TileY(10)) lane8 (.SpawnEnable(       SpawnEnable       ), .CarPixel(c8Pixel), .CarPriority(c8Priority), .Direction(Random[7]), .CarType(Random[23:22]), .CarCount(Random[39:38] + 1), .CarSpeed(4 - Random[39:38] + Difficulty),
	                           .Tile(c8Tile), .PixelX(c8PixelX), .PixelY(c8PixelY), .*);
	 
    //moneys
	 //money money1 ();
	 //money money2 ();
	 //money money3 ();
	 //money money4 ();
	 //money money5 ();
	 
	 // ROM
	 car_rom carRom    (.Tile(carTile),  .PixelX(carPixelX),  .PixelY(carPixelY),  .Data(car_data) ); //used for retrieving the palette addr for a given car tile
	 car_rom carPriRom (.Tile(carPriTile), .PixelX(carPriPixelX), .PixelY(carPriPixelY), .Data(carPri_data)); //used for retrieving the palette addr for a given priority car tile
	
endmodule
