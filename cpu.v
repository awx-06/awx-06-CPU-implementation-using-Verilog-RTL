module cpu (
	input clk,
	input rst,

	input  [15:0] memrdata,
	output reg [11:0] mar,
	output reg [15:0] mbr,
	output wire	      memwr
	);


// regs and wires 

wire [15:0] ac;
wire [ 3:0] opcode;
wire [11:0] pc;
wire [15:0] ir;
wire ld_pc2mar;
wire ld_ir2mar;
wire ld_mdata2mbr;
wire ld_ac2mbr;		// STORE X
wire ld_mbr2ac;		// LOAD X
wire exrdy;

// mar address register
always @(posedge clk)
begin
  if (rst)
    mar <= 12'h000;
  else 
  begin
  case (1'b1)
    ld_pc2mar :  mar <= pc;
    ld_ir2mar :  mar <= ir[11:0];
    default   :  ;
  endcase
  end
end

// mbr memory buffer register
always @(posedge clk)
begin
  if (rst)
    mbr <= 16'h0000;
  else 
  begin
  case (1'b1)
    ld_ac2mbr    :  mbr <= ac;
    ld_mdata2mbr :  mbr <= memrdata;
    default      :  ;
  endcase
  end
end

alu alu (.rst(rst), .clk(clk), .mbr(mbr), .opcode(ir[15:12]), .ac(ac), 
         .exrdy(exrdy), .aczero(aczero), .acneg(acneg), .ld_mbr2ac(ld_mbr2ac)
	);

ctrl ctrl ( .rst(rst), .clk(clk), .aczero(aczero), .acneg(acneg), .mbr(mbr), 
	    .pc(pc), .ir(ir), .ld_pc2mar(ld_pc2mar), .ld_ir2mar(ld_ir2mar), 
	    .ld_mdata2mbr(ld_mdata2mbr), .ld_ac2mbr(ld_ac2mbr), .exrdy(exrdy), 
	    .memwr(memwr), .memrdata(memrdata), .ld_mbr2ac(ld_mbr2ac)
	  );

endmodule


