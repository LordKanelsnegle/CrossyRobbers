
//Uses 4 LFSRs with different clocks to generate a pseudo-random 4 bit number
module random (
    input  logic ClkA, ClkB, ClkC, ClkD,
	 output logic [3:0] Out
);

    logic [3:0] OutA, OutB, OutC, OutD;
	 lfsr A(.Clk(ClkA),.Out(OutA));
	 lfsr B(.Clk(ClkB),.Out(OutB));
	 lfsr C(.Clk(ClkC),.Out(OutC));
	 lfsr D(.Clk(ClkD),.Out(OutD));
	 assign Out = {OutA,OutB,OutC,OutD};
  
endmodule

//LFSR taps obtained from https://datacipy.cz/lfsr_table.pdf
module lfsr (
    input  logic Clk,
	 output logic [3:0] Out
);

    logic In;
    assign In = (Out[3] == Out[2]); //XNOR is the same as equality

    always_ff @ (posedge Clk)
    begin
        Out = {Out[2:0],In};
    end
  
endmodule