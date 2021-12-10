
module player (
    input  logic       FrameClk, SpawnEnable, PlayerOne, PlayerHit,
	 input  logic [1:0] PlayerCollect,
	 input  logic [2:0] Speed,
    input  logic [7:0] Keycode,
    input  logic [9:0] DrawX, DrawY,
	 output logic       Collected, PlayerPixel, PlayerPriority,
	 output logic [6:0] Tile,
    output logic [4:0] PixelX, PixelY, HbOffset,
	 output logic [6:0] Score,
    output logic [9:0] PlayerX, PlayerY
);

    // LOCAL LOGIC
	 
	 localparam [1:0] maxItems      = 2'd3;
	 localparam [3:0] tilesPerAnim  = 4'd8;
	 localparam [2:0] framesPerTile = 3'd5;  //roughly equivalent to 12fps (60/5 = 12)
	 localparam [9:0] playerWidth   = 10'd32;
	 localparam [9:0] playerHeight  = 10'd32;
	 localparam [9:0] playerMinX    = 10'd100;
	 localparam [9:0] playerMaxX    = 10'd739;
	 localparam [9:0] playerMinY    = 10'd65; //ideally these are set to screen dimensions, and we use collidable tiles to do the work
	 localparam [9:0] playerMaxY    = 10'd448;
	 localparam [9:0] SpawnY        = 10'd400;
	 logic [9:0] SpawnX;
	 
	 logic spawned, faceLeft, moved, deposited;
	 logic [1:0] items;
	 logic [2:0] itemsVal;
	 logic [2:0] speed;
	 logic [2:0] tileNum;
	 logic [2:0] frameNum;
	 logic [6:0] score;
	 logic [9:0] playerX;
	 logic [9:0] playerY;

    enum logic [1:0] { Idle, Walk, Dead1, Dead2 } state;
	 
	 
	 // FRAME LOGIC
	 
    always_ff @ (posedge FrameClk)
    begin
        if (SpawnEnable)
        begin
		  
		      if (!spawned)
				begin
				    faceLeft <= ~PlayerOne;
				    state    <= Idle;
					 items    <= 2'b0;
					 itemsVal <= 3'b0;
		   	    tileNum  <= 3'b0;
		   	    frameNum <= 3'b0;
		   	    playerX  <= SpawnX;
		   	    playerY  <= SpawnY;
					 spawned  <= 1'b1;
			   end
				else
				begin
				
				    //player animation logic
		          if (frameNum == framesPerTile)
				    begin
				        frameNum <= 3'b0;
		              if (tileNum == tilesPerAnim) //technically we dont need this check in the case of player since tilesPerAnim is 8 and tileNum is 3 bits
						  begin
				            tileNum <= 3'b0;
						      if (state == Dead1)
						          state <= Dead2;
						      else if (state == Dead2)
						          spawned <= 1'b0;
						  end
				    	  else
				            tileNum <= tileNum + 1'b1;
			       end
			    	 else
			    	     frameNum <= frameNum + 1'b1;
					 
					 //non-dead logic
                if (state < Dead1)
				    begin
					 
					     //player death logic - must check here so that it doesnt trigger continuously while in contact with cars
					     if (PlayerHit)
					     begin
		   	            tileNum  <= 3'b0;
		   	            frameNum <= 3'b0;
	                     state    <= Dead1;
					     end
						  else
						  begin
						  
                        //player movement logic
					         if (!moved)
					         begin
								    moved <= 1'b1; //add one frame delay, thus halving player speed
						          state <= Idle;
								    if (Keycode[4*PlayerOne + 3] ^ Keycode[4*PlayerOne + 2]) //if EITHER left OR right is pressed, process it, otherwise do nothing on X axis
								    begin
					                 state <= Walk;
		                          if (Keycode[4*PlayerOne + 3])
				                    begin
						                  faceLeft <= 1'b1;
				                        if (playerMinX < playerX - speed)
				                            playerX <= playerX - speed;
				        	               else
								                playerX <= playerMinX;
				                    end
		                          else
				                    begin
						                  faceLeft <= 1'b0;
				                        if (playerX + playerWidth + speed < playerMaxX)
				                            playerX <= playerX + speed;
				        	               else
								                playerX <= playerMaxX - playerWidth;
				                    end
								    end
								    if (Keycode[4*PlayerOne + 1] ^ Keycode[4*PlayerOne])
								    begin
					                 state <= Walk;
		                          if (Keycode[4*PlayerOne + 1])
				                    begin
				                        if (playerMinY < playerY - speed)
				                            playerY <= playerY - speed;
				        	               else
								                playerY <= playerMinY;
				                    end
		                          else
				                    begin
				                        if (playerY + playerHeight + speed < playerMaxY)
				                            playerY <= playerY + speed;
				        	               else
								                playerY <= playerMaxY - playerHeight;
				                    end
								    end
								end
								else
								    moved <= 1'b0;
								
					         //player item logic
					         Collected <= 1'b0;
					         if (PlayerCollect && items < maxItems)
					         begin
	                         items     <= items + 1'b1;
					             itemsVal  <= itemsVal + PlayerCollect;
						          Collected <= 1'b1;
					         end
								else if (deposited)
								begin
								    score    <= score + itemsVal;
									 itemsVal <= 3'b0;
									 items    <= 2'b0;
								end
								
					     end
						  
                end
					
				end
				
        end
		  else
		  begin
			   score    <= 7'b0;
		      spawned  <= 1'b0;
		  end
    end
	 
	 
	 // OUTPUT LOGIC
	 
	 always_comb
	 begin
	     speed          = Speed - items;
	     SpawnX         = (PlayerOne) ? 10'd292 : 10'd548 - playerWidth; //bank takes up the middle 16 tiles, so 192 on either side of players plus offset of 100
		  
	     PlayerPixel    = (SpawnEnable && playerX <= DrawX && DrawX < playerX + playerWidth && playerY <= DrawY && DrawY < playerY + playerHeight);
		  PlayerPriority = (SpawnEnable && playerY <= DrawY &&   DrawY < playerY + 10'd16    && PlayerPixel);
		  Tile           = (state * tilesPerAnim * (maxItems+1'b1)) + (tileNum * (maxItems+1'b1)) + items;
		  PixelX         = faceLeft ? (playerWidth - 1'b1) - (DrawX - playerX) : DrawX - playerX;
		  PixelY         = DrawY - playerY;
		  
	     Score          = score;
		  HbOffset       = (faceLeft) ? 5'b0 : 5'd16;
		  PlayerX        = playerX;
		  PlayerY        = playerY;
		  
	 end
	 
	 
	 // MODULE INSTANTIATION
	 
	 collision deposit (.X1(playerX+HbOffset), .Y1(playerY+10'd16), .Width1(10'd16), .Height1(10'd16), .X2(10'd288), .Y2(playerMinY), .Width2(10'd64), .Height2(10'd40), .Collided(deposited)); //288 and 64 are hardcoded heist vehicle vals

endmodule
