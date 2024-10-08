/*****************************************
    testbench.v

    Project 1
    
    Team 06 : 
        2020104167    Kim Seokjin
        2022104234    Kim Hyerim
*****************************************/

module testbench;

    reg CLK, RSTN;

    /// CLOCK Generator ///
    parameter   PERIOD = 10.0;
    parameter   HPERIOD = PERIOD/2.0;

    initial CLK <= 1'b0;
    always #(HPERIOD) CLK <= ~CLK;

	// Include other Input signals if needed.
	// Do not modify the given I/O signals for the top module stated below.
	//Additional required signals: weight/input enable signals (enW_i, enI_i)

	// N, T variables
	parameter N = 3; //N = 1~5
	parameter T = 8; // Any values (but set to 1~10)
	
	//Input
	reg [5*8-1:0]    Weight_i;
	reg [5*8-1:0]    In_i;
	reg [3:0] NI=N;
	reg [4:0] TI=T;
	
	//Output - Cannot be modified.
	wire [5*8-1:0] OUT_o;		//Column output
	wire VAL_o;		//Column Output Valid signal 
	wire OV_o;		//Overflow
	
	//Top module instantiation: Include I/O signals and change the port name if needed.
	
	
	
	MatMul	MatMul(.clk(CLK), .reset_n(RSTN), .weight_i(Weight_i), .in_i(In_i), .ni(NI), .ti(TI), .out_o(OUT_o), .val_o(VAL_o), .ov_o(OV_o));
	
	// --------------------------------------------
	// Load Weight (5 X N) and Input (N X T) test matrices.
	// --------------------------------------------
	// Caution : Assumption : input files have hex data like below. 
	//			 Weight     : (1,1) (1,2) ... (1,N)
	//          (N= 1~5)      (2,1) (2,2) ... (2,N)
	//                        (3,1) (3,2) ... (3,N)
	//                        (4,1) (4,2) ... (4,N)
	//                        (5,1) (5,2) ... (5,N)
	//
	//		  In_transpose  : (1,1) (1,2) ... (1,N)
	//          (N= 1~5)      (2,1) (2,2) ... (2,N)
	//          (T=No limit)  (3,1) (3,2) ... (3,N)
	//                         ...   ...  ...  ...
	//                        (T,1) (T,1) ... (T,N)
	
	reg		[5*8-1:0]    weight [0:4];
	reg		[5*8-1:0]    in_transpose [0:T-1];
	reg enW_i;
	reg enI_i;
	
	
	//Do not change the hex file name.
	initial begin
		$readmemh("weight.hex", weight);
		$readmemh("in_transpose.hex", in_transpose);
	end

	integer i;

	initial begin
		RSTN <= 1'b0;
		#(10*PERIOD)
		RSTN <= 1'b1;
		
		////////////////////////////////////////////////////
		//Write your own testbench to test your module.
		//Do not manually insert input data (Weight, In) in this space.
		//Input data should only be inserted by wiring from the hex file mentioned above.
		////////////////////////////////////////////////////

		//Signal Initialization

		//Weight insertion
		for (i=0; i<5; i=i+1) begin
			#(1*PERIOD) Weight_i <= weight[i]; enW_i <= 1'b1;
		end
		
		//'In' insertion column by column (N data stored in a single vector in 'in_transpose')
		for (i=0; i<T; i=i+1) begin
			#(1*PERIOD) In_i <= in_transpose[i]; enI_i <= 1'b1;
		end
		
		#(1*PERIOD) In_i <= 40'b0; enI_i <= 1'b0;		

		#(100*PERIOD);
		$finish();
	end

	/// Waveform Dump ///
	initial begin
		$display("Dump variables..");
		$dumpfile("./prj1.vcd");
		$dumpvars(0, testbench);
	end

endmodule

