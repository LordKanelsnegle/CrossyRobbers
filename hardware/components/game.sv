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
/*
module game (

);

//=======================================================
//  FSM LOGIC
//=======================================================

    enum logic [1:0] { Menu, Game, End } curr_state, next_state; // Internal state logic
		
    always_ff @ (posedge Clk)
    begin
        if (Reset) 
            curr_state <= Menu;
        else 
            curr_state <= Next_state;
    end
   
    always_comb
    begin 
        // Default next state is staying at current state
        next_state = curr_state;
		
        // Default controls signal values
		  
		  // Assign next state
		  unique case (curr_state)
		      Halted: 
		          if (Run) 
		              next_state = S_18;                      
		      S_18: 
		          next_state = S_33_1;
		      default : next_state = Menu;
		  endcase
		
        // Assign control signals based on current state
        case (curr_state)
            Halted: ;
            S_18: 
                begin 
                  GatePC     = 1'b1;
                  LD_MAR     = 1'b1;
                  PCMUX      = 2'b00;
                  LD_PC      = 1'b1;
                end
            default: ;
		  endcase
		  
    end 
	
endmodule*/
