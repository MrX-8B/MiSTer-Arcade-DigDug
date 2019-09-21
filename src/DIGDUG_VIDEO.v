//--------------------------------------------
// FPGA DigDug (Video part)
//
//					Copyright (c) 2017 MiSTer-X
//--------------------------------------------
module DIGDUG_VIDEO
(
	input					CLK48M,
	input	  [8:0]		POSH,
	input	  [8:0]		POSV,

	input	  [1:0]		BG_SELECT,
	input   [1:0]		BG_COLBNK,
	input					BG_CUTOFF,
	input					FG_CLMODE,

	output				FGSCCL,
	output  [9:0]		FGSCAD,
	input   [7:0]		FGSCDT,

	output				SPATCL,
	output  [6:0]		SPATAD,
	input	 [23:0]		SPATDT,

	output				VBLK,
	output				PCLK,
	output  [7:0]		POUT,


	input					ROMCL,		// Downloaded ROM image
	input  [15:0]		ROMAD,
	input	  [7:0]		ROMDT,
	input					ROMEN
);

//---------------------------------------
//  Clock Generator
//---------------------------------------
reg [2:0] clkdiv;
always @( posedge CLK48M ) clkdiv <= clkdiv+1;
wire VCLKx8 = CLK48M;
wire VCLKx4 = clkdiv[0];
wire VCLKx2 = clkdiv[1];
wire VCLK   = clkdiv[2];


//---------------------------------------
//  Local Offset
//---------------------------------------
reg [8:0] PH, PV;
always@( posedge VCLK ) begin
	PH <= POSH-1;
	PV <= POSV-2;
end


//---------------------------------------
//  VRAM Scan Address Generator
//---------------------------------------
wire  [5:0] SCOL = PH[8:3]-2;
wire  [5:0] SROW = PV[8:3]+2;
wire  [9:0] VSAD = SCOL[5] ? {SCOL[4:0],SROW[4:0]} : {SROW[4:0],SCOL[4:0]};


//---------------------------------------
//  Sprite ScanLine Generator
//---------------------------------------
wire  [4:0]	SPCOL;

DIGDUG_SPRITE sprite
(
	.RCLK(VCLKx8),.VCLK(VCLK),.VCLKx2(VCLKx2),
	.POSH(PH-1),.POSV(PV),
	.SPATCL(SPATCL),.SPATAD(SPATAD),.SPATDT(SPATDT),

	.SPCOL(SPCOL),
	
	.ROMCL(ROMCL),.ROMAD(ROMAD),.ROMDT(ROMDT),.ROMEN(ROMEN)
);


//---------------------------------------
//  FG ScanLine Generator
//---------------------------------------
reg   [4:0] FGCOL;

assign		FGSCCL = VCLKx2;
assign 		FGSCAD = VSAD;

wire [10:0]	FGCHAD = {1'b0,FGSCDT[6:0],PV[2:0]};
wire  [7:0]	FGCHDT;
DLROM #(11,8) fgchip(~VCLKx2,FGCHAD,FGCHDT, ROMCL,ROMAD[10:0],ROMDT,ROMEN & (ROMAD[15:11]=={4'hD,1'b0}));
wire  [7:0] FGCHPX = FGCHDT >> (PH[2:0]);

wire  [3:0] FGCLUT = FG_CLMODE ? FGSCDT[3:0] : ({FGSCDT[7:5],1'b0}|{2'b00,FGSCDT[4],1'b0});

always @( posedge VCLKx2 ) FGCOL <= {FGCHPX[0],FGCLUT};


//---------------------------------------
//  BG ScanLine Generator
//---------------------------------------
wire  [3:0] BGCOL;

wire [11:0] BGSCAD = {BG_SELECT,VSAD};
wire  [7:0] BGSCDT;
DLROM #(12,8) bgscrn(VCLKx2,BGSCAD,BGSCDT, ROMCL,ROMAD[11:0],ROMDT,ROMEN & (ROMAD[15:12]==4'hB));

wire [11:0] BGCHAD = {BGSCDT,~PH[2],PV[2:0]};
wire  [7:0] BGCHDT;
DLROM #(12,8) bgchip(~VCLKx2,BGCHAD,BGCHDT, ROMCL,ROMAD[11:0],ROMDT,ROMEN & (ROMAD[15:12]==4'hC));
wire  [7:0] BGCHPI = BGCHDT << (PH[1:0]);
wire  [1:0] BGCHPX = {BGCHPI[7],BGCHPI[3]};

wire  [7:0] BGCLAD = BG_CUTOFF ? {6'h0F,BGCHPX} : {BG_COLBNK,BGSCDT[7:4],BGCHPX};
DLROM #(8,4) bgclut(VCLKx2,BGCLAD,BGCOL, ROMCL,ROMAD[7:0],ROMDT,ROMEN & (ROMAD[15:8]==8'hDA));


//---------------------------------------
//  Color Mixer & Pixel Output
//---------------------------------------
wire [4:0] CMIX = SPCOL[4] ? {1'b1,SPCOL[3:0]} : FGCOL[4] ? {1'b0,FGCOL[3:0]} : {1'b0,BGCOL};

DLROM #(5,8) palet( VCLK, CMIX, POUT, ROMCL,ROMAD[4:0],ROMDT,ROMEN & (ROMAD[15:5]=={8'hDB,3'b000}) );
assign PCLK = ~VCLK;
assign VBLK = (PH<64)&(PV==224);

endmodule

