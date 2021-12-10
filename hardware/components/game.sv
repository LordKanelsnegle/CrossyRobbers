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
	 output logic        PlayerPriority,
	 output logic [1:0]  Map,
	 output logic [5:0]  TextPixel, PlayerPixel, MoneyPixel, CarPixel,
	 output logic [3:0]  HEX3, HEX2, HEX1, HEX0,
	 output logic [9:0]  LED
);

    // LOCAL LOGIC

	 localparam [2:0]  tilesPerAnim = 3'd6;
	 localparam [2:0]  framesPerTile = 3'd5;  //roughly equivalent to 12fps (60/5 = 12)
	 localparam [5:0]  lane1Tile     = 6'd23;
	 localparam [5:0]  lane2Tile     = 6'd22;
	 localparam [5:0]  lane3Tile     = 6'd21;
	 localparam [5:0]  lane4Tile     = 6'd20;
	 localparam [5:0]  lane5Tile     = 6'd13;
	 localparam [5:0]  lane6Tile     = 6'd12;
	 localparam [5:0]  lane7Tile     = 6'd11;
	 localparam [5:0]  lane8Tile     = 6'd10;
	 localparam [9:0]  titleWidth    = 10'd376;
	 localparam [9:0]  titleHeight   = 10'd152;
	 localparam [9:0]  titleX        = 10'd420 - titleWidth[9:1];   //same as width/2
	 localparam [9:0]  titleY        = 10'd40;
	 localparam [9:0]  winWidth      = 10'd327;
	 localparam [9:0]  winHeight     = 10'd57;
	 localparam [9:0]  winX          = 10'd420 - winWidth[9:1];     //same as width/2
	 localparam [9:0]  winY          = 10'd60;
	 localparam [9:0]  animWidth     = 10'd115;
	 localparam [9:0]  animHeight    = 10'd225;
	 localparam [9:0]  animX         = 10'd420 - animWidth[9:1];    //same as width/2
	 localparam [9:0]  animY         = 10'd136;
	 localparam [9:0]  rematchWidth  = 10'd399;
	 localparam [9:0]  rematchHeight = 10'd43;
	 localparam [9:0]  rematchX      = 10'd420 - rematchWidth[9:1]; //same as width/2
	 localparam [9:0]  rematchY      = 10'd400;
    localparam [15:0] roundDuration = 16'd7142; //round duration in frames, ie (int)59.52*seconds
	 
	 logic tileInc = 1'b1;
	 logic [2:0] tileNum, frameNum;
	 logic [5:0] tt_data, tw_data, ta_data, tr_data;
	 
	 logic p1Pixel, p2Pixel;
	 logic [6:0] p1Tile, p2Tile;
	 logic [4:0] p1PixelX, p1PixelY, p2PixelX, p2PixelY;
	 logic [5:0] p1_data, p2_data;
	 
	 logic c1Pixel, c2Pixel, c3Pixel, c4Pixel, c5Pixel, c6Pixel, c7Pixel, c8Pixel;
	 logic [3:0] carTile, carPriTile, c1Tile, c2Tile, c3Tile, c4Tile, c5Tile, c6Tile, c7Tile, c8Tile;
	 logic [5:0] carPixelX, carPriPixelX, c1PixelX, c2PixelX, c3PixelX, c4PixelX, c5PixelX, c6PixelX, c7PixelX, c8PixelX;
	 logic [4:0] carPixelY, carPriPixelY, c1PixelY, c2PixelY, c3PixelY, c4PixelY, c5PixelY, c6PixelY, c7PixelY, c8PixelY;
	 logic [5:0] car_data, carPri_data;
	 
	 logic m1Pixel, m2Pixel, m3Pixel, m4Pixel, m5Pixel;
	 logic [1:0] moneyTile, m1Tile, m2Tile, m3Tile, m4Tile, m5Tile;
	 logic [4:0] moneyPixelX, m1PixelX, m2PixelX, m3PixelX, m4PixelX, m5PixelX;
	 logic [4:0] moneyPixelY, m1PixelY, m2PixelY, m3PixelY, m4PixelY, m5PixelY;
	 logic [5:0] money_data;
	 
    logic SpawnEnable, p1Dead, p2Dead;
	 logic P1Hit, c1P1Hit, c2P1Hit, c3P1Hit, c4P1Hit, c5P1Hit, c6P1Hit, c7P1Hit, c8P1Hit;
	 logic P2Hit, c1P2Hit, c2P2Hit, c3P2Hit, c4P2Hit, c5P2Hit, c6P2Hit, c7P2Hit, c8P2Hit;
	 logic P1Collected, P2Collected;
	 logic [1:0] P1Collect, m1P1Collect, m2P1Collect, m3P1Collect, m4P1Collect, m5P1Collect;
	 logic [1:0] P2Collect, m1P2Collect, m2P2Collect, m3P2Collect, m4P2Collect, m5P2Collect;
	 logic [4:0] P1HbOffset, P2HbOffset;
	 logic [6:0] p1Score, p2Score;
	 logic [9:0] P1X, P1Y, P2X, P2Y;
	 logic [15:0] timer;

    enum logic [1:0] { Menu, Game, End } curr_state, next_state; // Internal state logic
	 
	 
	 // FRAME LOGIC
	 
    always_ff @ (posedge FrameClk)
    begin
        if (Reset)
            curr_state <= Menu;
        else
		  begin
            curr_state <= next_state;
				if (curr_state == Game)
				begin
		          timer   <= timer + 1'b1;
				    tileNum <= 3'b0;
				end
				else
				begin
				    timer   <= 15'b0;
					 if (tileInc)
					 begin
					     if (tileNum == tilesPerAnim)
						      tileInc <= 1'b0;
						  else
						      tileNum <= tileNum + 1'b1; //must be 1'b1, for ta_data
					 end
					 else
					 begin
					     if (tileNum == 0)
						      tileInc <= 1'b1;
						  else
						      tileNum <= tileNum - 1'b1; //must be 1'b1, for ta_data
					 end
				end
		  end
    end
   
	
	 // OUTPUT LOGIC
	 
    always_comb
    begin 
		  
		  // Assign TextPixel and next state
		  TextPixel  = 6'b0;
        next_state = curr_state;
		  unique case (curr_state)
		      Menu:
				begin
				    if (titleX <= DrawX && DrawX < titleX + titleWidth && titleY <= DrawY && DrawY < titleY + titleHeight)
		              TextPixel = tt_data;
		          if (Continue) 
		              next_state = Game;
				end
				End:
				begin
		          if      (winX     <= DrawX && DrawX < winX + winWidth         && winY     <= DrawY && DrawY < winY + winHeight        )
		              TextPixel = tw_data;
		          else if (animX    <= DrawX && DrawX < animX + animWidth       && animY    <= DrawY && DrawY < animY + animHeight      )
		              TextPixel = ta_data;
				    else if (rematchX <= DrawX && DrawX < rematchX + rematchWidth && rematchY <= DrawY && DrawY < rematchY + rematchHeight)
		              TextPixel = tr_data;
		          if (Continue) 
		              next_state = Game;
				end
		      Game:
				begin
					 if (timer == roundDuration)
						  next_state = End;
				end
		      default : next_state = Menu;
		  endcase
		  
		  // Calculate PlayerPixel
		  if (p1Pixel && p2Pixel)
		  begin
		      if (P2Y <= P1Y)
		          PlayerPixel = (p1_data) ? p1_data : p2_data;
				else
		          PlayerPixel = (p2_data) ? p2_data : p1_data;
		  end
		  else if (p1Pixel)
		      PlayerPixel = p1_data;
		  else if (p2Pixel)
		      PlayerPixel = p2_data;
		  else
		      PlayerPixel = 6'b0;
		
        // Calculate CarPixel and Priority vars
	     if (c1Pixel)
		  begin
		      carPriTile   = c1Tile;
				carPriPixelX = c1PixelX;
				carPriPixelY = c1PixelY;
		      carTile   = c2Tile;
		      carPixelX = c2PixelX;
		      carPixelY = c2PixelY;
		      PlayerPriority = (p1Pixel && (P1Y+10'd32) >> 4 > lane1Tile) || (p2Pixel && (P2Y+10'd32) >> 4 > lane1Tile);
		  end
		  else if (c2Pixel)
		  begin
		      carPriTile   = c2Tile;
				carPriPixelX = c2PixelX;
				carPriPixelY = c2PixelY;
		      carTile   = c3Tile;
		      carPixelX = c3PixelX;
		      carPixelY = c3PixelY;
		      PlayerPriority = (p1Pixel && (P1Y+10'd32) >> 4 > lane2Tile) || (p2Pixel && (P2Y+10'd32) >> 4 > lane2Tile);
		  end
		  else if (c3Pixel)
		  begin
		      carPriTile   = c3Tile;
				carPriPixelX = c3PixelX;
				carPriPixelY = c3PixelY;
		      carTile   = c4Tile;
		      carPixelX = c4PixelX;
		      carPixelY = c4PixelY;
		      PlayerPriority = (p1Pixel && (P1Y+10'd32) >> 4 > lane3Tile) || (p2Pixel && (P2Y+10'd32) >> 4 > lane3Tile);
		  end
		  else if (c4Pixel)
		  begin
		      carPriTile   = c4Tile;
				carPriPixelX = c4PixelX;
				carPriPixelY = c4PixelY;
		      carTile   = c5Tile;
		      carPixelX = c5PixelX;
		      carPixelY = c5PixelY;
		      PlayerPriority = (p1Pixel && (P1Y+10'd32) >> 4 > lane4Tile) || (p2Pixel && (P2Y+10'd32) >> 4 > lane4Tile);
		  end
		  else if (c5Pixel)
		  begin
		      carPriTile   = c5Tile;
				carPriPixelX = c5PixelX;
				carPriPixelY = c5PixelY;
		      carTile   = c6Tile;
		      carPixelX = c6PixelX;
		      carPixelY = c6PixelY;
		      PlayerPriority = (p1Pixel && (P1Y+10'd32) >> 4 > lane5Tile) || (p2Pixel && (P2Y+10'd32) >> 4 > lane5Tile);
		  end
		  else if (c6Pixel)
		  begin
		      carPriTile   = c6Tile;
				carPriPixelX = c6PixelX;
				carPriPixelY = c6PixelY;
		      carTile   = c7Tile;
		      carPixelX = c7PixelX;
		      carPixelY = c7PixelY;
		      PlayerPriority = (p1Pixel && P1Y[9:4] > lane6Tile) || (p2Pixel && P2Y[9:4] > lane6Tile);
		  end
		  else if (c7Pixel)
		  begin
		      carPriTile   = c7Tile;
				carPriPixelX = c7PixelX;
				carPriPixelY = c7PixelY;
		      carTile   = c8Tile;
		      carPixelX = c8PixelX;
		      carPixelY = c8PixelY;
		      PlayerPriority = (p1Pixel && P1Y[9:4] > lane7Tile) || (p2Pixel && P2Y[9:4] > lane7Tile);
		  end
		  else if (c8Pixel)
		  begin
		      carPriTile   = c8Tile;
				carPriPixelX = c8PixelX;
				carPriPixelY = c8PixelY;
		      carTile   = 4'b0;
		      carPixelX = 6'b0;
		      carPixelY = 5'b0;
		      PlayerPriority = (p1Pixel && P1Y[9:4] > lane8Tile) || (p2Pixel && P2Y[9:4] > lane8Tile);
		  end
		  else
		  begin
		      carPriTile   = 4'b0;
				carPriPixelX = 6'b0;
				carPriPixelY = 5'b0;
		      carTile   = 4'b0;
		      carPixelX = 6'b0;
		      carPixelY = 5'b0;
		      PlayerPriority = (p1Pixel || p2Pixel);
		  end
		  
		  if (c1Pixel | c2Pixel | c3Pixel | c4Pixel | c5Pixel | c6Pixel | c7Pixel | c8Pixel)
		      CarPixel = (carPri_data) ? carPri_data : car_data;
		  else
		      CarPixel = 6'b0;
		  
		  // Calculate MoneyPixel
		  moneyTile   = m1Tile   |  m2Tile  |  m3Tile  |  m4Tile  | m5Tile;
		  moneyPixelX = m1PixelX | m2PixelX | m3PixelX | m4PixelX | m5PixelX;
		  moneyPixelY = m1PixelY | m2PixelY | m3PixelY | m4PixelY | m5PixelY;
		  if (m1Pixel | m2Pixel | m3Pixel | m4Pixel | m5Pixel)
		      MoneyPixel = money_data;
		  else
		      MoneyPixel = 6'b0;
		  
		  // Calculate other outputs
		  P1Hit       = !p1Dead && (c1P1Hit | c2P1Hit | c3P1Hit | c4P1Hit | c5P1Hit | c6P1Hit | c7P1Hit | c8P1Hit);
	     P2Hit       = !p2Dead && (c1P2Hit | c2P2Hit | c3P2Hit | c4P2Hit | c5P2Hit | c6P2Hit | c7P2Hit | c8P2Hit);
		  P1Collect   = m1P1Collect | m2P1Collect | m3P1Collect | m4P1Collect | m5P1Collect;
	     P2Collect   = m1P2Collect | m2P2Collect | m3P2Collect | m4P2Collect | m5P2Collect;
		  SpawnEnable = (curr_state == Game);
		  Map         = 2'b0;
		  HEX3        = p1Score / 4'd10;
		  HEX2        = p1Score % 4'd10;
		  HEX1        = p2Score / 4'd10;
		  HEX0        = p2Score % 4'd10;
		  //LED         = 10'b1111111111 << ((10*timer) / roundDuration);]
		  //DEBUG
		  LED = {1'b0,P1Hit,c1P1Hit,c2P1Hit,c3P1Hit,c4P1Hit,c5P1Hit,c6P1Hit,c7P1Hit,c8P1Hit};
		  money_data = 6'd20;
		  //carPri_data = 6'd21;
		  //car_data = 6'd22;
		  p1_data = 6'd23;
		  p2_data = 6'd24;
    end 
	 
	 
	 // MODULE INSTANTIATION
	 
	 //Players
	 player p1 (.PlayerOne(1'b1),        .PlayerHit(P1Hit),       .PlayerCollect(P1Collect), .Speed(3'd4 + Difficulty),
	            .Dead(p1Dead),           .Collected(P1Collected), .PlayerPixel(p1Pixel),
					.Tile(p1Tile),           .PixelX(p1PixelX),       .PixelY(p1PixelY),         .HbOffset(P1HbOffset), .Score(p1Score), .PlayerX(P1X), .PlayerY(P1Y), .*);
					
	 player p2 (.PlayerOne(1'b0),        .PlayerHit(P2Hit),       .PlayerCollect(P2Collect), .Speed(3'd4 + Difficulty),
	            .Dead(p2Dead),           .Collected(P2Collected), .PlayerPixel(p2Pixel),
					.Tile(p2Tile),           .PixelX(p2PixelX),       .PixelY(p2PixelY),         .HbOffset(P2HbOffset), .Score(p2Score), .PlayerX(P2X), .PlayerY(P2Y), .*);
	 
	 //Cars - Car Speed is set to be inversely proportional to the Car Count to avoid super fast clusters of cars, but this could be tweaked or made into a difficulty thing. also, lanes support up to 6 cars, but this will yield a max of 5
	 lane #(.TileY(lane1Tile)) lane1 (.SpawnEnable(SpawnEnable && Difficulty), .Direction(Random[0]), .CarType(Random[ 9:8 ]), .CarCount(Random[25:24] + 1'b1), .CarSpeed(3'd4 - Random[25:24] + Difficulty),
	                                                                       .P1Hit(c1P1Hit),       .P2Hit(c1P2Hit),         .CarPixel(c1Pixel),
																								  .Tile(c1Tile),         .PixelX(c1PixelX),       .PixelY(c1PixelY), .*);
										
	 lane #(.TileY(lane2Tile)) lane2 (.SpawnEnable(       SpawnEnable       ), .Direction(Random[1]), .CarType(Random[11:10]), .CarCount(Random[27:26] + 1'b1), .CarSpeed(3'd4 - Random[27:26] + Difficulty),
	                                                                       .P1Hit(c2P1Hit),       .P2Hit(c2P2Hit),         .CarPixel(c2Pixel),
																								  .Tile(c2Tile),         .PixelX(c2PixelX),       .PixelY(c2PixelY), .*);
										
	 lane #(.TileY(lane3Tile)) lane3 (.SpawnEnable(SpawnEnable && Difficulty), .Direction(Random[2]), .CarType(Random[13:11]), .CarCount(Random[29:28] + 1'b1), .CarSpeed(3'd4 - Random[29:28] + Difficulty),
	                                                                       .P1Hit(c3P1Hit),       .P2Hit(c3P2Hit),         .CarPixel(c3Pixel),
																								  .Tile(c3Tile),         .PixelX(c3PixelX),       .PixelY(c3PixelY), .*);
										
	 lane #(.TileY(lane4Tile)) lane4 (.SpawnEnable(       SpawnEnable       ), .Direction(Random[3]), .CarType(Random[15:14]), .CarCount(Random[31:30] + 1'b1), .CarSpeed(3'd4 - Random[31:30] + Difficulty),
	                                                                       .P1Hit(c4P1Hit),       .P2Hit(c4P2Hit),         .CarPixel(c4Pixel),
																								  .Tile(c4Tile),         .PixelX(c4PixelX),       .PixelY(c4PixelY), .*);
										
	 lane #(.TileY(lane5Tile)) lane5 (.SpawnEnable(SpawnEnable && Difficulty), .Direction(Random[4]), .CarType(Random[17:16]), .CarCount(Random[33:32] + 1'b1), .CarSpeed(3'd4 - Random[33:32] + Difficulty),
	                                                                       .P1Hit(c5P1Hit),       .P2Hit(c5P2Hit),         .CarPixel(c5Pixel),
																								  .Tile(c5Tile),         .PixelX(c5PixelX),       .PixelY(c5PixelY), .*);
										
	 lane #(.TileY(lane6Tile)) lane6 (.SpawnEnable(       SpawnEnable       ), .Direction(Random[5]), .CarType(Random[19:18]), .CarCount(Random[35:34] + 1'b1), .CarSpeed(3'd4 - Random[35:34] + Difficulty),
	                                                                       .P1Hit(c6P1Hit),       .P2Hit(c6P2Hit),         .CarPixel(c6Pixel),
																								  .Tile(c6Tile),         .PixelX(c6PixelX),       .PixelY(c6PixelY), .*);
										
	 lane #(.TileY(lane7Tile)) lane7 (.SpawnEnable(SpawnEnable && Difficulty), .Direction(Random[6]), .CarType(Random[21:20]), .CarCount(Random[37:36] + 1'b1), .CarSpeed(3'd4 - Random[37:36] + Difficulty),
	                                                                       .P1Hit(c7P1Hit),       .P2Hit(c7P2Hit),         .CarPixel(c7Pixel),
																								  .Tile(c7Tile),         .PixelX(c7PixelX),       .PixelY(c7PixelY), .*);
										
	 lane #(.TileY(lane8Tile)) lane8 (.SpawnEnable(       SpawnEnable       ), .Direction(Random[7]), .CarType(Random[23:22]), .CarCount(Random[39:38] + 1'b1), .CarSpeed(3'd4 - Random[39:38] + Difficulty),
	                                                                       .P1Hit(c8P1Hit),       .P2Hit(c8P2Hit),         .CarPixel(c8Pixel),
																								  .Tile(c8Tile),         .PixelX(c8PixelX),       .PixelY(c8PixelY), .*);
	 
    //Money - SpawnX obtained by centering middle pallet then arbitrarily spacing the others evenly from there (40px, a bit more than 1 money width)
	 money money1 (.Random(Random[ 2:0 ]), .SpawnX(10'd331), .P1Collect(m1P1Collect), .P2Collect(m1P2Collect), .MoneyPixel(m1Pixel), .Tile(m1Tile), .PixelX(m1PixelX), .PixelY(m1PixelY), .*);
	 money money2 (.Random(Random[ 5:3 ]), .SpawnX(10'd371), .P1Collect(m2P1Collect), .P2Collect(m2P2Collect), .MoneyPixel(m2Pixel), .Tile(m2Tile), .PixelX(m2PixelX), .PixelY(m2PixelY), .*);
	 money money3 (.Random(Random[ 8:0 ]), .SpawnX(10'd411), .P1Collect(m3P1Collect), .P2Collect(m3P2Collect), .MoneyPixel(m3Pixel), .Tile(m3Tile), .PixelX(m3PixelX), .PixelY(m3PixelY), .*);
	 money money4 (.Random(Random[11:9 ]), .SpawnX(10'd451), .P1Collect(m4P1Collect), .P2Collect(m4P2Collect), .MoneyPixel(m4Pixel), .Tile(m4Tile), .PixelX(m4PixelX), .PixelY(m4PixelY), .*);
	 money money5 (.Random(Random[14:12]), .SpawnX(10'd491), .P1Collect(m5P1Collect), .P2Collect(m5P2Collect), .MoneyPixel(m5Pixel), .Tile(m5Tile), .PixelX(m5PixelX), .PixelY(m5PixelY), .*);
	 
	 //ROM
	 /*text_title_rom   tt  (.PixelX(DrawX-titleX),   .PixelY(DrawY-titleY+tileNum), .Data(tt_data));
	 text_pl_win_rom  tw  (.PixelX(DrawX-winX),     .PixelY(DrawY-winY),           .Data(tw_data), .PlayerTwo(p2Score > p1Score));
	 text_pl_anim_rom tp  (.PixelX(DrawX-animX),    .PixelY(DrawY-animY),          .Data(ta_data), .PlayerTwo(p2Score > p1Score), .Tile(tileNum));
	 text_rematch_rom tr  (.PixelX(DrawX-rematchX), .PixelY(DrawY-rematchY),       .Data(tr_data));
	 player_rom p1Rom     (.Tile(p1Tile),     .PixelX(p1PixelX),     .PixelY(p1PixelY),     .Data(p1_data),     .PlayerTwo(1'b0));
	 player_rom p2Rom     (.Tile(p2Tile),     .PixelX(p2PixelX),     .PixelY(p2PixelY),     .Data(p2_data),     .PlayerTwo(1'b1));*/
	 car_rom    carRom    (.Tile(carTile),    .PixelX(carPixelX),    .PixelY(carPixelY),    .Data(car_data)   );
	 car_rom    carPriRom (.Tile(carPriTile), .PixelX(carPriPixelX), .PixelY(carPriPixelY), .Data(carPri_data));
	 /*money_rom  moneyRom  (.Tile(moneyTile),  .PixelX(moneyPixelX),  .PixelY(moneyPixelY),  .Data(money_data) );*/
	
endmodule
