`timescale 1ns/100ps
module cpu_tb;

reg clk=0;
reg sys_rst;
reg rst, rst1;

wire memwr;
wire [11:0] mar;
wire [15:0] mbr;
wire [15:0] memrdata;

always @(posedge clk)
begin
  rst1 <= sys_rst; //DFF1
  rst  <= rst1;    //DFF2
end


cpu cpu ( .clk(clk), .rst(rst), .mar(mar), .memrdata(memrdata), 
	  .mbr(mbr), .memwr(memwr));


mem mem (.adr(mar), .datain(mbr), .write(memwr), .dataout(memrdata));


// clock generator
always begin
  #5 clk = ~clk;
end

// dump waveform/signals
initial
  $dumpvars;

initial
  $readmemh("test.hex", mem.memarray);

initial 
begin
  sys_rst  = 1;
  #1000 ;
  sys_rst  = 0;

  wait(cpu.ctrl.assert_halt);
  #100000;

  $display("memarray[40] = %d\n", mem.memarray[40]) ;
  $display("simulation done") ;
  $finish;
end 


endmodule
