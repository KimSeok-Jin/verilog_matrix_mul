module MatMul(clk, reset_n, weight_i, in_i, ni, ti, out_o, val_o, ov_o);
	
	input clk, reset_n;
	input signed [39:0] weight_i;
	input signed [39:0] in_i;
	input [3:0] ni;		//N 입력
	input [4:0] ti;		//T 입력
   
	output signed [39:0]out_o;
	output val_o;
	output ov_o;

	//Internal signals and registers
	reg [4:0] count;
	reg start;
	reg [2:0] wcount;
	reg [2:0] state;
	reg men1, men2, men3, men4, men5;	//mac unit on/off 를 위한 signal=> N값에 따라 on/off
	reg signed [39:0] W1, W2, W3, W4, W5;
	reg signed [39:0] out;
	wire signed [16:0] out11, out12, out13, out14, out15;
	wire signed [16:0] out21, out22, out23, out24, out25;    
	wire signed [16:0] out31, out32, out33, out34, out35; 
	wire signed [16:0] out41, out42, out43, out44, out45; 
	wire signed [16:0] out51, out52, out53, out54, out55;
   
	reg [39:0] in;
	reg signed [39:0] i1, i2, i3, i4, i5;
	reg ion;
   
	reg val, ov;
	wire ov11, ov12, ov13, ov14, ov15;
	wire ov21, ov22, ov23, ov24, ov25;
	wire ov31, ov32, ov33, ov34, ov35;
	wire ov41, ov42, ov43, ov44, ov45;
	wire ov51, ov52, ov53, ov54, ov55;
   
	reg [4:0] cv;
	reg v_on;
   
    //25 MAC modules Instantiation(datapath)
	mac_unit m11(clk, reset_n, i1[39:32], W1[39:32], 17'b0, start, count, men1, out11, ov11);
	mac_unit m12(clk, reset_n, i2[31:24], W1[31:24], out11, start, count, men2, out12, ov12);
	mac_unit m13(clk, reset_n, i3[23:16], W1[23:16], out12, start, count, men3, out13, ov13);
	mac_unit m14(clk, reset_n, i4[15:8], W1[15:8], out13, start, count, men4, out14, ov14);
	mac_unit m15(clk, reset_n, i5[7:0], W1[7:0], out14, start, count, men5, out15, ov15);
   
	mac_unit m21(clk, reset_n, i1[39:32], W2[39:32], 17'b0, start, count, men1, out21, ov21);
	mac_unit m22(clk, reset_n, i2[31:24], W2[31:24], out21, start, count, men2, out22, ov22);
	mac_unit m23(clk, reset_n, i3[23:16], W2[23:16], out22, start, count, men3, out23, ov23);
	mac_unit m24(clk, reset_n, i4[15:8], W2[15:8], out23, start, count, men4, out24, ov24);
	mac_unit m25(clk, reset_n, i5[7:0], W2[7:0], out24, start, count, men5, out25, ov25);
   
	mac_unit m31(clk, reset_n, i1[39:32], W3[39:32], 17'b0, start, count, men1, out31, ov31);
	mac_unit m32(clk, reset_n, i2[31:24], W3[31:24], out31, start, count, men2, out32, ov32);
	mac_unit m33(clk, reset_n, i3[23:16], W3[23:16], out32, start, count, men3, out33, ov33);
	mac_unit m34(clk, reset_n, i4[15:8], W3[15:8], out33, start, count, men4, out34, ov34);
	mac_unit m35(clk, reset_n, i5[7:0], W3[7:0], out34, start, count, men5, out35, ov35);
   
	mac_unit m41(clk, reset_n, i1[39:32], W4[39:32], 17'b0, start, count, men1, out41, ov41);
	mac_unit m42(clk, reset_n, i2[31:24], W4[31:24], out41, start, count, men2, out42, ov42);
	mac_unit m43(clk, reset_n, i3[23:16], W4[23:16], out42, start, count, men3, out43, ov43);
	mac_unit m44(clk, reset_n, i4[15:8], W4[15:8], out43, start, count, men4, out44, ov44);
	mac_unit m45(clk, reset_n, i5[7:0], W4[7:0], out44, start, count, men5, out45, ov45);
   
	mac_unit m51(clk, reset_n, i1[39:32], W5[39:32], 17'b0, start, count, men1, out51, ov51);
	mac_unit m52(clk, reset_n, i2[31:24], W5[31:24], out51, start, count, men2, out52, ov52);
	mac_unit m53(clk, reset_n, i3[23:16], W5[23:16], out52, start, count, men3, out53, ov53);
	mac_unit m54(clk, reset_n, i4[15:8], W5[15:8], out53, start, count, men4, out54, ov54);
	mac_unit m55(clk, reset_n, i5[7:0], W5[7:0], out54, start, count, men5, out55, ov55);
   
	assign out_o=out;
	assign ov_o=ov;
	assign val_o=val;
   
	// Control logic for matrix multiplication
	always @(posedge clk, negedge reset_n) begin
		in<=in_i;
        if (!reset_n) begin      //reset
			count<=0;
			in=0;
			out<=0;
			val<=0;
			ov<=0;
			W1<=0; W2<=0; W3<=0; W4<=0; W5<=0;
			wcount<=6;
			men1<=0; men2<=0; men3<=0; men4<=0; men5<=0;
			ion<=0;
			v_on<=0;
			cv<=0;
        end
		else begin
			count<=ti+5;   //mac unit의 count
			if(wcount==6) wcount<=wcount-1;   //weight 카운트->weight 저장 및 입력
			else if(wcount==5) begin
				W1=weight_i;		
				wcount<=wcount-1;
			end 
			else if (wcount==4) begin
				W2=weight_i;
				wcount<=wcount-1;
			end
			else if (wcount==3) begin
				W3<=weight_i;
				wcount<=wcount-1;
			end
			else if (wcount==2) begin
				W4<=weight_i;
				wcount<=wcount-1;
			end
			else if (wcount==1) begin   
				W5<=weight_i;
				wcount<=wcount-1;
				ion<=1;		//in-transpose 입력
			end
			else begin
				if(!start) start<=0;   //weight 입력 끝나면 start
				else if (start) start<=0;	//mac unit에 들어가는 start signal
				else start<=1;
			end
         
			if(start) start<=0;
		
			case(ni) 	//N 값에 따라 mac unit on/off, 출력 signal 조절
				5: begin	//N=5
					men1<=1; men2<=1; men3<=1; men4<=1; men5<=1;	
					out={out15[7:0],out25[7:0], out35[7:0], out45[7:0], out55[7:0]};
					ov=(ov15|ov25|ov35|ov45|ov55);
				end
				4: begin	//N=4
					men1<=1; men2<=1; men3<=1; men4<=1; men5<=0;
					out={out14[7:0],out24[7:0], out34[7:0], out44[7:0], out54[7:0]};
					ov=(ov14|ov24|ov34|ov44|ov54);
				end
				3: begin	//N=3
					men1<=1; men2<=1; men3<=1; men4<=0; men5<=0;
					out={out13[7:0],out23[7:0], out33[7:0], out43[7:0], out53[7:0]};
					ov=(ov13|ov23|ov33|ov43|ov53);
				end
				2: begin	//N=2
					men1<=1; men2<=1; men3<=0; men4<=0; men5<=0;
					out={out12[7:0],out22[7:0], out32[7:0], out42[7:0], out52[7:0]};
					ov=(ov12|ov22|ov32|ov42|ov52);
				end
				1: begin	//N=1
					men1<=1; men2<=0; men3<=0; men4<=0; men5<=0;
					out={out11[7:0],out21[7:0], out31[7:0], out41[7:0], out51[7:0]};
					ov=(ov11|ov21|ov31|ov41|ov51);
				end
			endcase
		end
	end
		
   
   //transpose in
	always @(posedge clk) begin
		if(!ion) begin 
			i1<=0;
			i2<=0;
			i3<=0;
			i4<=0;
			i5<=0;
			cv<=ti+ni+3;	//valid signal 을 위한 count, 연산 수에 비례
		end
		else if (ion) begin
			i1<=in_i;	//한 사이클 씩 밀려서 입력
			i2<=i1;
			i3<=i2;
			i4<=i3;
			i5<=i4;
			v_on<=1;
		end
	end
   
	always @(posedge clk) begin		//결과 나오기 시작하면 valid signal ON, 연산 끝나면 OFF
		if (v_on) begin	
			cv<=cv-1;
			if (cv==(ti+1)) begin
				val<=1;
			end 
			else if (cv==1) begin
				val<=0;
				v_on<=0;
				cv<=1;
			end	
		end
	end

endmodule


module mac_unit (clk, reset_n, in, weight, preout, start, count, men, out,ov);
   
	input clk, reset_n;
	input start;
	input [4:0] count;
	
	input signed [7:0] in, weight;
	input signed [16:0] preout;
	input men;
	output signed [16:0] out;
	output ov;
	//mac on/off => men signal
	reg   [4:0] creg;
	wire Zero = (creg == 0);   // counter is zero
	wire en = ((creg != 0)&&men); // en when counter reg is not zero
	
	//reg En_reg0, En_reg1, En_reg2;
	reg En_reg0, En_reg1, En_reg2;
	reg signed [7:0] in_reg0, weight_reg0;
	//reg signed [15:0] mul, outreg;
	reg signed [16:0] outreg;
	reg signed [16:0] mul;
	reg ov_reg;
   
	//mac enable 이 OFF => 작동X
	always @(posedge clk, negedge reset_n, men) begin 
		if(!reset_n) begin
			creg<=0;
			in_reg0<=0;
			weight_reg0<=0;
			mul<=0;
			outreg<=0;
			ov_reg<=0;
		end
		else if (men)begin
			if(start) creg<=count;
			else if(Zero) creg<=0;
			else if(en) creg<=creg-1;
		end
	end
   
	always @(posedge clk, en, men) begin
		if (men) begin
			if (en) begin
				En_reg0<=1;
			end
			if(En_reg0) begin
				En_reg1<=1;
				En_reg2<=1;
			end
			if (!en) begin
				En_reg0<=0;
				En_reg1<=En_reg0;
				En_reg2<=En_reg1;
			end
		end
	end
   
	always @(posedge clk,men) begin
		if (men) begin
			in_reg0<=in;
			weight_reg0<=weight;  
			if (En_reg0) begin
				mul<=in_reg0*weight_reg0;
			end
			if (En_reg2) begin
				outreg<=preout+mul;
			end
			if ((preout+mul > 127) | (preout+mul<-128))
				ov_reg <= 1;
			else begin
				ov_reg <= 0;
			end
		end
	end

	assign out = outreg;
	assign ov = ov_reg;
   
endmodule
