module money (
    input  logic       FrameClk, SpawnEnable, P1Full, P2Full,
	 input  logic [2:0] Random,
	 input  logic [4:0] P1HbOffset, P2HbOffset,
    input  logic [9:0] SpawnX, DrawX, DrawY, P1X, P1Y, P2X, P2Y,
	 output logic [1:0] P1Collect, P2Collect,
    output logic       MoneyPixel,
	 output logic [1:0] Tile,
    output logic [4:0] PixelX, PixelY
);

    // LOCAL LOGIC
	 
	 localparam [9:0] moneyWidth      = 10'd18;
	 localparam [9:0] moneyHeight     = 10'd18;
	 localparam [9:0] respawnDuration = 10'd595; //base respawn duration in frames, ie (int)59.52*seconds
	 localparam [9:0] SpawnY          = 10'd436;
	 
	 logic spawned, p1Collect, p2Collect;
    logic [1:0] state;
	 logic [2:0] delay = 3'b0;
	 logic [9:0] timer = 10'b0;
	 
	 
	 //FRAME LOGIC
	 
    always_ff @ (posedge FrameClk)
    begin
        if (SpawnEnable)
        begin
		  
		      if (!spawned)
				begin
				    delay   <= Random;
		          state   <= Random[0] + 1'b1;
		          timer   <= 10'b0;
					 spawned <= 1'b1;
				end
				else
				begin
				
				    //respawn logic
					 if (P1Collect || P2Collect)
					     state <= 2'b0;
		          else if (timer == respawnDuration + delay * 6'd60)
						  spawned <= 1'b0;
			    	 else if (!state)
			    	     timer <= timer + 1'b1;
						  
				end
				
        end
		  else
		      spawned  <= 1'b0;
    end
	 
	 
	 // OUTPUT LOGIC
	 
	 always_comb
	 begin
	     MoneyPixel = (SpawnEnable && SpawnX <= DrawX && DrawX < SpawnX + moneyWidth && SpawnY <= DrawY && DrawY < SpawnY + moneyHeight);
		  P1Collect  = (p1Collect && !p2Collect && !P1Full) ? state : 2'b0; //give collection priority to p2, since p1 has win priority
		  P2Collect  = (        p2Collect && !P2Full      ) ? state : 2'b0;
		  Tile       = (MoneyPixel) ? state          : 2'b0;
		  PixelX     = (MoneyPixel) ? DrawX - SpawnX : 5'b0;
		  PixelY     = (MoneyPixel) ? DrawY - SpawnY : 5'b0;
	 end
	 
	 
	 // MODULE INSTANTIATION
	 
	 collision p1 (.X1(P1X+P1HbOffset), .Y1(P1Y+10'd16), .Width1(10'd16), .Height1(10'd16), .X2(SpawnX), .Y2(SpawnY), .Width2(moneyWidth), .Height2(moneyHeight), .Collided(p1Collect));
	 collision p2 (.X1(P2X+P2HbOffset), .Y1(P2Y+10'd16), .Width1(10'd16), .Height1(10'd16), .X2(SpawnX), .Y2(SpawnY), .Width2(moneyWidth), .Height2(moneyHeight), .Collided(p2Collect));

endmodule
