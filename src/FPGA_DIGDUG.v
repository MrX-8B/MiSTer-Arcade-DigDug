//--------------------------------------------
// FPGA DigDug (Top module)
//
//					Copyright (c) 2017 MiSTer-X
//--------------------------------------------
module FPGA_DIGDUG
(
	input          RESET,      // RESET
	input          MCLK,       // Master Clock (48.0MHz) = VCLKx8

	input   [7:0]	INP0,			// Control Panel
	input   [7:0]	INP1,
	input   [7:0]	DSW0,
	input   [7:0]	DSW1,

	input   [8:0]  PH,         // PIXEL H
	input   [8:0]  PV,         // PIXEL V
	output         PCLK,       // PIXEL CLOCK
	output  [7:0]  POUT,       // PIXEL OUT

	output reg [7:0] SOUT,		// SOUND OUT

	output  [7:0]  LED,			// LEDs (for Debug)


	input				ROMCL,		// Downloaded ROM image
	input  [15:0]	ROMAD,
	input	  [7:0]	ROMDT,
	input				ROMEN
);

// Common I/O Device Bus
wire			DEV_CL;
wire [15:0]	DEV_AD;
wire			DEV_RD;
wire			DEV_DV;
wire  [7:0]	DEV_DO;
wire			DEV_WR;
wire  [7:0]	DEV_DI;


//-----------------------------------------------
//  CPUs
//-----------------------------------------------
wire	[2:0]	RSTS,IRQS,NMIS;

DIGDUG_CORES cores
(
	.MCLK(MCLK),
	.RSTS(RSTS),.IRQS(IRQS),.NMIS(NMIS),

	.DEV_CL(DEV_CL),.DEV_AD(DEV_AD),
	.DEV_RD(DEV_RD),.DEV_DV(DEV_DV),.DEV_DO(DEV_DO),
	.DEV_WR(DEV_WR),.DEV_DI(DEV_DI),

	.ROMCL(ROMCL),.ROMAD(ROMAD),.ROMDT(ROMDT),.ROMEN(ROMEN)
);

assign LED = { RSTS, IRQS[1:0], 1'b0, NMIS[2],NMIS[0] };


//-----------------------------------------------
//  Sound wave ROM
//-----------------------------------------------
wire 			WAVECL;
wire [7:0]	WAVEAD;
wire [3:0]	WAVEDT;

DLROM #(8,4) wave(WAVECL,WAVEAD,WAVEDT, ROMCL,ROMAD[7:0],ROMDT,ROMEN & (ROMAD[15:8]==8'hD8));


//-----------------------------------------------
//  Common I/O Device Module
//-----------------------------------------------
wire			PCMCLK;
wire [7:0]	PCMOUT;
always @(posedge PCMCLK) SOUT <= PCMOUT;

wire			FGSCCL;
wire [9:0]	FGSCAD;
wire [7:0]	FGSCDT;

wire			SPATCL;
wire [6:0]	SPATAD;
wire [23:0]	SPATDT;

wire [1:0]	BG_SELECT;
wire [1:0]	BG_COLBNK;
wire			BG_CUTOFF;
wire			FG_CLMODE;

wire			VBLK;

DIGDUG_IODEV iodev
(
	.RESET(RESET),
	.VBLK(VBLK),

	.INP0(INP0),
	.INP1(INP1),
	.DSW0(DSW0),
	.DSW1(DSW1),
	
	.CL(DEV_CL), // Access Clock: 24.0MHz
	.AD(DEV_AD),.WR(DEV_WR),.DI(DEV_DI),
	.RD(DEV_RD),.DV(DEV_DV),.DO(DEV_DO),
	
	.RSTS(RSTS),.IRQS(IRQS),.NMIS(NMIS),

	.CLK48M(MCLK),.PCMCLK(PCMCLK),.PCMOUT(PCMOUT),

	.WAVECL(WAVECL),.WAVEAD(WAVEAD),.WAVEDT(WAVEDT),

	.FGSCCL(FGSCCL),.FGSCAD(FGSCAD),.FGSCDT(FGSCDT),
	.SPATCL(SPATCL),.SPATAD(SPATAD),.SPATDT(SPATDT),

	.BG_SELECT(BG_SELECT),.BG_COLBNK(BG_COLBNK),.BG_CUTOFF(BG_CUTOFF),
	.FG_CLMODE(FG_CLMODE)
);


//-----------------------------------------------
//  Video Module
//-----------------------------------------------
DIGDUG_VIDEO video
(
	.CLK48M(MCLK),
	.POSH(PH+1),.POSV(PV+2),

	.BG_SELECT(BG_SELECT),.BG_COLBNK(BG_COLBNK),.BG_CUTOFF(BG_CUTOFF),
	.FG_CLMODE(FG_CLMODE),

	.FGSCCL(FGSCCL),.FGSCAD(FGSCAD),.FGSCDT(FGSCDT),
	.SPATCL(SPATCL),.SPATAD(SPATAD),.SPATDT(SPATDT),

	.VBLK(VBLK),.PCLK(PCLK),.POUT(POUT),

	.ROMCL(ROMCL),.ROMAD(ROMAD),.ROMDT(ROMDT),.ROMEN(ROMEN)
);


endmodule

