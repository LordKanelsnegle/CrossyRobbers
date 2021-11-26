/*
//-------------------------------------------------------------------------


module player (
    input frame_clk, inGame, isPlayerOne,
    input [7:0] keycode,
	 output [] PlayerAnim,
	 output [7:0] PlayerScore,
    output [9:0] PlayerX, PlayerY
);
    
//=======================================================
//  FSM LOGIC
//=======================================================
	 
	 enum logic [1:0] { Dead, Idle, Walk } curr_state, next_state; // Internal state logic
		
    always_ff @ (posedge Clk)
    begin
        if (Reset) 
            curr_state <= Menu;
        else 
            curr_state <= Next_state;
    end
	 
//=======================================================
//  MOVEMENT LOGIC
//=======================================================
	 
    logic [9:0] Player_X_Pos, Player_X_Motion, Player_Y_Pos, Player_Y_Motion;
	 
	 // Using parameters because they have constant values (thus don't use registers)
	 parameter [9:0] Player_X_Step = 1;
	 parameter [9:0] Player_Y_Step = 1;
	 parameter [9:0] Player_X_Max  = 6; //WRONG
	 parameter [9:0] Player_Y_Max  = 1; //
	 parameter [9:0] SpawnY        = 400;
	 
	 // Conditional parameters
	 parameter [9:0] SpawnX = isPlayerOne ? 220 : 420;     // Horizontal spawnpoint
	 parameter [7:0] Left   = isPlayerOne ? 8'h04 : 8'h00; // Left keycode
	 parameter [7:0] Right  = isPlayerOne ? 8'h07 : 8'h00; // Right keycode
	 parameter [7:0] Up     = isPlayerOne ? 8'h1A : 8'h00; // Up keycode
	 parameter [7:0] Down   = isPlayerOne ? 8'h16 : 8'h00; // Down keycode
   
    always_ff @ (posedge frame_clk)
    begin
        if (isDead) //player has died or we are not currently in a game (e.g. if reset has been pressed)
        begin 
            Player_X_Motion <= 0;
				Player_Y_Motion <= 0;
				Player_X_Pos <= SpawnX;
				Player_Y_Pos <= SpawnY;
        end
        else
        begin : Movement
		      //default motion should be 0
				Player_X_Motion <= 0;
				Player_Y_Motion <= 0;
				
				//check key direction, keeping boundaries in mind
		      if (keycode == Left)
				begin
				    if (Player_X_Pos >= Player_X_Step)
				        Player_X_Motion <= ~Player_X_Step + 1; //2's complement
					 else Player_X_Pos <= 0;
				end
		      else if (keycode == Right)
				begin
				    if (Player_X_Pos + Player_X_Step <= Player_X_Max)
				        Player_X_Motion <= Player_X_Step;
					 else Player_X_Pos <= Player_X_Max;
				end
		      else if (keycode == Up)
				begin
				    if (Player_Y_Pos >= Player_Y_Step)
				        Player_Y_Motion <= ~Player_Y_Step + 1; //2's complement
					 else Player_Y_Pos <= 0;
				end
		      else if (keycode == Down)
				begin
				    if (Player_Y_Pos + Player_Y_Step <= Player_Y_Max)
				        Player_Y_Motion <= Player_Y_Step;
					 else Player_Y_Pos <= Player_Y_Max;
				end
				
				//update player position
				Player_X_Pos <= (Player_X_Pos + Player_X_Motion);
				Player_Y_Pos <= (Player_Y_Pos + Player_Y_Motion);
		end  
    end
       
    assign PlayerX = Player_X_Pos;
    assign PlayerY = Player_Y_Pos;

endmodule*/
