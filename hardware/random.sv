
//Uses 4 LFSRs with different clocks to generate a pseudo-random 4 bit number
module random (
    input  logic ClkA, ClkB, ClkC, ClkD,
	 output logic [19:0] Out
);

    logic [3:0] OutA, OutB, OutC, OutD;
	 lfsr A(.Clk(ClkA),.Out(OutA));
	 lfsr B(.Clk(ClkB),.Out(OutB));
	 lfsr C(.Clk(ClkC),.Out(OutC));
	 lfsr D(.Clk(ClkD),.Out(OutD));
	 assign Out = {OutA,OutB,OutC,OutD};
  
endmodule

module lfsr (
    input  logic Clk,
	 output logic [4:0] Out
);

    logic In;
    assign In = (Out[0] ^ Out[2]); //taps obtained from https://zipcpu.com/dsp/2017/11/11/lfsr-example.html

    always_ff @ (posedge Clk)
    begin
        Out = {Out[3:0],In};
    end
  
endmodule
