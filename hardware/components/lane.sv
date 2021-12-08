
module lane #(parameter [5:0] TileY = 0) (
    input  logic FrameClk, SpawnEnable, Direction,
	 input  logic [1:0] CarType,
    input  logic [2:0] CarCount, CarSpeed,
	 input  logic [9:0] DrawX, DrawY,
    output logic       CarPixel, CarPriority,
	 output logic [3:0] Tile,
    output logic [5:0] PixelX,
    output logic [4:0] PixelY
);

    // Declare local variables
	 
	 localparam [5:0] carWidth   = 48;  //640px width, minus 48px per car, gives total empty space. divide that evenly between the cars
	 
	 logic init         = 1'b0;
	 logic FaceLeft     = 1'b0;
	 logic [1:0] Type   = 2'b0;
	 logic [2:0] Speed  = 3'b0;
	 logic [2:0] Count  = 3'b0;
	 logic [9:0] carSpacing = 10'b0;
	 logic [9:0] SpawnY     = 16 * TileY - 10; //-10 because car tiles are 26px tall but tiles are 16px
	 
	 logic buPriority, c1Priority, c2Priority, c3Priority, c4Priority, c5Priority;
    logic buPixel, c1Pixel, c2Pixel, c3Pixel, c4Pixel, c5Pixel;
	 logic [3:0] buTile, c1Tile, c2Tile, c3Tile, c4Tile, c5Tile;
	 logic [5:0] buPixelX, c1PixelX, c2PixelX, c3PixelX, c4PixelX, c5PixelX;
	 logic [4:0] buPixelY, c1PixelY, c2PixelY, c3PixelY, c4PixelY, c5PixelY;
	 
	 
	 // Snapshot the randomized inputs when SpawnEnable is FIRST set to true
	 
	 always_ff @ (posedge SpawnEnable)
	 begin
	     FaceLeft <= Direction;
		  Type     <= CarType;
		  Speed    <= CarSpeed;
		  Count    <= CarCount;
	 end
	 
	 assign carSpacing = (640 - (carWidth*Count)) / (Count + 1);

	 
	 // Module instantiation - max of 6 cars per lane (including buffer car) means minimum of ~80px between each car
	 
	 car buff (.SpawnEnable(       SpawnEnable       ), .SpawnX(0*carSpacing - 1*carWidth + 100), .CarPixel(buPixel), .CarPriority(buPriority), .Tile(buTile), .PixelX(buPixelX), .PixelY(buPixelY), .*);
    car car1 (.SpawnEnable(SpawnEnable && Count >= 1), .SpawnX(1*carSpacing + 0*carWidth + 100), .CarPixel(c1Pixel), .CarPriority(c1Priority), .Tile(c1Tile), .PixelX(c1PixelX), .PixelY(c1PixelY), .*);
    car car2 (.SpawnEnable(SpawnEnable && Count >= 2), .SpawnX(2*carSpacing + 1*carWidth + 100), .CarPixel(c2Pixel), .CarPriority(c2Priority), .Tile(c2Tile), .PixelX(c2PixelX), .PixelY(c2PixelY), .*);
    car car3 (.SpawnEnable(SpawnEnable && Count >= 3), .SpawnX(3*carSpacing + 2*carWidth + 100), .CarPixel(c3Pixel), .CarPriority(c3Priority), .Tile(c3Tile), .PixelX(c3PixelX), .PixelY(c3PixelY), .*);
    car car4 (.SpawnEnable(SpawnEnable && Count >= 4), .SpawnX(4*carSpacing + 3*carWidth + 100), .CarPixel(c4Pixel), .CarPriority(c4Priority), .Tile(c4Tile), .PixelX(c4PixelX), .PixelY(c4PixelY), .*);
    car car5 (.SpawnEnable(SpawnEnable && Count >= 5), .SpawnX(5*carSpacing + 4*carWidth + 100), .CarPixel(c5Pixel), .CarPriority(c5Priority), .Tile(c5Tile), .PixelX(c5PixelX), .PixelY(c5PixelY), .*);

	 
	 // Module outputs
	 
	 always_comb
	 begin
	     CarPriority = buPriority | c1Priority | c2Priority | c3Priority | c4Priority | c5Priority;
	     CarPixel    = buPixel    |  c1Pixel   |  c2Pixel   |  c3Pixel   |  c4Pixel   |    c5Pixel;
	     if (buPixel)
		  begin
				Tile   = buTile;
				PixelX = buPixelX;
				PixelY = buPixelY;
		  end
		  else if (c1Pixel)
		  begin
				Tile   = c1Tile;
				PixelX = c1PixelX;
				PixelY = c1PixelY;
		  end
		  else if (c2Pixel)
		  begin
				Tile   = c2Tile;
				PixelX = c2PixelX;
				PixelY = c2PixelY;
		  end
		  else if (c3Pixel)
		  begin
				Tile   = c3Tile;
				PixelX = c3PixelX;
				PixelY = c3PixelY;
		  end
		  else if (c4Pixel)
		  begin
				Tile   = c4Tile;
				PixelX = c4PixelX;
				PixelY = c4PixelY;
		  end
		  else if (c5Pixel)
		  begin
				Tile   = c5Tile;
				PixelX = c5PixelX;
				PixelY = c5PixelY;
		  end
		  else
		  begin
				Tile   = 4'b0;
				PixelX = 6'b0;
				PixelY = 5'b0;
		  end
	 end

endmodule
