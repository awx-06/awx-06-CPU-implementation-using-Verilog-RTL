module ctrl (	input clk,
		input rst,
		input aczero,
		input acneg,
		input [15:0] mbr,
	        input [15:0] memrdata,
		output reg [11:0] pc,
		output reg [15:0] ir,
		output reg ld_pc2mar,
		output reg ld_ir2mar,
		output reg ld_mdata2mbr,
                output reg ld_mbr2ac,	
		output reg ld_ac2mbr,
		output reg exrdy,
		output reg memwr
		);


// regs and wire declarations
reg inc_pc;		// increment program counter
reg ld_mdata2ir;	// Load mem data to ir reg
reg assert_halt;	// Halt CPU 
reg assert_skip;	// Skip instruction
reg assert_jump;	// Jump to new address specified in ir[11:0]
reg [1:0] cpu_state;	// CPU state register
reg [1:0] state_next;	// CPU next state 

// CPU state parameters
localparam FETCH   = 2'b00;
localparam DECODE  = 2'b01;
localparam MEMRW   = 2'b10;
localparam EXECUTE = 2'b11;

// Instruction opcodes params
localparam NOP    = 4'h0;
localparam LOAD   = 4'h1;
localparam STORE  = 4'h2;
localparam ADD    = 4'h3;
localparam SUB    = 4'h4;
localparam INPUT  = 4'h5;
localparam OUTPUT = 4'h6;
localparam HALT   = 4'h7;
localparam SKIPC  = 4'h8;
localparam JUMP   = 4'h9;


// PC register
always @(posedge clk)
begin	
  if (rst)
    pc <= 12'h000;
  else if (inc_pc)
    pc <= pc + 1;
  else if (assert_skip)
    pc <= pc + 1;
  else if (assert_jump)
    pc <= ir[11:0];
end


// IR instruction register
always @(posedge clk)
begin	
  if (rst)
    ir <= 16'h0000;
  else if (ld_mdata2ir)
    ir <= memrdata;
end


always @(posedge clk)
begin	
  if (rst)
    cpu_state <= FETCH;
  else if (assert_halt)
    cpu_state <= cpu_state;
  else 
    cpu_state <= state_next;
end

always @(*) 
begin 
  state_next = 0;
  case ( cpu_state )     
    FETCH   : state_next = DECODE;              
    DECODE  : state_next = MEMRW;              
    MEMRW   : state_next = EXECUTE;     
    EXECUTE : state_next = FETCH;       
    default : ;   
  endcase
end

always @(*)
begin

  memwr=0;
  inc_pc=0;
  ld_pc2mar=0;
  ld_mdata2ir=0;
  ld_ir2mar=0;
  ld_mdata2mbr=0;
  ld_mbr2ac=0;
  ld_ac2mbr=0;
  assert_halt=0;
  assert_skip=0;
  assert_jump=0;
  exrdy=0;

  case (cpu_state)
    FETCH  :  begin
  		inc_pc=1;
  	 	ld_mdata2ir=1;
	      end
    DECODE :  begin
		case (ir[15:12])
		  LOAD   :  begin
  				ld_ir2mar=1;
			    end
		  STORE  :  begin
  				ld_ir2mar=1;
  				ld_ac2mbr=1;
			    end
		  ADD    :  begin
  				ld_ir2mar=1;
  				ld_mdata2mbr=1;
			    end
		  SUB    :  begin
  				ld_ir2mar=1;
  				ld_mdata2mbr=1;
			    end
		  HALT   :  assert_halt=1;
		  SKIPC  :  assert_skip = ir[11:10]==2'b00 ? acneg : (ir[11:10]==2'b01 ? aczero : 1'b1);
		  JUMP   :  assert_jump=1;
		  default:  ;
	  	endcase
	        end
    MEMRW  :  begin
		case (ir[15:12])
		  LOAD   :  ld_mdata2mbr=1;
		  ADD    :  ld_mdata2mbr=1;
		  SUB    :  ld_mdata2mbr=1;
		  //STORE  :  ld_ac2mbr=1;
		  STORE  :  memwr=1;
		  default:  ;
		endcase
	      end
    EXECUTE:  begin  
  	 	ld_pc2mar=1;
		case (ir[15:12])
		  LOAD   :  ld_mbr2ac=1;
		  //STORE  :  memwr=1;
		  ADD    :  exrdy=1;
		  SUB    :  exrdy=1;
		  default:  ;
		endcase
	      end
  endcase
end

endmodule
  
