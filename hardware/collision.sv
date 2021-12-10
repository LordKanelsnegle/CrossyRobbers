//inspired by https://stackoverflow.com/questions/23302698/java-check-if-two-rectangles-overlap-at-any-point

module collision (
    input  logic [9:0] X1, Y1, Width1, Height1, //hitbox 1
	 input  logic [9:0] X2, Y2, Width2, Height2, //hitbox 2
    output logic       Collided
);
	 
	 always_comb
	 begin
	     Collided = X1 < X2 + Width2 && X1 + Width1 > X2 && Y1 < Y2 + Height2 && Y1 + Height1 > Y2;
	 end

endmodule
