module car (
    input  logic FrameClk, SpawnEnable, FaceLeft,
	 input  logic [1:0] Type,
	 input  logic [2:0] Speed,
    input  logic [9:0] DrawX, DrawY, SpawnX, SpawnY,
    output logic       CarPixel, CarPriority,
	 output logic [3:0] Tile,
    output logic [5:0] PixelX,
    output logic [4:0] PixelY
);

    // Declare local logic
	 localparam [2:0] tilesPerAnim    = 4;
	 localparam [2:0] framesPerTile   = 5;  //roughly equivalent to 12fps (60/5 = 12)
	 localparam [9:0] carWidth        = 48;
	 localparam [9:0] carHeight       = 26;
	 localparam [9:0] carMinX         = 100;
	 localparam [9:0] carMaxX         = 739;
	 logic spawned = 1'b0;
	 logic [1:0] tileNum    = 2'b0;
	 logic [2:0] frameNum   = 3'b0;
	 logic [9:0] carX       = 10'b0;
	 
    always_ff @ (posedge FrameClk)
    begin
        if (SpawnEnable)
        begin
		  
		      if (!spawned) //single cycle delay to movement to make sure cars are spawned correctly
				begin
		          tileNum  <= 2'b0;
		          frameNum <= 3'b0;
				    carX     <= SpawnX;
					 spawned  <= 1'b1;
				end
				else
				begin
				
				    //car animation logic
					 
		          if (frameNum == framesPerTile)
				    begin
				        frameNum <= 3'b0;
		              if (tileNum == tilesPerAnim) //technically we dont need this check in the case of cars since tilesPerAnim is 4 and tileNum is 2 bits
				            tileNum <= 2'b0;
				    	 else
				            tileNum <= tileNum + 1'b1;
			       end
			    	else
			    	begin
			    	    tileNum <= tileNum;
			    	    frameNum <= frameNum + 1'b1;
			    	end
				
				
                //car movement logic
				    
				    if (FaceLeft)
				    begin
				        carX <= carX - Speed;
				    	 if (carX + carWidth < carMinX)
				    	     carX <= carMaxX + 1;
			    	end
			    	else
			    	begin
			    	    carX <= carX + Speed;
			    		 if (carX >= carMaxX)
				    	     carX <= carMinX - carWidth - 1;
				    end
				end
				
        end
		  else
		  begin
			   spawned  <= 1'b0;
		      tileNum  <= 2'b0;
		      frameNum <= 3'b0;
				carX     <= SpawnX;
		  end
    end
	 
	 always_comb
	 begin
	     CarPixel    = (SpawnEnable && carX   <= DrawX && DrawX < carX + carWidth && SpawnY <= DrawY && DrawY < SpawnY + carHeight);
	     CarPriority = (SpawnEnable && SpawnY <= DrawY &&     DrawY < SpawnY + (carHeight - 16)      && CarPixel);
		  Tile        = (Type * tilesPerAnim) + tileNum;
		  PixelX      = FaceLeft ? DrawX - carX : (carWidth - 1) - (DrawX - carX);
		  PixelY      = DrawY - SpawnY;
	 end

endmodule
