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
    input logic FrameClk, Reset, Continue,
	 output logic SpawnEnable,
	 output logic [9:0] LED
);

    parameter [15:0] round_duration = 7142; //round duration in frames, ie (int)59.52*seconds
	 logic [15:0] timer;

    enum logic [1:0] { Menu, Game, End } curr_state, next_state; // Internal state logic
		
    always_ff @ (posedge FrameClk)
    begin
        if (Reset)
            curr_state <= Menu;
        else
            curr_state <= next_state;
				
		  if (curr_state == Game)
		      timer <= timer + 1;
		  else
		      timer <= 15'b0;
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
					 if (timer == round_duration)
						  next_state = End;
		      default : next_state = Menu;
		  endcase
		
        // Set output values
		  SpawnEnable = (curr_state == Game);
		  LED = 10'b1111111111 << ((10*timer) / round_duration);
		  
    end 
	
endmodule
