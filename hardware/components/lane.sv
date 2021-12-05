
module lane #(parameter [5:0] TileY = 0) (
    input  logic FrameClk, SpawnEnable,
    //input  logic [2:0] CarCount, Speed,
	 input  logic [9:0] DrawX, DrawY,
	 output logic CarTopHalf,
    output logic [5:0] CarPixel
);

    // Declare local variables
	 
	 parameter [2:0] carCount   = 4;//$urandom_range(5);   //picks a random number from 0 to 5, inclusive
	 parameter [5:0] carWidth   = 48;  //640px width, minus 48px per car, gives total empty space. divide that evenly between the cars
	 parameter [9:0] carSpacing = (640 - (carWidth*carCount)) / (carCount + 1);
	 
	 //logic [1:0] Type   = $urandom_range(2);   //picks a random number from 0 to 2, inclusive
	 logic       FaceLeft = 1'b1;//$urandom_range(1);   //picks a random number from 0 to 1, inclusive
	 logic [2:0] Speed    = 3;//$urandom_range(1,5); //picks a random number from 1 to 5, inclusive - might need to tweak
	 logic [9:0] SpawnY   = 16 * TileY - 10;     //-10 because car tiles are 26px tall but tiles are 16px
	 
	 logic c1TopHalf, c2TopHalf, c3TopHalf, c4TopHalf, c5TopHalf;
    logic [5:0] c1Pixel, c2Pixel, c3Pixel, c4Pixel, c5Pixel;

	 
	 // Module instantiation - max of 5 cars per lane means minimum of ~60px between each car
	 
    car #(.SpawnX(1*carSpacing + 0*carWidth)) car1 (.SpawnEnable(SpawnEnable && carCount >= 1), .Type(2'b00), .CarTopHalf(c1TopHalf), .CarPixel(c1Pixel), .*);
    car #(.SpawnX(2*carSpacing + 1*carWidth)) car2 (.SpawnEnable(SpawnEnable && carCount >= 2), .Type(2'b01), .CarTopHalf(c2TopHalf), .CarPixel(c2Pixel), .*);
    car #(.SpawnX(3*carSpacing + 2*carWidth)) car3 (.SpawnEnable(SpawnEnable && carCount >= 3), .Type(2'b10), .CarTopHalf(c3TopHalf), .CarPixel(c3Pixel), .*);
    car #(.SpawnX(4*carSpacing + 3*carWidth)) car4 (.SpawnEnable(SpawnEnable && carCount >= 4), .Type(2'b01), .CarTopHalf(c4TopHalf), .CarPixel(c4Pixel), .*);
    car #(.SpawnX(5*carSpacing + 4*carWidth)) car5 (.SpawnEnable(SpawnEnable && carCount >= 5), .Type(2'b00), .CarTopHalf(c5TopHalf), .CarPixel(c5Pixel), .*);

				  
	 // Module outputs can be OR'd together because car pixels should never overlap
	 
    assign CarTopHalf = c1TopHalf | c2TopHalf | c3TopHalf | c4TopHalf | c5TopHalf;
	 assign CarPixel   = c1Pixel   | c2Pixel   | c3Pixel   | c4Pixel   | c5Pixel;

endmodule
