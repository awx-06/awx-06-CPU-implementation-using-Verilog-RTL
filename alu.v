module alu (	input clk,
		input rst,
                input  [15:0]     mbr,
	        input [3:0]       opcode,
	        input             ld_mbr2ac,
	        input             exrdy,
	        output reg [15:0] ac,
	        output wire       aczero,
	        output wire       acneg,
	        input [15:0]      inreg);


localparam LOAD  = 4'b0001;
localparam STORE = 4'b0010;
localparam ADD   = 4'b0011;
localparam SUB   = 4'b0100;
localparam INPUT = 4'b0101;

reg  [15:0] aluout;  // ALU output

assign aczero = (ac[15:0] == 0) ? 1'b1 : 1'b0;
assign acneg  = ac[15] ? 1'b1 : 1'b0; // ac reg bit 15 msb is the sign bit 

always @(*)
begin
  aluout = 0;
  if (exrdy)
  begin
    case (opcode)
      ADD    :  aluout = ac + mbr;
      SUB    :  aluout = ac + ~mbr + 1;
      default:  ;
    endcase
  end
end

// AC register
always @(posedge clk)
begin
  if (rst)
    ac <= 16'h0000;
  else if (ld_mbr2ac)
    ac <= mbr;
  else if (exrdy)
    ac <= aluout;
end

endmodule
  
