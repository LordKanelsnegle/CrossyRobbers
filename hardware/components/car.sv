module car (
    input  logic       FrameClk, SpawnEnable, FaceLeft,
	 input  logic [1:0] Type,
	 input  logic [2:0] Speed,
	 input  logic [4:0] P1HbOffset, P2HbOffset,
    input  logic [9:0] DrawX, DrawY, SpawnX, SpawnY, P1X, P1Y, P2X, P2Y,
    output logic       P1Hit, P2Hit, CarPixel,
	 output logic [3:0] Tile,
    output logic [5:0] PixelX,
    output logic [4:0] PixelY
);

    // LOCAL LOGIC
	 
	 localparam [2:0] tilesPerAnim  = 3'd4;
	 localparam [2:0] framesPerTile = 3'd5;  //roughly equivalent to 12fps (60/5 = 12)
	 localparam [9:0] carWidth      = 10'd48;
	 localparam [9:0] carHeight     = 10'd26;
	 localparam [9:0] carMinX       = 10'd100;
	 localparam [9:0] carMaxX       = 10'd739;
	 
	 logic spawned, moved, p1Hit, p2Hit;
	 logic [1:0] tileNum;
	 logic [2:0] frameNum;
	 logic [9:0] carX;
	 
	 
	 //FRAME LOGIC
	 
    always_ff @ (posedge FrameClk)
    begin
        if (SpawnEnable)
        begin
		  
		      if (!spawned)
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
		              if (tileNum == tilesPerAnim - 1'b1)
				            tileNum <= 2'b0;
				    	  else
				            tileNum <= tileNum + 1'b1;
			       end
			    	 else
			    	     frameNum <= frameNum + 1'b1;
					 
                //car movement logic
					 if (!moved)
					 begin
					     moved <= 1'b1; //add one frame delay, thus halving car speeds
				        if (FaceLeft)
				        begin
				            carX <= carX - Speed;
				        	 if (carX + carWidth < carMinX)
				        	     carX <= carMaxX + 1'b1;
			    	     end
			    	     else
			    	     begin
			    	        carX <= carX + Speed;
			    	    	 if (carX >= carMaxX)
				        	     carX <= carMinX - carWidth - 1'b1;
				        end
					 end
					 else
					     moved <= 1'b0;
					
				end
				
        end
		  else
		      spawned  <= 1'b0;
    end
	 
	 
	 // OUTPUT LOGIC
	 
	 always_comb
	 begin
	     P1Hit       = (SpawnEnable && p1Hit);
	     P2Hit       = (SpawnEnable && p2Hit);
	     CarPixel    = (SpawnEnable && carX   <= DrawX && DrawX < carX + carWidth && SpawnY <= DrawY && DrawY < SpawnY + carHeight);
		  Tile        = (Type * tilesPerAnim) + tileNum;
		  PixelX      = FaceLeft ? DrawX - carX : (carWidth - 1'b1) - (DrawX - carX);
		  PixelY      = DrawY - SpawnY;
	 end
	 
	 
	 // MODULE INSTANTIATION
	 
	 collision p1 (.X1(P1X+P1HbOffset), .Y1(P1Y+10'd30), .Width1(10'd16), .Height1(10'd1), .X2(carX), .Y2(SpawnY+(carHeight-10'd16)), .Width2(carWidth), .Height2(10'd16), .Collided(p1Hit));
	 collision p2 (.X1(P2X+P2HbOffset), .Y1(P2Y+10'd30), .Width1(10'd16), .Height1(10'd1), .X2(carX), .Y2(SpawnY+(carHeight-10'd16)), .Width2(carWidth), .Height2(10'd16), .Collided(p2Hit));

endmodule
