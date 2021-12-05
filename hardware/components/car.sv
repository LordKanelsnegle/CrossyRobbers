module car #(parameter [9:0] SpawnX = 0) (
    input  logic FrameClk, SpawnEnable, FaceLeft,
	 input  logic [1:0] Type,
	 input  logic [2:0] Speed,
    input  logic [9:0] DrawX, DrawY, SpawnY,
    output logic CarTopHalf,
	 output logic [5:0] CarPixel
);

    // Declare local logic
	 parameter [2:0] framesPerSprite = 5;  //roughly equivalent to 12fps (60/5 = 12)
	 parameter [9:0] carWidth        = 48;
	 parameter [9:0] carHeight       = 26;
	 //logic [1:0] carType   = 2'b11; //initialize car type to something not possible (only 3 cars)
	 logic [1:0] animFrame = 2'b0;
	 logic [2:0] counter   = 3'b0;
	 logic [9:0] carX      = SpawnX;

    always_ff @ (FrameClk)
    begin
        if (SpawnEnable)
        begin
		      if (counter == framesPerSprite)
				begin
				    counter   <= 3'b0;
					 animFrame <= animFrame + 1;
				end
				else
				    counter <= counter + 1;
				
            //car movement logic goes here
				//.......
        end
		  else
		  begin
		      counter <= 3'b0;
				carX    <= SpawnX;
		  end
    end
	 
	 always_comb
	 begin
	     if (SpawnEnable && carX <= DrawX && DrawX < carX + carWidth && SpawnY <= DrawY && DrawY < SpawnY + carHeight)
		  begin
		      //car_addr = ;
	         CarTopHalf = (SpawnY <= DrawY && DrawY < SpawnY + (carHeight - 16));
	         CarPixel   = 6'b0;//car_data[];
		  end
		  else
		  begin
	         CarTopHalf = 1'b0;
	         CarPixel   = 6'b0;
		  end
	 end

endmodule
