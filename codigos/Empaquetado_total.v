`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:05:18 10/22/2016 
// Design Name: 
// Module Name:    Empaquetado_total 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Empaquetado_total(SEG, AN, DP,/*PosX, PosY,*/ clk,inreset,R,G,B,HSync,VSync,PS2_Clock,PS2_Data,datRTC,CS,AD,RD,WR,pwm_out,inirq);
	//input general
	input clk,inreset;
	//port id, output input port
	wire [7:0] id_port,datosinRTC,datosinteclado,datooutmicro,datoVGA,dirmicro;
	//act's
	wire actRTC,actTeclado,actSonido,actVGA;
	//write read strobe
	wire readstrobe,writestrobe;
	//output VGA
	output [3:0] R,G,B;
	output HSync,VSync;
//	output [9:0]PosX,PosY;
	//input teclado
	input PS2_Clock,PS2_Data;
	//input RTC
	input inirq;
	inout [7:0] datRTC;//dat_RTC = entrada dato_out =salida
	//output RTC
	output CS,AD,RD,WR;
	//output sonido
	output pwm_out;
	// Displays
	output wire [6:0] SEG;
	output wire [7:0] AN;
	output wire DP;
	wire irq, reset;
	// START LLEON
	
	assign reset = inreset;
	assign irq = inirq;
	
	
		reg [7:0] writedata, writeRTC;
		wire [7:0] readdata;
		assign datRTC = WR ? 8'bzz : writeRTC;
		
		always @(posedge clk)
      if (reset) begin
         writedata  <= 8'd0;
         writeRTC <= 8'd0;
      end else begin
			if(WR) writedata  <= datRTC; // write Data es el Dato de Salida RTC
         writeRTC <= readdata; // Read Data es la Entrada de Datos del RTC
         //writeMEM <= escreg;
      end
	// END LLEON
	
	ControlVGACentral_MemoryPointed VGA(.IRQ(irq),/*.PosX(PosX), .PosY(PosY),*/.CLK(clk),.RESET(reset),.actVGA(actVGA),.Port_ID(id_port),.IN_DATA(datooutmicro),.Read_Strobe(readstrobe),.Write_Strobe(writestrobe),.OUT_DATA(datoVGA),.R(R),.G(G),.B(B),.HSync(HSync),.VSync(VSync));
	Keyboard teclado(.seg(SEG), .an(AN), .dp(DP),.CLK(clk),.RESET(reset),.Port_ID(id_port),.Read_Strobe(readstrobe),.Keyboard_Output(datosinteclado),.PS2_Clock(PS2_Clock),.PS2_Data(PS2_Data));
	ModuloRTC RTC(.clk(clk),.reset(reset),.data_out(readdata),.data_out_micro(datosinRTC),.dat_RTC(writedata),.CS(CS),.AD(AD),.RD(RD),.WR(WR),.chipsel(actRTC),.writestrobe(writestrobe),.readstrobe(readstrobe),.irq(irq),.dir_in(dirmicro),.port_id(id_port),.dato_in(datooutmicro));
	empaquetado_audio sonido(.clk(clk),.reset(irq)/*,.act_sonido(actSonido),.data_in(datooutmicro)*/,.pwm_out(pwm_out));
	encapsulado_micro micro(.out_port(datooutmicro),.in_portRTC(datosinRTC),.in_portteclado(datosinteclado),.in_portVGA(datoVGA),.writestrobe(writestrobe),.read_strobe(readstrobe)/*.interrupt(interrupt),.interrupt_ack(interrupt)*/,.clk(clk),.kcpsm6_reset(reset),.actRTC(actRTC), .actVGA(actVGA),.actTeclado(actTeclado),.actsonido(actSonido),.dir(dirmicro),.port_id(id_port));
endmodule
