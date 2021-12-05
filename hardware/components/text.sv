
/*module text (
    parameter Topside         = 1'b1; //0 to start from 639, 1 to start from -tileHeight
	 parameter [1:0] TextIndex = 2'b0; //0 for title, 1 for p1win, 2 for p2win, 3 for rematch
	 parameter [9:0] EndY      = 9'b0; //the y position the text should settle at (x is constant)
	 // Input and Outputs
    input logic FrameClk, Active,
	 output logic [9:0] TextY
);
	 
	 parameter [6:0] hoverOffset      = 60; //pixel offset for hover effect, 127 max
    parameter [2:0] hoverMotion      = 1;  //pixels per frame to move for hover effect, ie offset / (seconds * fps)
	 parameter [2:0] transitionMotion = 2;  //pixels per frame to move for transition effect, ie |StartY-EndY| / (seconds * fps)
    
	 logic visible = 1'b0;
	 logic [9:0] tileHeight = ;
    logic [9:0] textY = topside ? ~(tileHeight) + 1'b1 : 9'b0;
	 logic [9:0] textMotionY = 9'b0;
   
    always_ff @ (posedge frame_clk)
    begin
	 
	     textMotionY <= 9'b0;
		  
	     if (visible)
        begin
		      if (Active)
				begin:TextHover
		          if (textY <= EndY + hoverOffset) textMotionY <= hoverMotion;
				    else textMotionY <= ~(hoverMotion) + 1'b1; //2s complement
				end
        end
		  else
		  begin
				
		      if (topside == Active)    //if (!visible && topside && Active) || (visible && ~topside && ~Active), aka (!visible XNOR topside XNOR Active) , aka equivalence
				begin:SlideDown
					 
				    if (topside) //StartY == -tileHeight
					 begin
				        if (textY <= StartY) visible = 1'b0; //THIS CHECK WILL BE MESSED UP BY 2S COMPLEMENT
						  else textMotionY <= ~(transitionMotion) + 1'b1; //2s complement
					 end
					 else        //StartY == -tileHeight
					 begin
				        if (textY >= StartY) visible = 1'b0;
						  else textMotionY <= ~(transitionMotion) + 1'b1; //2s complement
					 end
						  
            end
            else
				begin:SlideUp
					 
				    if (topside) //comment about simplification applies here too
				    begin
				        if (textY <= StartY) visible = 1'b0;
						  else textMotionY <= ~(transitionMotion) + 1'b1; //2s complement
					 end
					 else
					 begin
				        if (textY >= StartY) visible = 1'b0;
						  else textMotionY <= ~(transitionMotion) + 1'b1; //2s complement
					 end
						  
			   end
					 
		  end
		  
		  // Update Text position
        textY <= (textY + textMotionY);
		  
    end
	 
    assign TextY = textY;

endmodule*/
