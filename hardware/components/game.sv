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

module game (
    input  logic       FrameClk, Reset, Continue,
    input  logic [7:0] Keycode,
    input  logic [9:0] DrawX, DrawY,
	 output logic       CarTopHalf,
	 output logic [5:0] TextPixel, P1Pixel, P2Pixel, MoneyPixel, CarPixel,
	 output logic [9:0] LED
);

    // GAME LOGIC

    parameter [15:0] round_duration = 7142; //round duration in frames, ie (int)59.52*seconds
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
		          timer <= timer + 1;
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
		
        // Set output values
		  SpawnEnable = (curr_state == Game);
		  LED = 10'b1111111111 << ((10*timer) / round_duration);
		  
    end 
	 
	 
	 // COMPONENT LOGIC

    logic SpawnEnable, carTopHalf;
	 logic [9:0] p1X, p1Y, p2X, p2Y;
	
	 logic c1TopHalf, c2TopHalf, c3TopHalf, c4TopHalf, c5TopHalf, c6TopHalf, c7TopHalf, c8TopHalf;
	 logic [5:0] c1Pixel, c2Pixel, c3Pixel, c4Pixel, c5Pixel, c6Pixel, c7Pixel, c8Pixel;
	
	 //lane outputs can be OR'd together because car pixels should never overlap (and thus lane pixels never will either)
	 assign CarTopHalf = c1TopHalf | c2TopHalf | c3TopHalf | c4TopHalf | c5TopHalf | c6TopHalf | c7TopHalf | c8TopHalf;
	 assign CarPixel   = c1Pixel   | c2Pixel   | c3Pixel   | c4Pixel   | c5Pixel   | c6Pixel   | c7Pixel   | c8Pixel;
	 
	 //Text
	 //text title   ();
	 //text p1win   ();
	 //text p2win   ();
	 //text rematch ();
	 
	 //Players
	 player p1 (.PlayerOne(1'b1), .PlayerX(p1X), .PlayerY(p1Y), .PlayerPixel(P1Pixel), .*);
	 player p2 (.PlayerOne(1'b0), .PlayerX(p2X), .PlayerY(p2Y), .PlayerPixel(P2Pixel), .*);
	 
	 //Cars
	 lane #(.TileY(10)) lane1 (.CarTopHalf(c1TopHalf), .CarPixel(c1Pixel), .*);
	 lane #(.TileY(11)) lane2 (.CarTopHalf(c2TopHalf), .CarPixel(c2Pixel), .*);
	 lane #(.TileY(12)) lane3 (.CarTopHalf(c3TopHalf), .CarPixel(c3Pixel), .*);
	 lane #(.TileY(13)) lane4 (.CarTopHalf(c4TopHalf), .CarPixel(c4Pixel), .*);
	 lane #(.TileY(20)) lane5 (.CarTopHalf(c5TopHalf), .CarPixel(c5Pixel), .*);
	 lane #(.TileY(21)) lane6 (.CarTopHalf(c6TopHalf), .CarPixel(c6Pixel), .*);
	 lane #(.TileY(22)) lane7 (.CarTopHalf(c7TopHalf), .CarPixel(c7Pixel), .*);
	 lane #(.TileY(23)) lane8 (.CarTopHalf(c8TopHalf), .CarPixel(c8Pixel), .*);
	 
    //moneys
	 //money money1 ();
	 //money money2 ();
	 //money money3 ();
	 //money money4 ();
	 //money money5 ();
	
endmodule
