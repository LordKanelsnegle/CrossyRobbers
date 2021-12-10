
module lane #(parameter [5:0] TileY = 0) (
    input  logic       FrameClk, SpawnEnable, Direction,
	 input  logic [1:0] CarType,
    input  logic [2:0] CarCount, CarSpeed,
	 input  logic [4:0] P1HbOffset, P2HbOffset,
	 input  logic [9:0] DrawX, DrawY, P1X, P1Y, P2X, P2Y,
    output logic       P1Hit, P2Hit, CarPixel,
	 output logic [3:0] Tile,
    output logic [5:0] PixelX,
    output logic [4:0] PixelY
);

    // LOCAL LOGIC
	 
	 localparam [5:0] carWidth   = 6'd48;  //640px width, minus 48px per car, gives total empty space. divide that evenly between the cars
	 
	 logic FaceLeft;
	 logic [1:0] Type;
	 logic [2:0] Speed;
	 logic [2:0] Count;
	 logic [9:0] carSpacing;
	 logic [9:0] SpawnY = 10'd16 * TileY - 10'd10; //-10 because car tiles are 26px tall but tiles are 16px
	 
    logic buP1Hit, c1P1Hit, c2P1Hit, c3P1Hit, c4P1Hit, c5P1Hit;
	 logic buP2Hit, c1P2Hit, c2P2Hit, c3P2Hit, c4P2Hit, c5P2Hit;
    logic buPixel, c1Pixel, c2Pixel, c3Pixel, c4Pixel, c5Pixel;
	 logic [3:0] buTile, c1Tile, c2Tile, c3Tile, c4Tile, c5Tile;
	 logic [5:0] buPixelX, c1PixelX, c2PixelX, c3PixelX, c4PixelX, c5PixelX;
	 logic [4:0] buPixelY, c1PixelY, c2PixelY, c3PixelY, c4PixelY, c5PixelY;
	 
	 
	 // INIT LOGIC
	 
	 always_ff @ (posedge SpawnEnable)
	 begin
	     FaceLeft <= Direction;
		  Type     <= CarType;
		  Speed    <= CarSpeed;
		  Count    <= CarCount;
	 end

	 
	 // OUTPUT LOGIC
	 
	 always_comb
	 begin
	     carSpacing = (10'd640 - (carWidth*Count)) / (Count + 1'b1);
	     P1Hit = buP1Hit | c1P1Hit | c2P1Hit | c3P1Hit | c4P1Hit | c5P1Hit;
	     P2Hit = buP2Hit | c1P2Hit | c2P2Hit | c3P2Hit | c4P2Hit | c5P2Hit;
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

	 
	 // MODULE INSTANTIATION
	 
	 car buff (.SpawnEnable(       SpawnEnable       ), .SpawnX(         100 - carWidth        ), .P1Hit(buP1Hit), .P2Hit(buP2Hit), .CarPixel(buPixel), .Tile(buTile), .PixelX(buPixelX), .PixelY(buPixelY), .*);
    car car1 (.SpawnEnable(SpawnEnable && Count >= 1), .SpawnX(1*carSpacing + 0*carWidth + 100), .P1Hit(c1P1Hit), .P2Hit(c1P2Hit), .CarPixel(c1Pixel), .Tile(c1Tile), .PixelX(c1PixelX), .PixelY(c1PixelY), .*);
    car car2 (.SpawnEnable(SpawnEnable && Count >= 2), .SpawnX(2*carSpacing + 1*carWidth + 100), .P1Hit(c2P1Hit), .P2Hit(c2P2Hit), .CarPixel(c2Pixel), .Tile(c2Tile), .PixelX(c2PixelX), .PixelY(c2PixelY), .*);
    car car3 (.SpawnEnable(SpawnEnable && Count >= 3), .SpawnX(3*carSpacing + 2*carWidth + 100), .P1Hit(c3P1Hit), .P2Hit(c3P2Hit), .CarPixel(c3Pixel), .Tile(c3Tile), .PixelX(c3PixelX), .PixelY(c3PixelY), .*);
    car car4 (.SpawnEnable(SpawnEnable && Count >= 4), .SpawnX(4*carSpacing + 3*carWidth + 100), .P1Hit(c4P1Hit), .P2Hit(c4P2Hit), .CarPixel(c4Pixel), .Tile(c4Tile), .PixelX(c4PixelX), .PixelY(c4PixelY), .*);
    car car5 (.SpawnEnable(SpawnEnable && Count >= 5), .SpawnX(5*carSpacing + 4*carWidth + 100), .P1Hit(c5P1Hit), .P2Hit(c5P2Hit), .CarPixel(c5Pixel), .Tile(c5Tile), .PixelX(c5PixelX), .PixelY(c5PixelY), .*);

endmodule
