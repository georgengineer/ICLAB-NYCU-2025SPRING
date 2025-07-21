//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab04 Exercise		: Two Head Attention
//   Author     		: Yu-Chi Lin (a6121461214.st12@nycu.edu.tw)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : ATTN.v
//   Module Name : ATTN
//   Release version : V1.0 (Release Date: 2025-3)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################


module ATTN(
    //Input Port
    clk,
    rst_n,

    in_valid,
    in_str,
    q_weight,
    k_weight,
    v_weight,
    out_weight,

    //Output Port
    out_valid,
    out
    );

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point parameter
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;
parameter inst_faithful_round = 0;
parameter sqare_root_2 = 32'b00111111101101010000010011110011;

parameter IDLE = 3'd0;
parameter IN = 3'd1;
parameter CAL = 3'd2;
parameter OUT = 3'd3;
integer i;
input rst_n, clk, in_valid;
input [inst_sig_width+inst_exp_width:0] in_str, q_weight, k_weight, v_weight, out_weight;

output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;


//---------------------------------------------------------------------
//   Reg & Wires
//---------------------------------------------------------------------
reg[inst_sig_width+inst_exp_width:0] reg_in_str[0:19];
reg[inst_sig_width+inst_exp_width:0] reg_k[0:15];
reg[inst_sig_width+inst_exp_width:0] reg_q[0:15];
reg[inst_sig_width+inst_exp_width:0] reg_v[0:15];
reg[inst_sig_width+inst_exp_width:0] reg_out_weight[0:15];
reg[4:0]weight_counter;
//---------------------------------------------------------------------
// IPs
//---------------------------------------------------------------------
// ex.
//DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
//MUL1 ( .a(mul1_a), .b(mul1_b), .rnd(3'b000), .z(mul1_res), .status(mul_status1));


wire control_0;
wire control_1;
wire control_2;
wire control_3;
assign control_1=(weight_counter==1)?1'b1:1'b0;
assign control_2=(weight_counter==2)?1'b1:1'b0;
assign control_3=(weight_counter==3)?1'b1:1'b0;
assign control_4=(weight_counter==4)?1'b1:1'b0;
reg [9:0]counter;

reg[inst_sig_width+inst_exp_width:0] k[0:19];
reg[inst_sig_width+inst_exp_width:0] q[0:19];
reg[inst_sig_width+inst_exp_width:0] v[0:19];
reg[inst_sig_width+inst_exp_width:0] score_1[0:24];
reg[inst_sig_width+inst_exp_width:0] score_2[0:24];
wire shift_enable;
assign shift_enable=(counter==26 || counter==28 || counter==30 || counter==32)?1'b1:1'b0;
// ---------k----------// 
reg [31:0]reg_mul_a_0,reg_mul_b_0;
reg [31:0]reg_mul_a_1,reg_mul_b_1;
reg [31:0]reg_mul_a_2,reg_mul_b_2;
reg [31:0]reg_mul_a_3,reg_mul_b_3;
reg [31:0]f0,f1,f2,f3;
wire [31:0]wire_f0,wire_f1,wire_f2,wire_f3;
reg  [31:0]out_f0,out_f1,out_f2,out_f3;

// ---------q----------// 
reg [31:0]reg_mul_a_4,reg_mul_b_4;
reg [31:0]reg_mul_a_5,reg_mul_b_5;
reg [31:0]reg_mul_a_6,reg_mul_b_6;
reg [31:0]reg_mul_a_7,reg_mul_b_7;
reg [31:0]q_f0,q_f1,q_f2,q_f3;
wire [31:0]q_wire_f0,q_wire_f1,q_wire_f2,q_wire_f3;
reg  [31:0]q_out_f0 ,q_out_f1 ,q_out_f2 ,q_out_f3; 

// ---------v----------// 
reg [31:0]reg_mul_a_8 ,reg_mul_b_8;
reg [31:0]reg_mul_a_9 ,reg_mul_b_9;
reg [31:0]reg_mul_a_10,reg_mul_b_10;
reg [31:0]reg_mul_a_11,reg_mul_b_11;
reg [31:0]v_f0,v_f1,v_f2,v_f3;
wire [31:0]v_wire_f0,v_wire_f1,v_wire_f2,v_wire_f3;
reg  [31:0]v_out_f0 ,v_out_f1 ,v_out_f2 ,v_out_f3; 

///divide
reg [31:0]reg_div_a_0; 
reg [31:0]reg_div_a_1;
wire[31:0]div_wire_1,div_wire_2;            
reg [31:0]reg_divide_1;
reg [31:0]reg_divide_2;
reg[31:0]exp_1,exp_2;
wire[31:0]wire_exp_1;
wire[31:0]wire_exp_2;
reg [31:0]reg_exp_1;
reg [31:0]reg_exp_2;
//addsum
reg [31:0]add_1,add_2;
wire[31:0]wire_add_1,wire_add_2,wire_add_3,wire_add_4,wire_add_5;
reg [31:0]reg_add_1,reg_add_2;
reg [31:0]add_f1,add_f2;
reg [31:0]reg_sum_1,reg_sum_2;
//divide2
reg [31:0]reg_div_numerator_1; 
reg [31:0]reg_div_denominator_1;
reg [31:0]reg_div_numerator_2; 
reg [31:0]reg_div_denominator_2;

wire[31:0]div_wire_3,div_wire_4;  
reg [31:0]softmax_1,softmax_2;

//head out
reg [31:0]head_out_1;
reg [31:0]head_out_2;
reg [31:0]head_out_3;
reg [31:0]head_out_4;
wire[31:0]wire_head_out_1;
wire[31:0]wire_head_out_2;
wire[31:0]wire_head_out_3;
wire[31:0]wire_head_out_4;
//out_weight ^T 
reg [31:0]out_weight_1;
reg [31:0]out_weight_2;
reg [31:0]out_weight_3;
reg [31:0]out_weight_4;
wire[31:0]wire_out_weight_1;
wire[31:0]wire_out_weight_2;
wire[31:0]wire_out_weight_3;
wire[31:0]wire_out_weight_4;
//NONE USE
reg [31:0]div_f0,div_f1;
reg [31:0]div_out_f0,div_out_f1;
reg [inst_sig_width+inst_exp_width:0]reg_div_f1;
reg [inst_sig_width+inst_exp_width:0]reg_div_f2;
wire[inst_sig_width+inst_exp_width:0]wire_exp_f1,wire_exp_f2;
reg [inst_sig_width+inst_exp_width:0]reg_exp_f1,reg_exp_f2;




reg [31:0]exp_shift[0:5];
reg [31:0]exp_shift_2[0:5];

reg[31:0]wire_divide_1,wire_divide_2;





//---------------------------------------------------------------------
// Design
//---------------------------------------------------------------------
always @(posedge clk  or negedge rst_n)begin	
	if(!rst_n)begin
		for(i=0;i<20;i=i+1)begin
			reg_in_str[i] <= 32'd0;
		end
	end		
	else if(in_valid)
		reg_in_str[weight_counter] <= in_str;
    else begin
        case(counter)
        26:begin
            reg_in_str[0]<=wire_f0;
            reg_in_str[1]<=wire_f1;
            reg_in_str[2]<=wire_f2;
            reg_in_str[3]<=wire_f3;
            reg_in_str[4]<=q_wire_f0;
        end

        28:begin
            //reg_in_str[1]<=div_wire_1;//divide

            reg_in_str[5]<=wire_f0;
            reg_in_str[6]<=wire_f1;
            reg_in_str[7]<=wire_f2;
            reg_in_str[8]<=wire_f3;
            reg_in_str[9]<=q_wire_f0;
        end
        30:begin
            //reg_in_str[3]<=div_wire_1;//divide

            reg_in_str[10]<=wire_f0;
            reg_in_str[11]<=wire_f1;
            reg_in_str[12]<=wire_f2;
            reg_in_str[13]<=wire_f3;
            reg_in_str[14]<=q_wire_f0;
        end
        32:begin
            //reg_in_str[5]<=div_wire_1;//divide

            reg_in_str[15]<=wire_f0;
            reg_in_str[16]<=wire_f1;
            reg_in_str[17]<=wire_f2;
            reg_in_str[18]<=wire_f3;
            reg_in_str[19]<=q_wire_f0;
        end
        //Final_res store data
        43:begin
            reg_in_str[0]<=q_wire_f0;
            reg_in_str[1]<=q_wire_f1;
            reg_in_str[2]<=q_wire_f2;
            reg_in_str[3]<=q_wire_f3;
        end


        48:begin
            reg_in_str[4]<=q_wire_f0;
            reg_in_str[5]<=q_wire_f1;
            reg_in_str[6]<=q_wire_f2;
            reg_in_str[7]<=q_wire_f3;
        end


        53:begin
            reg_in_str[8]<=q_wire_f0;
            reg_in_str[9]<=q_wire_f1;
            reg_in_str[10]<=q_wire_f2;
            reg_in_str[11]<=q_wire_f3;
        end
        58:begin
            reg_in_str[12]<=q_wire_f0;
            reg_in_str[13]<=q_wire_f1;
            reg_in_str[14]<=q_wire_f2;
            reg_in_str[15]<=q_wire_f3;
        end
        63:begin
            reg_in_str[16]<=q_wire_f0;
            reg_in_str[17]<=q_wire_f1;
            reg_in_str[18]<=q_wire_f2;
            reg_in_str[19]<=q_wire_f3;
        end
        /*68:begin
            reg_in_str[20]<=q_wire_f0;
            reg_in_str[21]<=q_wire_f1;
            reg_in_str[22]<=q_wire_f2;
            reg_in_str[23]<=q_wire_f3;
        end*/
        /*27:begin
            reg_in_str[0]<=div_wire_1;//divide
            
        end
        29:begin
            reg_in_str[2]<=div_wire_1;//divide
            
        end
        31: begin
            reg_in_str[4] <= div_wire_1; // divide
        end
        33: begin
            reg_in_str[6] <= div_wire_1;
        end
        34: begin
            reg_in_str[7] <= div_wire_1;
        end
        35: begin
            reg_in_str[8] <= div_wire_1;
        end
        36: begin
            reg_in_str[9] <= div_wire_1;
        end
        37: begin
            reg_in_str[10] <= div_wire_1;
        end
        38: begin
            reg_in_str[11] <= div_wire_1;
        end
        39: begin
            reg_in_str[12] <= div_wire_1;
        end
        40: begin
            reg_in_str[13] <= div_wire_1;
        end
        41: begin
            reg_in_str[14] <= div_wire_1;
        end
        42: begin
            reg_in_str[15] <= div_wire_1;
        end
        43: begin
            reg_in_str[16] <= div_wire_1;
        end
        44: begin
            reg_in_str[17] <= div_wire_1;
        end
        45: begin
            reg_in_str[18] <= div_wire_1;
        end
        46: begin
            reg_in_str[19] <= div_wire_1;
        end*/       
        endcase
    end
end
always @(posedge clk  or negedge rst_n)begin	
	if(!rst_n)begin
		for(i=0;i<16;i=i+1)begin
			reg_k[i] <= 32'd0;
		end
	end		
	else if(in_valid)
		reg_k[weight_counter] <= k_weight;

    else begin
        case(counter)
        34:begin
            //reg_k[14]<=div_wire_2;

            reg_k[0]<=wire_f0;  //reg_in_str[20]<=wire_f0;  
            reg_k[1]<=wire_f1;  //reg_in_str[21]<=wire_f1;  
            reg_k[2]<=wire_f2;  //reg_in_str[22]<=wire_f2;  
            reg_k[3]<=wire_f3;  //reg_in_str[23]<=wire_f3;  
            reg_k[4]<=q_wire_f0;//reg_in_str[24]<=q_wire_f0;
        end
        26:begin
            reg_k[5]<=0;//not usage
            reg_k[6]<=0;//not usage
            reg_k[7] <=q_wire_f1;
            reg_k[8] <=q_wire_f2;
            reg_k[9] <=q_wire_f3;
            reg_k[10]<=v_wire_f0;
            reg_k[11]<=v_wire_f1;
        end
        
        28:begin
            //reg_k[8]<=div_wire_2;
            
            reg_k[12]<=q_wire_f1;
            reg_k[13]<=q_wire_f2;
            reg_k[14]<=q_wire_f3;
            reg_k[15]<=v_wire_f0;
        end
        /*
        27:begin
            reg_k[7]<=div_wire_2;
        end
        29:begin
            reg_k[9]<=div_wire_2;
        end
        30:begin
            reg_k[10]<=div_wire_2;
        end
        31:begin
            reg_k[11]<=div_wire_2;
        end
        32:begin
            reg_k[12]<=div_wire_2;
        end
        33:begin
            reg_k[13]<=div_wire_2;
        end
        35:begin
            reg_k[15]<=div_wire_2;
        end

        //        47: reg_in_str[20] <= div_wire_1;
        47: begin
            reg_k[0] <= div_wire_1;
        end
        48: begin
            reg_k[1] <= div_wire_1;
        end
        49: begin
            reg_k[2] <= div_wire_1;
        end
        50: begin
            reg_k[3] <= div_wire_1;
        end
        51: begin
            reg_k[4] <= div_wire_1;
        end*/
        endcase
    end
end
always @(posedge clk  or negedge rst_n)begin	
	if(!rst_n)begin
		for(i=0;i<16;i=i+1)begin
			reg_q[i] <= 32'd0;
		end
	end		
	else if(in_valid)
		reg_q[weight_counter] <= q_weight;
    else begin
        case(counter)
        28:begin
            reg_q[0]<=v_wire_f1;
        end
        30:begin
            reg_q[1]<=q_wire_f1;
            reg_q[2]<=q_wire_f2;
            reg_q[3]<=q_wire_f3;
            reg_q[4]<=v_wire_f0;
            reg_q[5]<=v_wire_f1;
        end
        32:begin
            reg_q[6] <=q_wire_f1;
            reg_q[7] <=q_wire_f2;
            reg_q[8] <=q_wire_f3;
            reg_q[9] <=v_wire_f0;
            reg_q[10]<=v_wire_f1;
        end
        34:begin
            reg_q[11] <=q_wire_f1;
            reg_q[12] <=q_wire_f2;
            reg_q[13] <=q_wire_f3;
            reg_q[14] <=v_wire_f0;
            reg_q[15]<=v_wire_f1;  
        end
        /*
        36:begin
            reg_q[0] <= div_wire_2;
        end
        37: begin
            reg_q[1] <= div_wire_2;
        end
        38: begin
            reg_q[2] <= div_wire_2;
        end
        39: begin
            reg_q[3] <= div_wire_2;
        end
        40: begin
            reg_q[4] <= div_wire_2;
        end
        41: begin
            reg_q[5] <= div_wire_2;
        end
        42: begin
            reg_q[6] <= div_wire_2;
        end
        43: begin
            reg_q[7] <= div_wire_2;
        end
        44: begin
            reg_q[8] <= div_wire_2;
        end
        45: begin
            reg_q[9] <= div_wire_2;
        end
        46: begin
            reg_q[10] <= div_wire_2;
        end
        47: begin
            reg_q[11] <= div_wire_2;
        end
        48: begin
            reg_q[12] <= div_wire_2;
        end
        49: begin
            reg_q[13] <= div_wire_2;
        end
        50: begin
            reg_q[14] <= div_wire_2;
        end
        51: begin
            reg_q[15] <= div_wire_2;
        end*/
        endcase
    end
end

always @(posedge clk  or negedge rst_n)begin	
	if(!rst_n)begin
		for(i=0;i<16;i=i+1)begin
			reg_v[i] <= 32'd0;
		end
	end		
	else if(in_valid)
		reg_v[weight_counter] <= v_weight;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		weight_counter <= 'd0;
    end
    else if(in_valid)
		weight_counter <= weight_counter + 'd1;	
    else begin
		weight_counter <= 'd0;
    end
end
always @(posedge clk  or negedge rst_n)begin	
	if(!rst_n)begin
		for(i=0;i<16;i=i+1)begin
			reg_out_weight[i] <= 32'd0;
		end
	end		
	else if(in_valid)
        reg_out_weight[weight_counter] <= out_weight;
end
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		counter <= 0;
    else if(counter==68)
        counter<=0;
    else if(in_valid)
		counter <=counter + 'd1;	
    else if(counter>0)begin
		counter <=counter + 'd1;	
    end
    else 
        counter <=counter;
end




// ---------k1----------// 
always@(*)begin
    case(counter)
          1:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[0 ],reg_k[0 ],32'b0};
          2:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[1 ],reg_k[1 ],out_f0};
          3:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[2 ],reg_k[2 ],out_f0};
          4:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[3 ],reg_k[3 ],out_f0};

          9:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[8 ],reg_k[0 ],32'b0};
         10:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[9 ],reg_k[1 ],out_f0};
         11:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[10],reg_k[2 ],out_f0};
         12:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[11],reg_k[3 ],out_f0};

         13:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[0 ],reg_k[8 ],32'b0};
         14:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[1 ],reg_k[9 ],out_f0};
         15:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[2 ],reg_k[10],out_f0};
         16:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[3 ],reg_k[11],out_f0};

         17:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[12],reg_k[0 ],32'b0};
         18:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[13],reg_k[1 ],out_f0};
         19:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[14],reg_k[2 ],out_f0};
         20:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[15],reg_k[3 ],out_f0};

         21:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[16],reg_k[0 ],32'b0};
         22:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[17],reg_k[1 ],out_f0};
         23:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[18],reg_k[2 ],out_f0};
         24:{reg_mul_a_0,reg_mul_b_0,f0}={reg_in_str[19],reg_k[3 ],out_f0};

         25:{reg_mul_a_0,reg_mul_b_0,f0}={k[0 ],q[0 ],32'b0};
         26:{reg_mul_a_0,reg_mul_b_0,f0}={k[1 ],q[1 ],out_f0};
         27:{reg_mul_a_0,reg_mul_b_0,f0}={k[0 ],q[0 ],32'b0};
         28:{reg_mul_a_0,reg_mul_b_0,f0}={k[1 ],q[1 ],out_f0};
         29:{reg_mul_a_0,reg_mul_b_0,f0}={k[0 ],q[0 ],32'b0};
         30:{reg_mul_a_0,reg_mul_b_0,f0}={k[1 ],q[1 ],out_f0};
         31:{reg_mul_a_0,reg_mul_b_0,f0}={k[0 ],q[0 ],32'b0};
         32:{reg_mul_a_0,reg_mul_b_0,f0}={k[1 ],q[1 ],out_f0};
         33:{reg_mul_a_0,reg_mul_b_0,f0}={k[0 ],q[0 ],32'b0};
         34:{reg_mul_a_0,reg_mul_b_0,f0}={k[1 ],q[1 ],out_f0};
         

         35:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[0 ],32'b0} ; //head_out
         36:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[4 ],out_f0};
         37:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[8 ],out_f0};
         38:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[12],out_f0};
         39:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[16],out_f0};
         40:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[0 ],32'b0} ;
         41:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[4 ],out_f0};
         42:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[8 ],out_f0};
         43:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[12],out_f0};
         44:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[16],out_f0};
         45:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[0 ],32'b0} ;
         46:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[4 ],out_f0};
         47:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[8 ],out_f0};
         48:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[12],out_f0};
         49:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[16],out_f0};
         50:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[0 ],32'b0} ;
         51:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[4 ],out_f0};
         52:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[8 ],out_f0};
         53:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[12],out_f0};
         54:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[16],out_f0};
         55:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[0 ],32'b0} ;
         56:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[4 ],out_f0};
         57:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[8 ],out_f0};
         58:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[12],out_f0};
         59:{reg_mul_a_0,reg_mul_b_0,f0}={softmax_1,v[16],out_f0};



    default:{reg_mul_a_0,reg_mul_b_0,f0}={32'b0,32'b0,32'b0};
    endcase
end
// ---------k2----------// 
always@(*)begin
    case(counter)
          5:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[0 ],reg_k[4 ],32'b0};
          6:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[1 ],reg_k[5 ],out_f1};
          7:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[2 ],reg_k[6 ],out_f1};
          8:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[3 ],reg_k[7 ],out_f1};

          9:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[8 ],reg_k[4 ],32'b0};
         10:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[9 ],reg_k[5 ],out_f1};
         11:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[10],reg_k[6 ],out_f1};
         12:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[11],reg_k[7 ],out_f1};

         13:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[0 ],reg_k[12],32'b0};
         14:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[1 ],reg_k[13],out_f1};
         15:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[2 ],reg_k[14],out_f1};
         16:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[3 ],reg_k[15],out_f1};

         17:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[12],reg_k[4 ],32'b0};
         18:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[13],reg_k[5 ],out_f1};
         19:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[14],reg_k[6 ],out_f1};
         20:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[15],reg_k[7 ],out_f1};

         21:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[16],reg_k[4 ],32'b0};
         22:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[17],reg_k[5 ],out_f1};
         23:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[18],reg_k[6 ],out_f1};
         24:{reg_mul_a_1,reg_mul_b_1,f1}={reg_in_str[19],reg_k[7 ],out_f1};
         
         25:{reg_mul_a_1,reg_mul_b_1,f1}={k[4 ],q[0 ],32'b0};
         26:{reg_mul_a_1,reg_mul_b_1,f1}={k[5 ],q[1 ],out_f1};
         27:{reg_mul_a_1,reg_mul_b_1,f1}={k[4 ],q[0 ],32'b0};
         28:{reg_mul_a_1,reg_mul_b_1,f1}={k[5 ],q[1 ],out_f1};
         29:{reg_mul_a_1,reg_mul_b_1,f1}={k[4 ],q[0 ],32'b0};
         30:{reg_mul_a_1,reg_mul_b_1,f1}={k[5 ],q[1 ],out_f1};
         31:{reg_mul_a_1,reg_mul_b_1,f1}={k[4 ],q[0 ],32'b0};
         32:{reg_mul_a_1,reg_mul_b_1,f1}={k[5 ],q[1 ],out_f1};
         33:{reg_mul_a_1,reg_mul_b_1,f1}={k[4 ],q[0 ],32'b0};
         34:{reg_mul_a_1,reg_mul_b_1,f1}={k[5 ],q[1 ],out_f1};
         
         35:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[1 ],32'b0 };
         36:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[5 ],out_f1};
         37:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[9 ],out_f1};
         38:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[13],out_f1};
         39:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[17],out_f1};
         40:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[1 ],32'b0 };
         41:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[5 ],out_f1};
         42:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[9 ],out_f1};
         43:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[13],out_f1};
         44:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[17],out_f1};
         45:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[1 ],32'b0 };
         46:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[5 ],out_f1};
         47:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[9 ],out_f1};
         48:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[13],out_f1};
         49:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[17],out_f1};
         50:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[1 ],32'b0};
         51:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[5 ],out_f1};
         52:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[9 ],out_f1};
         53:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[13],out_f1};
         54:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[17],out_f1};
         55:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[1 ],32'b0 };
         56:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[5 ],out_f1};
         57:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[9 ],out_f1};
         58:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[13],out_f1};
         59:{reg_mul_a_1,reg_mul_b_1,f1}={softmax_1,v[17],out_f1};










    default:{reg_mul_a_1,reg_mul_b_1,f1}={32'b0,32'b0,32'b0};
    endcase
end


// ---------k3----------// 
always@(*)begin
    case(counter)
          5:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[4 ],reg_k[0 ], 32'b0};
          6:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[5 ],reg_k[1 ],out_f2};
          7:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[6 ],reg_k[2 ],out_f2};
          8:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[7 ],reg_k[3 ],out_f2};

          9:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[8 ],reg_k[8 ],32'b0};
         10:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[9 ],reg_k[9 ],out_f2};
         11:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[10],reg_k[10],out_f2};
         12:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[11],reg_k[11],out_f2};

         13:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[4 ],reg_k[12],32'b0};
         14:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[5 ],reg_k[13],out_f2};
         15:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[6 ],reg_k[14],out_f2};
         16:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[7 ],reg_k[15],out_f2};

         17:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[12],reg_k[8 ],32'b0};
         18:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[13],reg_k[9 ],out_f2};
         19:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[14],reg_k[10],out_f2};
         20:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[15],reg_k[11],out_f2};

         21:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[16],reg_k[8 ],32'b0};
         22:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[17],reg_k[9 ],out_f2};
         23:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[18],reg_k[10],out_f2};
         24:{reg_mul_a_2,reg_mul_b_2,f2}={reg_in_str[19],reg_k[11],out_f2}; 

         25:{reg_mul_a_2,reg_mul_b_2,f2}={k[8],q[0 ],32'b0};
         26:{reg_mul_a_2,reg_mul_b_2,f2}={k[9],q[1 ],out_f2};
         27:{reg_mul_a_2,reg_mul_b_2,f2}={k[8],q[0 ],32'b0};
         28:{reg_mul_a_2,reg_mul_b_2,f2}={k[9],q[1 ],out_f2};
         29:{reg_mul_a_2,reg_mul_b_2,f2}={k[8],q[0 ],32'b0};
         30:{reg_mul_a_2,reg_mul_b_2,f2}={k[9],q[1 ],out_f2};
         31:{reg_mul_a_2,reg_mul_b_2,f2}={k[8],q[0 ],32'b0};
         32:{reg_mul_a_2,reg_mul_b_2,f2}={k[9],q[1 ],out_f2};
         33:{reg_mul_a_2,reg_mul_b_2,f2}={k[8],q[0 ],32'b0};
         34:{reg_mul_a_2,reg_mul_b_2,f2}={k[9],q[1 ],out_f2};

         35:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[2 ],32'b0 };
         36:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[6 ],out_f2};
         37:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[10],out_f2};
         38:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[14],out_f2};
         39:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[18],out_f2};
         40:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[2 ],32'b0 };
         41:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[6 ],out_f2};
         42:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[10],out_f2};
         43:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[14],out_f2};
         44:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[18],out_f2};
         45:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[2 ],32'b0 };
         46:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[6 ],out_f2};
         47:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[10],out_f2};
         48:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[14],out_f2};
         49:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[18],out_f2};
         50:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[2 ],32'b0};
         51:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[6 ],out_f2};
         52:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[10],out_f2};
         53:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[14],out_f2};
         54:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[18],out_f2};
         55:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[2 ],32'b0 };
         56:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[6 ],out_f2};
         57:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[10],out_f2};
         58:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[14],out_f2};
         59:{reg_mul_a_2,reg_mul_b_2,f2}={softmax_2,v[18],out_f2};










    default:{reg_mul_a_2,reg_mul_b_2,f2}={32'b0,32'b0,32'b0};
    endcase
end

// ---------k4----------//
always@(*)begin
    case(counter)
          5:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[4 ],reg_k[4 ], 32'b0};
          6:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[5 ],reg_k[5 ],out_f3};
          7:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[6 ],reg_k[6 ],out_f3};
          8:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[7 ],reg_k[7 ],out_f3};

          9:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[4 ],reg_k[8 ],32'b0};
         10:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[5 ],reg_k[9 ],out_f3};
         11:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[6 ],reg_k[10],out_f3};
         12:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[7 ],reg_k[11],out_f3};

         13:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[8 ],reg_k[12],32'b0};
         14:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[9 ],reg_k[13],out_f3};
         15:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[10],reg_k[14],out_f3};
         16:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[11],reg_k[15],out_f3};

         17:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[12],reg_k[12],32'b0};
         18:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[13],reg_k[13],out_f3};
         19:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[14],reg_k[14],out_f3};
         20:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[15],reg_k[15],out_f3};

         21:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[16],reg_k[12],32'b0};
         22:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[17],reg_k[13],out_f3};
         23:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[18],reg_k[14],out_f3};
         24:{reg_mul_a_3,reg_mul_b_3,f3}={reg_in_str[19],reg_k[15],out_f3};

         25:{reg_mul_a_3,reg_mul_b_3,f3}={k[12],q[0 ],32'b0};
         26:{reg_mul_a_3,reg_mul_b_3,f3}={k[13],q[1 ],out_f3};
         27:{reg_mul_a_3,reg_mul_b_3,f3}={k[12],q[0 ],32'b0};
         28:{reg_mul_a_3,reg_mul_b_3,f3}={k[13],q[1 ],out_f3};
         29:{reg_mul_a_3,reg_mul_b_3,f3}={k[12],q[0 ],32'b0};
         30:{reg_mul_a_3,reg_mul_b_3,f3}={k[13],q[1 ],out_f3};
         31:{reg_mul_a_3,reg_mul_b_3,f3}={k[12],q[0 ],32'b0};
         32:{reg_mul_a_3,reg_mul_b_3,f3}={k[13],q[1 ],out_f3};
         33:{reg_mul_a_3,reg_mul_b_3,f3}={k[12],q[0 ],32'b0};
         34:{reg_mul_a_3,reg_mul_b_3,f3}={k[13],q[1 ],out_f3};

         35:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[3 ],32'b0 };//head_out_2
         36:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[7 ],out_f3};
         37:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[11 ],out_f3};
         38:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[15],out_f3};
         39:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[19],out_f3};
         40:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[3 ],32'b0 };
         41:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[7 ],out_f3};
         42:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[11],out_f3};
         43:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[15],out_f3};
         44:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[19],out_f3};
         45:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[3 ],32'b0 };
         46:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[7 ],out_f3};
         47:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[11],out_f3};
         48:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[15],out_f3};
         49:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[19],out_f3};
         50:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[3 ],32'b0};
         51:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[7 ],out_f3};
         52:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[11],out_f3};
         53:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[15],out_f3};
         54:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[19],out_f3};
         55:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[3 ],32'b0 };
         56:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[7 ],out_f3};
         57:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[11],out_f3};
         58:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[15],out_f3};
         59:{reg_mul_a_3,reg_mul_b_3,f3}={softmax_2,v[19],out_f3};              
         
    default:{reg_mul_a_3,reg_mul_b_3,f3}={32'b0,32'b0,32'b0};
    endcase
end

always @(posedge clk or negedge rst_n)begin //k[i]
	if(!rst_n)begin
		for(i=0;i<20;i=i+1)begin
			k[i] <= 32'd0;
		end
    end

    else begin
        case(counter)
        4:k[0]<=wire_f0;
        8:begin
            k[1]<=wire_f1;
            k[4]<=wire_f2;
            k[5]<=wire_f3;
        end
        12:begin
            k[6]<=wire_f3;
            k[8]<=wire_f0;
            k[9]<=wire_f1;
            k[10]<=wire_f2;

        end
        16:begin
            k[2]<=wire_f0;
            k[3]<=wire_f1;
            k[7]<=wire_f2;
            k[11]<=wire_f3;
        end


        20:begin
            k[12]<=wire_f0;
            k[13]<=wire_f1;
            k[14]<=wire_f2;
            k[15]<=wire_f3;

        end
        24:begin
            k[16]<=wire_f0;
            k[17]<=wire_f1;
            k[18]<=wire_f2;
            k[19]<=wire_f3;

        end    
        /*26:begin
          for(int i=0;i<20;i=i+1)begin
            k[0]<=k[4];
            k[1]<=k[5];
            k[2]<=k[6];
            k[3]<=k[7];
            k[4]<=k[8];
            k[5]<=k[9];

          
          end
        end*/

        //default:
        endcase
    end
end
// ---------q1----------// 
always@(*)begin
    case(counter)
          1:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[0 ],reg_q[0 ],32'b0};
          2:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[1 ],reg_q[1 ],q_out_f0};
          3:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[2 ],reg_q[2 ],q_out_f0};
          4:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[3 ],reg_q[3 ],q_out_f0};

          9:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[8 ],reg_q[0 ],32'b0};
         10:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[9 ],reg_q[1 ],q_out_f0};
         11:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[10],reg_q[2 ],q_out_f0};
         12:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[11],reg_q[3 ],q_out_f0};

         13:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[0 ],reg_q[8 ],32'b0};
         14:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[1 ],reg_q[9 ],q_out_f0};
         15:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[2 ],reg_q[10],q_out_f0};
         16:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[3 ],reg_q[11],q_out_f0};

         17:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[12],reg_q[0 ],32'b0};
         18:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[13],reg_q[1 ],q_out_f0};
         19:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[14],reg_q[2 ],q_out_f0};
         20:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[15],reg_q[3 ],q_out_f0};

         21:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[16],reg_q[0 ],32'b0};
         22:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[17],reg_q[1 ],q_out_f0};
         23:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[18],reg_q[2 ],q_out_f0};
         24:{reg_mul_a_4,reg_mul_b_4,q_f0}={reg_in_str[19],reg_q[3 ],q_out_f0};

         25:{reg_mul_a_4,reg_mul_b_4,q_f0}={k[16],q[0 ],32'b0}; //score1
         26:{reg_mul_a_4,reg_mul_b_4,q_f0}={k[17],q[1 ],q_out_f0}; //score1
         27:{reg_mul_a_4,reg_mul_b_4,q_f0}={k[16],q[0 ],32'b0}; 
         28:{reg_mul_a_4,reg_mul_b_4,q_f0}={k[17],q[1 ],q_out_f0};
         29:{reg_mul_a_4,reg_mul_b_4,q_f0}={k[16],q[0 ],32'b0}; 
         30:{reg_mul_a_4,reg_mul_b_4,q_f0}={k[17],q[1 ],q_out_f0};
         31:{reg_mul_a_4,reg_mul_b_4,q_f0}={k[16],q[0 ],32'b0}; 
         32:{reg_mul_a_4,reg_mul_b_4,q_f0}={k[17],q[1 ],q_out_f0};
         33:{reg_mul_a_4,reg_mul_b_4,q_f0}={k[16],q[0 ],32'b0}; 
         34:{reg_mul_a_4,reg_mul_b_4,q_f0}={k[17],q[1 ],q_out_f0};        

         //head_out*out_weight 
         40:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_1,reg_out_weight[0 ],32'b0   }; 
         41:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_2,reg_out_weight[1 ],q_out_f0}; 
         42:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_3,reg_out_weight[2 ],q_out_f0}; 
         43:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_4,reg_out_weight[3 ],q_out_f0}; 

         45:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_1,reg_out_weight[0 ],32'b0   };
         46:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_2,reg_out_weight[1 ],q_out_f0};
         47:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_3,reg_out_weight[2 ],q_out_f0};
         48:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_4,reg_out_weight[3 ],q_out_f0};
         
         50:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_1,reg_out_weight[0 ],32'b0   };
         51:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_2,reg_out_weight[1 ],q_out_f0};
         52:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_3,reg_out_weight[2 ],q_out_f0};
         53:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_4,reg_out_weight[3 ],q_out_f0};
         
         55:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_1,reg_out_weight[0 ],32'b0   };
         56:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_2,reg_out_weight[1 ],q_out_f0};
         57:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_3,reg_out_weight[2 ],q_out_f0};
         58:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_4,reg_out_weight[3 ],q_out_f0};
         
         60:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_1,reg_out_weight[0 ],32'b0   };
         61:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_2,reg_out_weight[1 ],q_out_f0};
         62:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_3,reg_out_weight[2 ],q_out_f0};
         63:{reg_mul_a_4,reg_mul_b_4,q_f0}={head_out_4,reg_out_weight[3 ],q_out_f0};
    default:{reg_mul_a_4,reg_mul_b_4,q_f0}={32'b0,32'b0,32'b0};
    endcase
end
// ---------q2----------// 
always@(*)begin
    case(counter)
          5:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[0 ],reg_q[4 ],32'b0};
          6:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[1 ],reg_q[5 ],q_out_f1};
          7:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[2 ],reg_q[6 ],q_out_f1};
          8:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[3 ],reg_q[7 ],q_out_f1};

          9:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[8 ],reg_q[4 ],32'b0};
         10:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[9 ],reg_q[5 ],q_out_f1};
         11:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[10],reg_q[6 ],q_out_f1};
         12:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[11],reg_q[7 ],q_out_f1};

         13:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[0 ],reg_q[12],32'b0};
         14:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[1 ],reg_q[13],q_out_f1};
         15:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[2 ],reg_q[14],q_out_f1};
         16:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[3 ],reg_q[15],q_out_f1};

         17:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[12],reg_q[4 ],32'b0};
         18:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[13],reg_q[5 ],q_out_f1};
         19:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[14],reg_q[6 ],q_out_f1};
         20:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[15],reg_q[7 ],q_out_f1};

         21:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[16],reg_q[4 ],32'b0};
         22:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[17],reg_q[5 ],q_out_f1};
         23:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[18],reg_q[6 ],q_out_f1};
         24:{reg_mul_a_5,reg_mul_b_5,q_f1}={reg_in_str[19],reg_q[7 ],q_out_f1};

         25:{reg_mul_a_5,reg_mul_b_5,q_f1}={k[2 ],q[2 ],32'b0};
         26:{reg_mul_a_5,reg_mul_b_5,q_f1}={k[3 ],q[3 ],q_out_f1};
         27:{reg_mul_a_5,reg_mul_b_5,q_f1}={k[2 ],q[2 ],32'b0};
         28:{reg_mul_a_5,reg_mul_b_5,q_f1}={k[3 ],q[3 ],q_out_f1};
         29:{reg_mul_a_5,reg_mul_b_5,q_f1}={k[2 ],q[2 ],32'b0};
         30:{reg_mul_a_5,reg_mul_b_5,q_f1}={k[3 ],q[3 ],q_out_f1};
         31:{reg_mul_a_5,reg_mul_b_5,q_f1}={k[2 ],q[2 ],32'b0};
         32:{reg_mul_a_5,reg_mul_b_5,q_f1}={k[3 ],q[3 ],q_out_f1};
         33:{reg_mul_a_5,reg_mul_b_5,q_f1}={k[2 ],q[2 ],32'b0};
         34:{reg_mul_a_5,reg_mul_b_5,q_f1}={k[3 ],q[3 ],q_out_f1};

         40:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_1,reg_out_weight[4 ],32'b0};
         41:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_2,reg_out_weight[5 ],q_out_f1};
         42:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_3,reg_out_weight[6 ],q_out_f1};
         43:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_4,reg_out_weight[7 ],q_out_f1};

         45:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_1,reg_out_weight[4 ],32'b0};
         46:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_2,reg_out_weight[5 ],q_out_f1};
         47:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_3,reg_out_weight[6 ],q_out_f1};
         48:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_4,reg_out_weight[7 ],q_out_f1};

         50:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_1,reg_out_weight[4 ],32'b0};
         51:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_2,reg_out_weight[5 ],q_out_f1};
         52:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_3,reg_out_weight[6 ],q_out_f1};
         53:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_4,reg_out_weight[7 ],q_out_f1};

         55:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_1,reg_out_weight[4 ],32'b0};
         56:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_2,reg_out_weight[5 ],q_out_f1};
         57:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_3,reg_out_weight[6 ],q_out_f1};
         58:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_4,reg_out_weight[7 ],q_out_f1};
         
         60:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_1,reg_out_weight[4 ],32'b0};
         61:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_2,reg_out_weight[5 ],q_out_f1};
         62:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_3,reg_out_weight[6 ],q_out_f1};
         63:{reg_mul_a_5,reg_mul_b_5,q_f1}={head_out_4,reg_out_weight[7 ],q_out_f1};





    default:{reg_mul_a_5,reg_mul_b_5,q_f1}={32'b0,32'b0,32'b0};
    endcase
end


// ---------q3----------// 
always@(*)begin
    case(counter)
          5:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[4 ],reg_q[0 ], 32'b0};
          6:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[5 ],reg_q[1 ],q_out_f2};
          7:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[6 ],reg_q[2 ],q_out_f2};
          8:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[7 ],reg_q[3 ],q_out_f2};

          9:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[8 ],reg_q[8 ],32'b0};
         10:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[9 ],reg_q[9 ],q_out_f2};
         11:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[10],reg_q[10],q_out_f2};
         12:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[11],reg_q[11],q_out_f2};

         13:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[4 ],reg_q[12],32'b0};
         14:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[5 ],reg_q[13],q_out_f2};
         15:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[6 ],reg_q[14],q_out_f2};
         16:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[7 ],reg_q[15],q_out_f2};

         17:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[12],reg_q[8 ],32'b0};
         18:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[13],reg_q[9 ],q_out_f2};
         19:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[14],reg_q[10],q_out_f2};
         20:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[15],reg_q[11],q_out_f2};

         21:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[16],reg_q[8 ],32'b0};
         22:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[17],reg_q[9 ],q_out_f2};
         23:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[18],reg_q[10],q_out_f2};
         24:{reg_mul_a_6,reg_mul_b_6,q_f2}={reg_in_str[19],reg_q[11],q_out_f2};  

         25:{reg_mul_a_6,reg_mul_b_6,q_f2}={k[6],q[2 ],32'b0};
         26:{reg_mul_a_6,reg_mul_b_6,q_f2}={k[7],q[3 ],q_out_f2};
         27:{reg_mul_a_6,reg_mul_b_6,q_f2}={k[6],q[2 ],32'b0};
         28:{reg_mul_a_6,reg_mul_b_6,q_f2}={k[7],q[3 ],q_out_f2};
         29:{reg_mul_a_6,reg_mul_b_6,q_f2}={k[6],q[2 ],32'b0};
         30:{reg_mul_a_6,reg_mul_b_6,q_f2}={k[7],q[3 ],q_out_f2};
         31:{reg_mul_a_6,reg_mul_b_6,q_f2}={k[6],q[2 ],32'b0};
         32:{reg_mul_a_6,reg_mul_b_6,q_f2}={k[7],q[3 ],q_out_f2};
         33:{reg_mul_a_6,reg_mul_b_6,q_f2}={k[6],q[2 ],32'b0};
         34:{reg_mul_a_6,reg_mul_b_6,q_f2}={k[7],q[3 ],q_out_f2};

         40:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_1,reg_out_weight[8 ],32'b0};
         41:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_2,reg_out_weight[9 ],q_out_f2};
         42:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_3,reg_out_weight[10],q_out_f2};
         43:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_4,reg_out_weight[11],q_out_f2};
            
         45:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_1,reg_out_weight[8 ],32'b0};
         46:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_2,reg_out_weight[9 ],q_out_f2};
         47:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_3,reg_out_weight[10],q_out_f2};
         48:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_4,reg_out_weight[11],q_out_f2};
           
         50:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_1,reg_out_weight[8 ],32'b0};
         51:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_2,reg_out_weight[9 ],q_out_f2};
         52:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_3,reg_out_weight[10],q_out_f2};
         53:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_4,reg_out_weight[11],q_out_f2};
            
         55:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_1,reg_out_weight[8 ],32'b0};
         56:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_2,reg_out_weight[9 ],q_out_f2};
         57:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_3,reg_out_weight[10],q_out_f2};
         58:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_4,reg_out_weight[11],q_out_f2};
            
         60:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_1,reg_out_weight[8 ],32'b0};
         61:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_2,reg_out_weight[9 ],q_out_f2};
         62:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_3,reg_out_weight[10],q_out_f2};
         63:{reg_mul_a_6,reg_mul_b_6,q_f2}={head_out_4,reg_out_weight[11],q_out_f2};






    default:{reg_mul_a_6,reg_mul_b_6,q_f2}={32'b0,32'b0,32'b0};
    endcase
end

// ---------q4----------//
always@(*)begin
    case(counter)
          5:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[4 ],reg_q[4 ], 32'b0};
          6:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[5 ],reg_q[5 ],q_out_f3};
          7:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[6 ],reg_q[6 ],q_out_f3};
          8:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[7 ],reg_q[7 ],q_out_f3};

          9:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[4 ],reg_q[8 ],32'b0};
         10:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[5 ],reg_q[9 ],q_out_f3};
         11:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[6 ],reg_q[10],q_out_f3};
         12:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[7 ],reg_q[11],q_out_f3};

         13:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[8 ],reg_q[12],32'b0};
         14:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[9 ],reg_q[13],q_out_f3};
         15:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[10],reg_q[14],q_out_f3};
         16:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[11],reg_q[15],q_out_f3};

         17:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[12],reg_q[12],32'b0};
         18:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[13],reg_q[13],q_out_f3};
         19:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[14],reg_q[14],q_out_f3};
         20:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[15],reg_q[15],q_out_f3};

         21:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[16],reg_q[12],32'b0};
         22:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[17],reg_q[13],q_out_f3};
         23:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[18],reg_q[14],q_out_f3};
         24:{reg_mul_a_7,reg_mul_b_7,q_f3}={reg_in_str[19],reg_q[15],q_out_f3};

         25:{reg_mul_a_7,reg_mul_b_7,q_f3}={k[10],q[2 ],32'b0};
         26:{reg_mul_a_7,reg_mul_b_7,q_f3}={k[11],q[3 ],q_out_f3};
         27:{reg_mul_a_7,reg_mul_b_7,q_f3}={k[10],q[2 ],32'b0};
         28:{reg_mul_a_7,reg_mul_b_7,q_f3}={k[11],q[3 ],q_out_f3};
         29:{reg_mul_a_7,reg_mul_b_7,q_f3}={k[10],q[2 ],32'b0};
         30:{reg_mul_a_7,reg_mul_b_7,q_f3}={k[11],q[3 ],q_out_f3};
         31:{reg_mul_a_7,reg_mul_b_7,q_f3}={k[10],q[2 ],32'b0};
         32:{reg_mul_a_7,reg_mul_b_7,q_f3}={k[11],q[3 ],q_out_f3};
         33:{reg_mul_a_7,reg_mul_b_7,q_f3}={k[10],q[2 ],32'b0};
         34:{reg_mul_a_7,reg_mul_b_7,q_f3}={k[11],q[3 ],q_out_f3};

         40:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_1,reg_out_weight[12],32'b0};
         41:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_2,reg_out_weight[13],q_out_f3};
         42:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_3,reg_out_weight[14],q_out_f3};
         43:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_4,reg_out_weight[15],q_out_f3};

         45:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_1,reg_out_weight[12],32'b0};
         46:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_2,reg_out_weight[13],q_out_f3};
         47:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_3,reg_out_weight[14],q_out_f3};
         48:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_4,reg_out_weight[15],q_out_f3};

         50:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_1,reg_out_weight[12],32'b0};
         51:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_2,reg_out_weight[13],q_out_f3};
         52:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_3,reg_out_weight[14],q_out_f3};
         53:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_4,reg_out_weight[15],q_out_f3};

         55:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_1,reg_out_weight[12],32'b0};
         56:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_2,reg_out_weight[13],q_out_f3};
         57:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_3,reg_out_weight[14],q_out_f3};
         58:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_4,reg_out_weight[15],q_out_f3};
         
         60:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_1,reg_out_weight[12],32'b0};
         61:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_2,reg_out_weight[13],q_out_f3};
         62:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_3,reg_out_weight[14],q_out_f3};
         63:{reg_mul_a_7,reg_mul_b_7,q_f3}={head_out_4,reg_out_weight[15],q_out_f3};

    default:{reg_mul_a_7,reg_mul_b_7,q_f3}={32'b0,32'b0,32'b0};
    endcase
end

always @(posedge clk or negedge rst_n)begin //q[i]
	if(!rst_n)begin
		for(i=0;i<20;i=i+1)begin
			q[i] <= 32'd0;
		end
    end
    else if(shift_enable)begin
        for (i = 0; i < 16; i = i + 1) begin
            q[i] <= q[i + 4];
        end
    end

    else begin
        case(counter)
        4:q[0]<=q_wire_f0;
        8:begin
            q[1]<=q_wire_f1;
            q[4]<=q_wire_f2;
            q[5]<=q_wire_f3;
        end
        12:begin
            q[6] <=q_wire_f3;
            q[8] <=q_wire_f0;
            q[9] <=q_wire_f1;
            q[10]<=q_wire_f2;

        end
        16:begin
            q[2]<=q_wire_f0;
            q[3]<=q_wire_f1;
            q[7]<=q_wire_f2;
            q[11]<=q_wire_f3;
        end


        20:begin
            q[12]<=q_wire_f0;
            q[13]<=q_wire_f1;
            q[14]<=q_wire_f2;
            q[15]<=q_wire_f3;

        end
        24:begin
            q[16]<=q_wire_f0;
            q[17]<=q_wire_f1;
            q[18]<=q_wire_f2;
            q[19]<=q_wire_f3;

        end

        //default:
        endcase
    end
end
// ---------v1----------// 
always@(*)begin
    case(counter)
          1:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[0 ],reg_v[0 ],32'b0};
          2:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[1 ],reg_v[1 ],v_out_f0};
          3:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[2 ],reg_v[2 ],v_out_f0};
          4:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[3 ],reg_v[3 ],v_out_f0};

          9:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[8 ],reg_v[0 ],32'b0};
         10:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[9 ],reg_v[1 ],v_out_f0};
         11:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[10],reg_v[2 ],v_out_f0};
         12:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[11],reg_v[3 ],v_out_f0};

         13:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[0 ],reg_v[8 ],32'b0};
         14:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[1 ],reg_v[9 ],v_out_f0};
         15:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[2 ],reg_v[10],v_out_f0};
         16:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[3 ],reg_v[11],v_out_f0};

         17:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[12],reg_v[0 ],32'b0};
         18:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[13],reg_v[1 ],v_out_f0};
         19:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[14],reg_v[2 ],v_out_f0};
         20:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[15],reg_v[3 ],v_out_f0};

         21:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[16],reg_v[0 ],32'b0};
         22:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[17],reg_v[1 ],v_out_f0};
         23:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[18],reg_v[2 ],v_out_f0};
         24:{reg_mul_a_8,reg_mul_b_8,v_f0}={reg_in_str[19],reg_v[3 ],v_out_f0};

         25:{reg_mul_a_8,reg_mul_b_8,v_f0}={k[14],q[2 ],32'b0};
         26:{reg_mul_a_8,reg_mul_b_8,v_f0}={k[15],q[3 ],v_out_f0};
         27:{reg_mul_a_8,reg_mul_b_8,v_f0}={k[14],q[2 ],32'b0};
         28:{reg_mul_a_8,reg_mul_b_8,v_f0}={k[15],q[3 ],v_out_f0};
         29:{reg_mul_a_8,reg_mul_b_8,v_f0}={k[14],q[2 ],32'b0};
         30:{reg_mul_a_8,reg_mul_b_8,v_f0}={k[15],q[3 ],v_out_f0};
         31:{reg_mul_a_8,reg_mul_b_8,v_f0}={k[14],q[2 ],32'b0};
         32:{reg_mul_a_8,reg_mul_b_8,v_f0}={k[15],q[3 ],v_out_f0};
         33:{reg_mul_a_8,reg_mul_b_8,v_f0}={k[14],q[2 ],32'b0};
         34:{reg_mul_a_8,reg_mul_b_8,v_f0}={k[15],q[3 ],v_out_f0};
    default:{reg_mul_a_8,reg_mul_b_8,v_f0}={32'b0,32'b0,32'b0};
    endcase
end
// ---------v2----------// 
always@(*)begin
    case(counter)
          5:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[0 ],reg_v[4 ],32'b0};
          6:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[1 ],reg_v[5 ],v_out_f1};
          7:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[2 ],reg_v[6 ],v_out_f1};
          8:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[3 ],reg_v[7 ],v_out_f1};

          9:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[8 ],reg_v[4 ],32'b0};
         10:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[9 ],reg_v[5 ],v_out_f1};
         11:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[10],reg_v[6 ],v_out_f1};
         12:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[11],reg_v[7 ],v_out_f1};

         13:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[0 ],reg_v[12],32'b0};
         14:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[1 ],reg_v[13],v_out_f1};
         15:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[2 ],reg_v[14],v_out_f1};
         16:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[3 ],reg_v[15],v_out_f1};

         17:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[12],reg_v[4 ],32'b0};
         18:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[13],reg_v[5 ],v_out_f1};
         19:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[14],reg_v[6 ],v_out_f1};
         20:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[15],reg_v[7 ],v_out_f1};

         21:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[16],reg_v[4 ],32'b0};
         22:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[17],reg_v[5 ],v_out_f1};
         23:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[18],reg_v[6 ],v_out_f1};
         24:{reg_mul_a_9,reg_mul_b_9,v_f1}={reg_in_str[19],reg_v[7 ],v_out_f1};

         25:{reg_mul_a_9,reg_mul_b_9,v_f1}={k[18],q[2 ],32'b0};
         26:{reg_mul_a_9,reg_mul_b_9,v_f1}={k[19],q[3 ],v_out_f1};
         27:{reg_mul_a_9,reg_mul_b_9,v_f1}={k[18],q[2 ],32'b0};
         28:{reg_mul_a_9,reg_mul_b_9,v_f1}={k[19],q[3 ],v_out_f1};
         29:{reg_mul_a_9,reg_mul_b_9,v_f1}={k[18],q[2 ],32'b0};
         30:{reg_mul_a_9,reg_mul_b_9,v_f1}={k[19],q[3 ],v_out_f1};
         31:{reg_mul_a_9,reg_mul_b_9,v_f1}={k[18],q[2 ],32'b0};
         32:{reg_mul_a_9,reg_mul_b_9,v_f1}={k[19],q[3 ],v_out_f1};
         33:{reg_mul_a_9,reg_mul_b_9,v_f1}={k[18],q[2 ],32'b0};
         34:{reg_mul_a_9,reg_mul_b_9,v_f1}={k[19],q[3 ],v_out_f1};
    default:{reg_mul_a_9,reg_mul_b_9,v_f1}={32'b0,32'b0,32'b0};
    endcase
end


// ---------v3----------// 
always@(*)begin
    case(counter)
          5:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[4 ],reg_v[0 ], 32'b0};
          6:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[5 ],reg_v[1 ],v_out_f2};
          7:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[6 ],reg_v[2 ],v_out_f2};
          8:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[7 ],reg_v[3 ],v_out_f2};

          9:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[8 ],reg_v[8 ],32'b0};
         10:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[9 ],reg_v[9 ],v_out_f2};
         11:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[10],reg_v[10],v_out_f2};
         12:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[11],reg_v[11],v_out_f2};

         13:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[4 ],reg_v[12],32'b0};
         14:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[5 ],reg_v[13],v_out_f2};
         15:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[6 ],reg_v[14],v_out_f2};
         16:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[7 ],reg_v[15],v_out_f2};

         17:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[12],reg_v[8 ],32'b0};
         18:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[13],reg_v[9 ],v_out_f2};
         19:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[14],reg_v[10],v_out_f2};
         20:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[15],reg_v[11],v_out_f2};

         21:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[16],reg_v[8 ],32'b0};
         22:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[17],reg_v[9 ],v_out_f2};
         23:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[18],reg_v[10],v_out_f2};
         24:{reg_mul_a_10,reg_mul_b_10,v_f2}={reg_in_str[19],reg_v[11],v_out_f2};  
    default:{reg_mul_a_10,reg_mul_b_10,v_f2}={32'b0,32'b0,32'b0};
    endcase
end

// ---------v4----------//
always@(*)begin
    case(counter)
          5:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[4 ],reg_v[4 ], 32'b0};
          6:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[5 ],reg_v[5 ],v_out_f3};
          7:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[6 ],reg_v[6 ],v_out_f3};
          8:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[7 ],reg_v[7 ],v_out_f3};

          9:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[4 ],reg_v[8 ],32'b0};
         10:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[5 ],reg_v[9 ],v_out_f3};
         11:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[6 ],reg_v[10],v_out_f3};
         12:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[7 ],reg_v[11],v_out_f3};

         13:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[8 ],reg_v[12],32'b0};
         14:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[9 ],reg_v[13],v_out_f3};
         15:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[10],reg_v[14],v_out_f3};
         16:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[11],reg_v[15],v_out_f3};

         17:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[12],reg_v[12],32'b0};
         18:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[13],reg_v[13],v_out_f3};
         19:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[14],reg_v[14],v_out_f3};
         20:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[15],reg_v[15],v_out_f3};

         21:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[16],reg_v[12],32'b0};
         22:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[17],reg_v[13],v_out_f3};
         23:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[18],reg_v[14],v_out_f3};
         24:{reg_mul_a_11,reg_mul_b_11,v_f3}={reg_in_str[19],reg_v[15],v_out_f3};
    default:{reg_mul_a_11,reg_mul_b_11,v_f3}={32'b0,32'b0,32'b0};
    endcase
end
/////////////divided////////////////

always@(*)begin
    case(counter)
    27:reg_div_a_0 = reg_in_str[0];
    28:reg_div_a_0 = reg_in_str[1];
    29:reg_div_a_0 = reg_in_str[2];
    30:reg_div_a_0 = reg_in_str[3];
    31:reg_div_a_0 = reg_in_str[4];
    32:reg_div_a_0 = reg_in_str[5];
    33:reg_div_a_0 = reg_in_str[6];
    34:reg_div_a_0 = reg_in_str[7];
    35:reg_div_a_0 = reg_in_str[8];
    36:reg_div_a_0 = reg_in_str[9];
    37:reg_div_a_0 = reg_in_str[10];
    38:reg_div_a_0 = reg_in_str[11];
    39:reg_div_a_0 = reg_in_str[12];
    40:reg_div_a_0 = reg_in_str[13];
    41:reg_div_a_0 = reg_in_str[14];
    42:reg_div_a_0 = reg_in_str[15];
    43:reg_div_a_0 = reg_in_str[16];
    44:reg_div_a_0 = reg_in_str[17];
    45:reg_div_a_0 = reg_in_str[18];
    46:reg_div_a_0 = reg_in_str[19];
    47:reg_div_a_0 = reg_k[0];
    48:reg_div_a_0 = reg_k[1];
    49:reg_div_a_0 = reg_k[2];
    50:reg_div_a_0 = reg_k[3];
    51:reg_div_a_0 = reg_k[4];
    default:reg_div_a_0=0;
    endcase
end

always@(*)begin
    case(counter)
    27:reg_div_a_1 = reg_k[7];
    28:reg_div_a_1 = reg_k[8];             
    29:reg_div_a_1 = reg_k[9];             
    30:reg_div_a_1 = reg_k[10];             
    31:reg_div_a_1 = reg_k[11];             
    32:reg_div_a_1 = reg_k[12];             
    33:reg_div_a_1 = reg_k[13];             
    34:reg_div_a_1 = reg_k[14];             
    35:reg_div_a_1 = reg_k[15];             
    36:reg_div_a_1 = reg_q[0];                                  
    37:reg_div_a_1 = reg_q[1];                                  
    38:reg_div_a_1 = reg_q[2];                                  
    39:reg_div_a_1 = reg_q[3];                                  
    40:reg_div_a_1 = reg_q[4];                                  
    41:reg_div_a_1 = reg_q[5];                                   
    42:reg_div_a_1 = reg_q[6];
    43:reg_div_a_1 = reg_q[7];
    44:reg_div_a_1 = reg_q[8];
    45:reg_div_a_1 = reg_q[9];
    46:reg_div_a_1 = reg_q[10];
    47:reg_div_a_1 = reg_q[11];
    48:reg_div_a_1 = reg_q[12];
    49:reg_div_a_1 = reg_q[13];
    50:reg_div_a_1 = reg_q[14];
    51:reg_div_a_1 = reg_q[15];
    default:reg_div_a_1=0;
    endcase
end

/*
    assign reg_div_a_0[0] = 32'h3dcccccd; //0.1
    assign reg_div_a_0[1] = 32'h3e4ccccd; //0.2
    assign reg_div_a_0[2] = 32'h3e99999a; //0.3
    assign reg_div_a_0[3] = 32'h3ecccccd; //0.4
    assign reg_div_a_0[4] = 32'h3f000000; //0.5

    assign reg_div_a_0[5] = 32'h3e99999a; //0.3
    assign reg_div_a_0[6] = 32'h3ecccccd; //0.4
    assign reg_div_a_0[7] = 32'h3f000000; //0.5
    assign reg_div_a_0[8] = 32'h3dcccccd; //0.1
    assign reg_div_a_0[9] = 32'h3e4ccccd; //0.2

    assign reg_div_a_0[10] = 32'h3e4ccccd; //0.2
    assign reg_div_a_0[11] = 32'h3dcccccd; //0.1
    assign reg_div_a_0[12] = 32'h3ecccccd; //0.4
    assign reg_div_a_0[13] = 32'h3e99999a; //0.3
    assign reg_div_a_0[14] = 32'h3f000000; //0.5

    assign reg_div_a_0[15] = 32'h3f000000; //0.5
    assign reg_div_a_0[16] = 32'h3e4ccccd; //0.2
    assign reg_div_a_0[17] = 32'h3e99999a; //0.3
    assign reg_div_a_0[18] = 32'h3dcccccd; //0.1
    assign reg_div_a_0[19] = 32'h3ecccccd; //0.4

    assign reg_div_a_0[20] = 32'h3e99999a; //0.3
    assign reg_div_a_0[21] = 32'h3f000000; //0.5
    assign reg_div_a_0[22] = 32'h3e4ccccd; //0.2
    assign reg_div_a_0[23] = 32'h3ecccccd; //0.4
    assign reg_div_a_0[24] = 32'h3dcccccd; //0.1

    assign reg_div_a_1[0] = 32'h3dcccccd; //0.1
    assign reg_div_a_1[1] = 32'h3e4ccccd; //0.2
    assign reg_div_a_1[2] = 32'h3e99999a; //0.3
    assign reg_div_a_1[3] = 32'h3ecccccd; //0.4
    assign reg_div_a_1[4] = 32'h3f000000; //0.5

    assign reg_div_a_1[5] = 32'h3e99999a; //0.3
    assign reg_div_a_1[6] = 32'h3ecccccd; //0.4
    assign reg_div_a_1[7] = 32'h3f000000; //0.5
    assign reg_div_a_1[8] = 32'h3dcccccd; //0.1
    assign reg_div_a_1[9] = 32'h3e4ccccd; //0.2

    assign reg_div_a_1[10] = 32'h3e4ccccd; //0.2
    assign reg_div_a_1[11] = 32'h3dcccccd; //0.1
    assign reg_div_a_1[12] = 32'h3ecccccd; //0.4
    assign reg_div_a_1[13] = 32'h3e99999a; //0.3
    assign reg_div_a_1[14] = 32'h3f000000; //0.5

    assign reg_div_a_1[15] = 32'h3f000000; //0.5
    assign reg_div_a_1[16] = 32'h3e4ccccd; //0.2
    assign reg_div_a_1[17] = 32'h3e99999a; //0.3
    assign reg_div_a_1[18] = 32'h3dcccccd; //0.1
    assign reg_div_a_1[19] = 32'h3ecccccd; //0.4

    assign reg_div_a_1[20] = 32'h3e99999a; //0.3
    assign reg_div_a_1[21] = 32'h3f000000; //0.5
    assign reg_div_a_1[22] = 32'h3e4ccccd; //0.2
    assign reg_div_a_1[23] = 32'h3ecccccd; //0.4
    assign reg_div_a_1[24] = 32'h3dcccccd; //0.1

*/
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		for(i=0;i<20;i=i+1)begin
			v[i] <= 32'd0;
		end
    end
    else begin
        case(counter)
        4:v[0]<=v_wire_f0;
        8:begin
            v[1]<=v_wire_f1;
            v[4]<=v_wire_f2;
            v[5]<=v_wire_f3;
        end
        12:begin
            v[6]<=v_wire_f3;
            v[8]<=v_wire_f0;
            v[9]<=v_wire_f1;
            v[10]<=v_wire_f2;

        end
        16:begin
            v[2]<=v_wire_f0;
            v[3]<=v_wire_f1;
            v[7]<=v_wire_f2;
            v[11]<=v_wire_f3;
        end


        20:begin
            v[12]<=v_wire_f0;
            v[13]<=v_wire_f1;
            v[14]<=v_wire_f2;
            v[15]<=v_wire_f3;

        end
        24:begin
            v[16]<=v_wire_f0;
            v[17]<=v_wire_f1;
            v[18]<=v_wire_f2;
            v[19]<=v_wire_f3;

        end

        //default:
        endcase
    end
end



always @(posedge clk or negedge rst_n)begin //score1
	if(!rst_n)begin
		for(int i=0;i<25;i=i+1)begin
			score_1[i] <= 32'd0;
		end
    end
    else begin
        case(counter)
        26:begin
            score_1[0] <=wire_f0;
            score_1[1] <=wire_f1;
            score_1[2] <=wire_f2;
            score_1[3] <=wire_f3;
            score_1[4] <=q_wire_f0;
        end
        28:begin
            score_1[5] <=wire_f0;
            score_1[6] <=wire_f1;
            score_1[7] <=wire_f2;
            score_1[8] <=wire_f3;
            score_1[9] <=q_wire_f0;
        end
        30:begin
            score_1[10] <=wire_f0;
            score_1[11] <=wire_f1;
            score_1[12]<=wire_f2;
            score_1[13]<=wire_f3;
            score_1[14]<=q_wire_f0;
        end
        32:begin
            score_1[15] <=wire_f0;
            score_1[16] <=wire_f1;
            score_1[17]<=wire_f2;
            score_1[18]<=wire_f3;
            score_1[19]<=q_wire_f0;
        end
        34:begin
            score_1[20] <=wire_f0;
            score_1[21] <=wire_f1;
            score_1[22] <=wire_f2;
            score_1[23] <=wire_f3;
            score_1[24] <=q_wire_f0;
        end

        endcase
    end
end

always @(posedge clk or negedge rst_n)begin //score2
	if(!rst_n)begin
		for(int i=0;i<25;i=i+1)begin
			score_2[i] <= 32'd0;
		end
    end
    else begin
        case(counter)
        26:begin
            score_2[0]<=q_wire_f1;
            score_2[1]<=q_wire_f2;
            score_2[2]<=q_wire_f3;
            score_2[3]<=v_wire_f0;
            score_2[4]<=v_wire_f1;
        end
        28:begin
            score_2[5]<=q_wire_f1;
            score_2[6]<=q_wire_f2;
            score_2[7]<=q_wire_f3;
            score_2[8]<=v_wire_f0;
            score_2[9]<=v_wire_f1;
        end
        30:begin
            score_2[10]<=q_wire_f1;
            score_2[11]<=q_wire_f2;
            score_2[12]<=q_wire_f3;
            score_2[13]<=v_wire_f0;
            score_2[14]<=v_wire_f1;
        end
        32:begin
            score_2[15]<=q_wire_f1;
            score_2[16]<=q_wire_f2;
            score_2[17]<=q_wire_f3;
            score_2[18]<=v_wire_f0;
            score_2[19]<=v_wire_f1;
        end
        34:begin
            score_2[20]<=q_wire_f1;
            score_2[21]<=q_wire_f2;
            score_2[22]<=q_wire_f3;
            score_2[23]<=v_wire_f0;
            score_2[24]<=v_wire_f1;
        end

        endcase
    end
end


always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
        reg_divide_1<=32'b0;
        reg_divide_2<=32'b0;
    end
    else begin
        if(counter>=27 && counter<=51)begin
            reg_divide_1<=div_wire_1;
            reg_divide_2<=div_wire_2;
        end
    end
end
always@(*)begin
    case(counter)
    28:     exp_1=reg_divide_1;
    29:     exp_1=reg_divide_1;
    30:     exp_1=reg_divide_1;
    31:     exp_1=reg_divide_1;
    32:     exp_1=reg_divide_1;
    33:     exp_1=reg_divide_1;
    34:     exp_1=reg_divide_1;
    35:     exp_1=reg_divide_1;
    36:     exp_1=reg_divide_1;
    37:     exp_1=reg_divide_1;
    38:     exp_1=reg_divide_1;
    39:     exp_1=reg_divide_1;
    40:     exp_1=reg_divide_1;
    41:     exp_1=reg_divide_1;
    42:     exp_1=reg_divide_1;
    43:     exp_1=reg_divide_1;
    44:     exp_1=reg_divide_1;
    45:     exp_1=reg_divide_1;
    46:     exp_1=reg_divide_1;
    47:     exp_1=reg_divide_1;
    48:     exp_1=reg_divide_1;
    49:     exp_1=reg_divide_1;
    50:     exp_1=reg_divide_1;
    51:     exp_1=reg_divide_1;
    52:     exp_1=reg_divide_1;
    


    default:exp_1=0;
    endcase
end
always@(*)begin
    case(counter)
    28:     exp_2=reg_divide_2;
    29:     exp_2=reg_divide_2;
    30:     exp_2=reg_divide_2;
    31:     exp_2=reg_divide_2;
    32:     exp_2=reg_divide_2;
    33:     exp_2=reg_divide_2;
    34:     exp_2=reg_divide_2;
    35:     exp_2=reg_divide_2;
    36:     exp_2=reg_divide_2;
    37:     exp_2=reg_divide_2;
    38:     exp_2=reg_divide_2;
    39:     exp_2=reg_divide_2;
    40:     exp_2=reg_divide_2;
    41:     exp_2=reg_divide_2;
    42:     exp_2=reg_divide_2;
    43:     exp_2=reg_divide_2;
    44:     exp_2=reg_divide_2;
    45:     exp_2=reg_divide_2;
    46:     exp_2=reg_divide_2;
    47:     exp_2=reg_divide_2;
    48:     exp_2=reg_divide_2;
    49:     exp_2=reg_divide_2;
    50:     exp_2=reg_divide_2;
    51:     exp_2=reg_divide_2;
    52:     exp_2=reg_divide_2;



    default:exp_2=0;
    endcase
end
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
        reg_exp_1<=32'b0;
        reg_exp_2<=32'b0;
    end
    else begin
        if(counter>=28 && counter<=52)begin
            reg_exp_1<=wire_exp_1;
            reg_exp_2<=wire_exp_2;
        end
    end
end

always@(*)begin
    case(counter)
    29:     {add_1,add_f1}={reg_exp_1,32'b0   };//a1+0
    30:     {add_1,add_f1}={reg_exp_1,reg_add_1};//a2+(a1+0)
    31:     {add_1,add_f1}={reg_exp_1,reg_add_1};//a3+(a2+a1+0)
    32:     {add_1,add_f1}={reg_exp_1,reg_add_1};//a4+(a3+a2+a1+0)
    33:     {add_1,add_f1}={reg_exp_1,reg_add_1};//a5+(a4+a3+a2+a1+0)

    34:     {add_1,add_f1}={reg_exp_1,32'b0   };                     
    35:     {add_1,add_f1}={reg_exp_1,reg_add_1};                     
    36:     {add_1,add_f1}={reg_exp_1,reg_add_1};                     
    37:     {add_1,add_f1}={reg_exp_1,reg_add_1};                     
    38:     {add_1,add_f1}={reg_exp_1,reg_add_1}; 

    39:     {add_1,add_f1}={reg_exp_1,32'b0   };                     
    40:     {add_1,add_f1}={reg_exp_1,reg_add_1};
    41:     {add_1,add_f1}={reg_exp_1,reg_add_1};
    42:     {add_1,add_f1}={reg_exp_1,reg_add_1};
    43:     {add_1,add_f1}={reg_exp_1,reg_add_1};

    44:     {add_1,add_f1}={reg_exp_1,32'b0   };
    45:     {add_1,add_f1}={reg_exp_1,reg_add_1};
    46:     {add_1,add_f1}={reg_exp_1,reg_add_1};
    47:     {add_1,add_f1}={reg_exp_1,reg_add_1};
    48:     {add_1,add_f1}={reg_exp_1,reg_add_1};

    49:     {add_1,add_f1}={reg_exp_1,32'b0   };
    50:     {add_1,add_f1}={reg_exp_1,reg_add_1};
    51:     {add_1,add_f1}={reg_exp_1,reg_add_1};
    52:     {add_1,add_f1}={reg_exp_1,reg_add_1};
    53:     {add_1,add_f1}={reg_exp_1,reg_add_1};
    default:{add_1,add_f1}={32'b0,32'b0};
    endcase
end
always@(*)begin
    case(counter)
    29:     {add_2,add_f2}={reg_exp_2,32'b0   };//a1+0
    30:     {add_2,add_f2}={reg_exp_2,reg_add_2};//a2+(a1+0)
    31:     {add_2,add_f2}={reg_exp_2,reg_add_2};//a3+(a2+a1+0)
    32:     {add_2,add_f2}={reg_exp_2,reg_add_2};//a4+(a3+a2+a1+0)
    33:     {add_2,add_f2}={reg_exp_2,reg_add_2};//a5+(a4+a3+a2+a1+0)

    34:     {add_2,add_f2}={reg_exp_2,32'b0   };                     
    35:     {add_2,add_f2}={reg_exp_2,reg_add_2};                     
    36:     {add_2,add_f2}={reg_exp_2,reg_add_2};                     
    37:     {add_2,add_f2}={reg_exp_2,reg_add_2};                     
    38:     {add_2,add_f2}={reg_exp_2,reg_add_2}; 

    39:     {add_2,add_f2}={reg_exp_2,32'b0   };                     
    40:     {add_2,add_f2}={reg_exp_2,reg_add_2};
    41:     {add_2,add_f2}={reg_exp_2,reg_add_2};
    42:     {add_2,add_f2}={reg_exp_2,reg_add_2};
    43:     {add_2,add_f2}={reg_exp_2,reg_add_2};

    44:     {add_2,add_f2}={reg_exp_2,32'b0   };
    45:     {add_2,add_f2}={reg_exp_2,reg_add_2};
    46:     {add_2,add_f2}={reg_exp_2,reg_add_2};
    47:     {add_2,add_f2}={reg_exp_2,reg_add_2};
    48:     {add_2,add_f2}={reg_exp_2,reg_add_2};

    49:     {add_2,add_f2}={reg_exp_2,32'b0   };
    50:     {add_2,add_f2}={reg_exp_2,reg_add_2};
    51:     {add_2,add_f2}={reg_exp_2,reg_add_2};
    52:     {add_2,add_f2}={reg_exp_2,reg_add_2};
    53:     {add_2,add_f2}={reg_exp_2,reg_add_2};
    default:{add_2,add_f2}={32'b0,32'b0};
    endcase
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
        reg_add_1<=32'b0;
        reg_add_2<=32'b0;
    end
    else begin
        if(counter>=29 && counter<=53)begin
            reg_add_1<=wire_add_1;
            reg_add_2<=wire_add_2;
        end
    end
end


always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
        reg_sum_1<=32'b0;
        reg_sum_2<=32'b0;
    end
    else begin
        if(counter==34 || counter==39 ||counter==44 ||counter==49 ||counter==54)begin
            reg_sum_1<=reg_add_1;
            reg_sum_2<=reg_add_2;
        end
    end
end

//********* [31:0]exp_shift[0:4];
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
        for(int i=0;i<6;i=i+1)begin
            exp_shift[i]<=32'b0;
        end
    end
    else begin
        if(counter>=28 && counter<=58)begin
            exp_shift[5]<=wire_exp_1;
            exp_shift[4]<=exp_shift[5];
            exp_shift[3]<=exp_shift[4];  
            exp_shift[2]<=exp_shift[3];
            exp_shift[1]<=exp_shift[2];
            exp_shift[0]<=exp_shift[1];
        end
    end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
        for(int i=0;i<6;i=i+1)begin
            exp_shift_2[i]<=32'b0;
        end
    end
    else begin
        if(counter>=28 && counter<=58)begin
            exp_shift_2[5]<=wire_exp_2;
            exp_shift_2[4]<=exp_shift_2[5];
            exp_shift_2[3]<=exp_shift_2[4];  
            exp_shift_2[2]<=exp_shift_2[3];
            exp_shift_2[1]<=exp_shift_2[2];
            exp_shift_2[0]<=exp_shift_2[1];
        end
    end
end


always@(*)begin
    case(counter)
    34:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_add_1};
    35:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};
    36:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};
    37:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};
    38:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};

    39:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_add_1};
    40:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};
    41:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};
    42:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};
    43:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};

    44:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_add_1};
    45:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};
    46:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};
    47:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};
    48:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};


    49:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_add_1};
    50:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};
    51:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};
    52:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};
    53:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};


    54:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_add_1};
    55:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};
    56:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};
    57:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};
    58:{reg_div_numerator_1,reg_div_denominator_1}={exp_shift[0],reg_sum_1};

    default:{reg_div_numerator_1,reg_div_denominator_1}={32'b0,32'b0};
    endcase
end
always@(*)begin
    case(counter)
    34:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_add_2};
    35:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};
    36:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};
    37:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};
    38:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};

    39:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_add_2};
    40:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};
    41:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};
    42:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};
    43:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};

    44:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_add_2};
    45:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};
    46:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};
    47:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};
    48:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};

    49:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_add_2};
    50:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};
    51:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};
    52:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};
    53:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};

    54:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_add_2};
    55:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};
    56:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};
    57:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};
    58:{reg_div_numerator_2,reg_div_denominator_2}={exp_shift_2[0],reg_sum_2};
    
    default:{reg_div_numerator_2,reg_div_denominator_2}={32'b0,32'b0};
    endcase
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        softmax_1<=32'b0;
    end
    else begin 
        softmax_1<=div_wire_3;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        softmax_2<=32'b0;
    end
    else begin 
        softmax_2<=div_wire_4;
    end
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        head_out_1<=32'b0;
        head_out_2<=32'b0;
        head_out_3<=32'b0;
        head_out_4<=32'b0;
    end

    else if(counter==39 || counter==44 || counter==49 || counter==54 || counter==59)begin
        head_out_1<=wire_f0;
        head_out_2<=wire_f1;
        head_out_3<=wire_f2;
        head_out_4<=wire_f3;
    end
end
/*
always@(*)begin
    case(counter)
    28:wire_divide_1=reg_divide_1;
    29:wire_divide_1=reg_divide_1;
    30:wire_divide_1=reg_divide_1;
    31:wire_divide_1=reg_divide_1;
    32:wire_divide_1=reg_divide_1;
    33:wire_divide_1=reg_divide_1;
    34:wire_divide_1=reg_divide_1;
    35:wire_divide_1=reg_divide_1;
    36:wire_divide_1=reg_divide_1;
    37:wire_divide_1=reg_divide_1;
    38:wire_divide_1=reg_divide_1;
    39:wire_divide_1=reg_divide_1;
    40:wire_divide_1=reg_divide_1;
    41:wire_divide_1=reg_divide_1;
    42:wire_divide_1=reg_divide_1;
    43:wire_divide_1=reg_divide_1;
    44:wire_divide_1=reg_divide_1;
    45:wire_divide_1=reg_divide_1;
    46:wire_divide_1=reg_divide_1;
    47:wire_divide_1=reg_divide_1;
    48:wire_divide_1=reg_divide_1;
    49:wire_divide_1=reg_divide_1;
    50:wire_divide_1=reg_divide_1;
    51:wire_divide_1=reg_divide_1;
    52:wire_divide_1=reg_divide_1;
    default:wire_divide_1=reg_divide_1;
    endcase
end
always@(*)begin
    case(counter)
    28:wire_divide_2=reg_divide_2;
    29:wire_divide_2=reg_divide_2;
    30:wire_divide_2=reg_divide_2;
    31:wire_divide_2=reg_divide_2;
    32:wire_divide_2=reg_divide_2;
    33:wire_divide_2=reg_divide_2;
    34:wire_divide_2=reg_divide_2;
    35:wire_divide_2=reg_divide_2;
    36:wire_divide_2=reg_divide_2;
    37:wire_divide_2=reg_divide_2;
    38:wire_divide_2=reg_divide_2;
    39:wire_divide_2=reg_divide_2;
    40:wire_divide_2=reg_divide_2;
    41:wire_divide_2=reg_divide_2;
    42:wire_divide_2=reg_divide_2;
    43:wire_divide_2=reg_divide_2;
    44:wire_divide_2=reg_divide_2;
    45:wire_divide_2=reg_divide_2;
    46:wire_divide_2=reg_divide_2;
    47:wire_divide_2=reg_divide_2;
    48:wire_divide_2=reg_divide_2;
    49:wire_divide_2=reg_divide_2;
    50:wire_divide_2=reg_divide_2;
    51:wire_divide_2=reg_divide_2;
    52:wire_divide_2=reg_divide_2;
    default:wire_divide_2=reg_divide_2;
    endcase
end
*/
/*
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
        reg_exp_1<=32'b0;
        reg_exp_2<=32'b0;
    end
    else begin
        if(counter>=28 &&counter<=52)begin
            reg_exp_1<=wire_exp_1;
            reg_exp_2<=wire_exp_2;
        end
    end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
        reg_exp_f1<=32'b0;
    end
    else begin
        case(counter)
        28:reg_exp_f1<=wire_exp_f1;
        29:reg_exp_f1<=wire_exp_f1;
        30:reg_exp_f1<=wire_exp_f1;
        31:reg_exp_f1<=wire_exp_f1;
        32:reg_exp_f1<=wire_exp_f1;
        33:reg_exp_f1<=wire_exp_f1;
        34:reg_exp_f1<=wire_exp_f1;
        35:reg_exp_f1<=wire_exp_f1;
        36:reg_exp_f1<=wire_exp_f1;
        37:reg_exp_f1<=wire_exp_f1;
        38:reg_exp_f1<=wire_exp_f1;
        39:reg_exp_f1<=wire_exp_f1;
        40:reg_exp_f1<=wire_exp_f1;
        41:reg_exp_f1<=wire_exp_f1;
        42:reg_exp_f1<=wire_exp_f1;
        43:reg_exp_f1<=wire_exp_f1;
        44:reg_exp_f1<=wire_exp_f1;
        45:reg_exp_f1<=wire_exp_f1;
        46:reg_exp_f1<=wire_exp_f1;
        47:reg_exp_f1<=wire_exp_f1;
        48:reg_exp_f1<=wire_exp_f1;
        49:reg_exp_f1<=wire_exp_f1;
        50:reg_exp_f1<=wire_exp_f1;
        51:reg_exp_f1<=wire_exp_f1;
        52:reg_exp_f1<=wire_exp_f1;
        default:reg_exp_f1<=0;
        endcase
    end
end
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
        reg_exp_f2<=32'b0;
    end
    else begin
        case(counter)
        28:reg_exp_f2<=wire_exp_f2;
        29:reg_exp_f2<=wire_exp_f2;
        30:reg_exp_f2<=wire_exp_f2;
        31:reg_exp_f2<=wire_exp_f2;
        32:reg_exp_f2<=wire_exp_f2;
        33:reg_exp_f2<=wire_exp_f2;
        34:reg_exp_f2<=wire_exp_f2;
        35:reg_exp_f2<=wire_exp_f2;
        36:reg_exp_f2<=wire_exp_f2;
        37:reg_exp_f2<=wire_exp_f2;
        38:reg_exp_f2<=wire_exp_f2;
        39:reg_exp_f2<=wire_exp_f2;
        40:reg_exp_f2<=wire_exp_f2;
        41:reg_exp_f2<=wire_exp_f2;
        42:reg_exp_f2<=wire_exp_f2;
        43:reg_exp_f2<=wire_exp_f2;
        44:reg_exp_f2<=wire_exp_f2;
        45:reg_exp_f2<=wire_exp_f2;
        46:reg_exp_f2<=wire_exp_f2;
        47:reg_exp_f2<=wire_exp_f2;
        48:reg_exp_f2<=wire_exp_f2;
        49:reg_exp_f2<=wire_exp_f2;
        50:reg_exp_f2<=wire_exp_f2;
        51:reg_exp_f2<=wire_exp_f2;
        52:reg_exp_f2<=wire_exp_f2;
        default:reg_exp_f2<=0;
        endcase
    end
end
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
        reg_exp_1<=32'b0;
        reg_exp_2<=32'b0;
    end
    else begin
        reg_exp_1<=wire_exp_1;
        reg_exp_2<=wire_exp_2;
    end
end
*/
// ---------1----------// 
/*
always@(*)begin
    if(weight_counter==1 || weight_counter==2 || weight_counter==3 ||weight_counter==4)
        reg_mul_a_0=reg_in_str[weight_counter-1];
    else    
        reg_mul_a_0=32'd0;
end

always@(*)begin
    if(weight_counter==1 || weight_counter==2 || weight_counter==3 ||weight_counter==4)
        reg_mul_b_0=reg_k[weight_counter-1];
    else    
        reg_mul_b_0=32'd0;
end*/
// ---------2----------// 
/*
always@(*)begin
    if(weight_counter==5 || weight_counter==6 || weight_counter==7 ||weight_counter==8)
        reg_mul_a_1=reg_in_str[weight_counter-1];
    else    
        reg_mul_a_1=32'd0;
end

always@(*)begin
    if(weight_counter==5 || weight_counter==6 || weight_counter==7 ||weight_counter==8)
        reg_mul_b_1=reg_k[weight_counter-5];
    else    
        reg_mul_b_1=32'd0;
end
// ---------3----------// 
always@(*)begin
    if(weight_counter==5 || weight_counter==6 || weight_counter==7 ||weight_counter==8)
        reg_mul_a_2=reg_in_str[weight_counter-5];
    else    
        reg_mul_a_2=32'd0;
end

always@(*)begin
    if(weight_counter==5 || weight_counter==6 || weight_counter==7 ||weight_counter==8)
        reg_mul_b_2=reg_k[weight_counter-1];
    else    
        reg_mul_b_2=32'd0;
end
// ---------4----------// 
always@(*)begin
    if(weight_counter==5 || weight_counter==6 || weight_counter==7 ||weight_counter==8)
        reg_mul_a_3=reg_in_str[weight_counter-1];
    else    
        reg_mul_a_3=32'd0;
end

always@(*)begin
    if(weight_counter==5 || weight_counter==6 || weight_counter==7 ||weight_counter==8)
        reg_mul_b_3=reg_k[weight_counter-1];
    else    
        reg_mul_b_3=32'd0;
end
*/



always @(posedge clk or negedge rst_n)begin //k out_f0<=wire_f0;
	if(!rst_n)
        out_f0<=32'b0;
    else 
        out_f0<=wire_f0;
end
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
        out_f1<=32'b0;
    else 
        out_f1<=wire_f1;
end
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
        out_f2<=32'b0;
    else 
        out_f2<=wire_f2;
end
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
        out_f3<=32'b0;
    else 
        out_f3<=wire_f3;
end
always @(posedge clk or negedge rst_n)begin //q q_out_f0<=q_wire_f0;
	if(!rst_n)
        q_out_f0<=32'b0;
    else 
        q_out_f0<=q_wire_f0;
end
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
        q_out_f1<=32'b0;
    else 
        q_out_f1<=q_wire_f1;
end
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
        q_out_f2<=32'b0;
    else 
        q_out_f2<=q_wire_f2;
end
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
        q_out_f3<=32'b0;
    else 
        q_out_f3<=q_wire_f3;
end

always @(posedge clk or negedge rst_n)begin //q q_out_f0<=q_wire_f0;
	if(!rst_n)
        v_out_f0<=32'b0;
    else 
        v_out_f0<=v_wire_f0;
end
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
        v_out_f1<=32'b0;
    else 
        v_out_f1<=v_wire_f1;
end
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
        v_out_f2<=32'b0;
    else 
        v_out_f2<=v_wire_f2;
end
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
        v_out_f3<=32'b0;
    else 
        v_out_f3<=v_wire_f3;
end
/*
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)


    else 

end*/

//DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
//    MUL1 ( .a(reg_mul_a_0), .b(reg_mul_b_0), .rnd(3'b000), .z(f0), .status() );
//--------------split line-----------//
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    MAC1 ( .a(reg_mul_a_0), .b(reg_mul_b_0),.c(f0), .rnd(3'b000), .z(wire_f0), .status() );

//DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
//    MUL1 ( .a(reg_mul_a_0), .b(reg_mul_b_0), .rnd(3'b000), .z(wire_f0), .status() );
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    MAC2 ( .a(reg_mul_a_1), .b(reg_mul_b_1),.c(f1), .rnd(3'b000), .z(wire_f1), .status() );
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    MAC3 ( .a(reg_mul_a_2), .b(reg_mul_b_2),.c(f2), .rnd(3'b000), .z(wire_f2), .status() );
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    MAC4 ( .a(reg_mul_a_3), .b(reg_mul_b_3),.c(f3), .rnd(3'b000), .z(wire_f3), .status() );


DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    MAC5 ( .a(reg_mul_a_4), .b(reg_mul_b_4),.c(q_f0), .rnd(3'b000), .z(q_wire_f0), .status() );
//DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
//    MUL2 ( .a(reg_mul_a_5), .b(reg_mul_b_5), .rnd(3'b000), .z(q_wire_f0), .status() );
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    MAC6 ( .a(reg_mul_a_5), .b(reg_mul_b_5),.c(q_f1), .rnd(3'b000), .z(q_wire_f1), .status() );
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    MAC7 ( .a(reg_mul_a_6), .b(reg_mul_b_6),.c(q_f2), .rnd(3'b000), .z(q_wire_f2), .status() );
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    MAC8 ( .a(reg_mul_a_7), .b(reg_mul_b_7),.c(q_f3), .rnd(3'b000), .z(q_wire_f3), .status() );

DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    MAC9 ( .a(reg_mul_a_8), .b(reg_mul_b_8),.c(v_f0), .rnd(3'b000), .z(v_wire_f0), .status() );
//DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
//    MUL3 ( .a(reg_mul_a_8), .b(reg_mul_b_8), .rnd(3'b000), .z(v_wire_f0), .status() );
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
   MAC10 ( .a(reg_mul_a_9), .b(reg_mul_b_9),.c(v_f1), .rnd(3'b000), .z(v_wire_f1), .status() );
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
   MAC11 ( .a(reg_mul_a_10), .b(reg_mul_b_10),.c(v_f2), .rnd(3'b000), .z(v_wire_f2), .status() );
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
   MAC12 ( .a(reg_mul_a_11), .b(reg_mul_b_11),.c(v_f3), .rnd(3'b000), .z(v_wire_f3), .status() );
//DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
//    MAC2 ( .a(reg_mul_a_1), .b(reg_mul_b_1),.c(f0), .rnd(3'b000), .z(wire_f0), .status() );
//DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
//    MAC3 ( .a(reg_mul_a_1), .b(reg_mul_b_1),.c(f0), .rnd(3'b000), .z(wire_f0), .status() );
//DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
//    MAC4 ( .a(reg_mul_a_1), .b(reg_mul_b_1),.c(f0), .rnd(3'b000), .z(wire_f0), .status() );
///*
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
   DIV1(.a(reg_div_a_0),.b(sqare_root_2), .rnd(3'b000), .z(div_wire_1));
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
   DIV2(.a(reg_div_a_1),.b(sqare_root_2), .rnd(3'b000), .z(div_wire_2));


/*DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
   DIV3(.a(wire_divide_1),.b(sqare_root_2), .rnd(3'b000), .z(wire_exp_1));
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
   DIV4(.a(wire_divide_2),.b(sqare_root_2), .rnd(3'b000), .z(wire_exp_2));*/
/*DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) 
   EXP1(.a(reg_div_f1),.z(wire_exp_f1),.status());
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) 
   EXP2(.a(reg_div_f2),.z(wire_exp_f2),.status());*/
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) 
   EXP1(.a(exp_1),.z(wire_exp_1),.status());
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) 
   EXP2(.a(exp_2),.z(wire_exp_2),.status());
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
   ADD1 (.a(add_1), .b(add_f1), .rnd(3'd0),.z(wire_add_1), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
   ADD2 (.a(add_2), .b(add_f2), .rnd(3'd0),.z(wire_add_2), .status());

DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
   DIV3(.a(reg_div_numerator_1),.b(reg_div_denominator_1), .rnd(3'b000), .z(div_wire_3));
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
   DIV4(.a(reg_div_numerator_2),.b(reg_div_denominator_2), .rnd(3'b000), .z(div_wire_4));


always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		out_valid <= 'd0;
	else if (counter>=48 && counter<=67)//67-48+1=20
        out_valid <= 1'b1;
    else 
		out_valid <= 'd0;		
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		out <= 32'd0;
    else if(counter>=48 && counter<=67)
        out <= reg_in_str[counter-48];
    else
		out <= 32'd0;
end
endmodule


/*
module mac_0(
    input [inst_sig_width-1:0]  a,    
    input [inst_sig_width-1:0]  b,     
    output [inst_sig_width-1:0] f,              
);

    parameter inst_sig_width = 23;           
    parameter inst_exp_width = 8;         
    parameter inst_ieee_compliance = 0;     


    DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
        MUL1 ( .a(a), .b(b), .rnd(3'b000), .z(f), .status() );

endmodule
*/