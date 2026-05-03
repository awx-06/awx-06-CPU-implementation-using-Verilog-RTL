module mem (input  [11:0] adr,
            input  [15:0] datain,
			input  write,
            output [15:0] dataout);

reg [15:0] memarray[0:4095];

assign dataout = memarray[adr];

always @(*)
begin
  if (write)
    memarray[adr]=datain;
end

endmodule 


