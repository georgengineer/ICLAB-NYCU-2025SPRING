module SNN(
	// Input signals
	clk,
	rst_n,
	in_valid,
	img,
	ker,
	weight,
	// Output signals
	out_valid,
	out_data
);

input clk;
input rst_n;
input in_valid;
input [7:0] img;
input [7:0] ker;
input [7:0] weight;

output reg out_valid;
output reg [9:0] out_data;
//==============================================//
//       parameter & integer declaration        //
//==============================================//
integer i,j;
reg [2:0]next_state,current_state;
reg [6:0]counter;
reg [7:0]img_reg[0:2][0:5]; // 8bit half of img
reg [7:0]ker_reg[0:2][0:2];           //8bit 3*3
reg [7:0]weight_reg[0:1][0:1];        //8bit 3*3

reg [7:0]data_gating_img_reg[0:2][0:5]; 
reg [7:0]data_gating_ker_reg[0:2][0:2];
reg [7:0]data_gating_weight_reg[0:1][0:1];

reg [7:0]convolution_img[0:2][0:2];
reg [9:0]L1_distance;
reg [7:0]temp1,temp2,temp3,temp4;
reg [7:0]conv_shift_register[0:14];
reg [7:0]conv_shift_power[0:8];
reg [7:0]data_gating_conv_shift_register[0:14];
reg [19:0]conv_out;
reg [19:0]couv_out_reg;
reg [7:0]quautization1;
reg [7:0]quautization_REG;
reg [7:0]quautization1_reg,quautization2_reg;
reg [7:0]compare[0:1];
reg [7:0]compare2;
reg [7:0]compare_result[0:1];
reg [16:0]fully_connected1,fully_connected2;
reg [7:0]encoding[0:7];
reg [7:0]data_gating_encoding[0:7];
reg [9:0]activation;
reg img_in_valid;
reg ker_in_valid;
reg weight_in_valid;

wire counter_0;
wire counter_14;
assign counter_0 =(counter==0)?1'b1:1'b0;
assign counter_14=(counter>=14)?1'b1:1'b0;
//wire img_in_valid;
//wire ker_in_valid;
//wire weight_in_valid;
//assign img_in_valid   =(in_valid==1'b1 && counter<18)?1'b1:1'b0;
//assign ker_in_valid   =(in_valid==1'b1 && counter<9)?1'b1:1'b0;
//assign weight_in_valid=(in_valid==1'b1 && counter<4)?1'b1:1'b0;
wire shift_register_clk;wire a=(counter==0)?1'b1:1'b0;
//==============================================//
//           reg & wire declaration             //
//==============================================//
reg convolution_enable;
reg counter_enable;
reg compare_enable;
reg weight_enable;

wire convolution_clk;
wire counter_clk;
wire compare_clk;
wire weight_clk;

									 //.SLEEP_CTRL(1'b1) lock  , .SLEEP_CTRL(1'b0) clk  
//GATED_OR GATED_convolution(.CLOCK(clk),.SLEEP_CTRL(cg_en&&convolution_enable),.RST_N(rst_n),.CLOCK_GATED(convolution_clk));
//GATED_OR GATED_compare    (.CLOCK(clk),.SLEEP_CTRL(cg_en&&compare_enable),.RST_N(rst_n),.CLOCK_GATED(compare_clk));
//GATED_OR GATED_shiftregister(.CLOCK(clk),.SLEEP_CTRL(cg_en&&shift_register_enable),.RST_N(rst_n),.CLOCK_GATED(shift_register_clk));
//GATED_OR GATED_weight     (.CLOCK(clk),.SLEEP_CTRL(cg_en&&weight_enable),.RST_N(rst_n),.CLOCK_GATED(weight_clk));
//GATED_OR GATED_counter    (.CLOCK(clk),.SLEEP_CTRL(cg_en&&a),.RST_N(rst_n),.CLOCK_GATED(counter_clk));


//==============================================//
//                  design                      //
//==============================================//

/*
always @(*) begin
	case (counter)
		//19,20,25,26,31,32,37,38,            // img1
		//39,40,41,42,43,44,45,46,47,48,49,50,// middle value wait next image
		//55,56,61,62,67,68,73:               // img2
		0,1,2,3,4,5,6,7,8,9,10,11,12,
		19,25,31,37,           
		38,39,40,41,42,43,44,45,46,47,48,49,
		55,61,67,73:               
			convolution_enable = 1'b1;
		default:
			convolution_enable = 1'b0;
	endcase
end
*/
always @(*) begin
	case (counter)
		//19,20,25,26,31,32,37,38,            // img1
		//39,40,41,42,43,44,45,46,47,48,49,50,// middle value wait next image
		//55,56,61,62,67,68,73:               // img2
		14,15,16,17,20,21,22,23,26,27,28,29,
		32,33,34,35,50,51,52,53,56,57,58,59,
		62,63,64,65,68,69,70,71:
			convolution_enable = 1'b0;
		default:
			convolution_enable = 1'b1;
	endcase
end

always @(*) begin
	case (counter)
	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,
	38,39,40,41,42,43,44,45,46,47,48,49,50:
		compare_enable=1'b1;
	default:
		compare_enable=1'b0;
	endcase
end
always@(*)begin
	case (counter)
	0,1,2,3:weight_enable=1'b0;
	default:weight_enable=1'b1;
	endcase
end


always@(*)begin
	if(in_valid==1'b1 && counter<9)
		ker_in_valid=1'b1;
	else 
		ker_in_valid=1'b0;
end
always@(*)begin
	if(in_valid==1'b1 && counter<4)
		weight_in_valid=1'b1;
	else 
		weight_in_valid=1'b0;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		counter<=0;
	else if(counter==73)
		counter<=0;
	else if(counter>0)
		counter<=counter+1'b1;
	else if(in_valid==1'b1)
		counter<=1;
	else 
		counter<=counter;
end

//img_reg
/*
always@(posedge clk)begin
	if(img_in_valid)begin
		img_reg[2][5]<=img;
		img_reg[2][4]<=img_reg[2][5];
		img_reg[2][3]<=img_reg[2][4];
		img_reg[2][2]<=img_reg[2][3];
		img_reg[2][1]<=img_reg[2][2];
		img_reg[2][0]<=img_reg[2][1];
		img_reg[1][5]<=img_reg[2][0];
		img_reg[1][4]<=img_reg[1][5];
		img_reg[1][3]<=img_reg[1][4];
		img_reg[1][2]<=img_reg[1][3];
		img_reg[1][1]<=img_reg[1][2];
		img_reg[1][0]<=img_reg[1][1];
		img_reg[0][5]<=img_reg[1][0];
		img_reg[0][4]<=img_reg[0][5];
		img_reg[0][3]<=img_reg[0][4];
		img_reg[0][2]<=img_reg[0][3];
		img_reg[0][1]<=img_reg[0][2];
		img_reg[0][0]<=img_reg[0][1];
	end
end
*/

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin 
		for(int i=0;i<15;i=i+1)begin
			conv_shift_register[i]<=0;
		end
	end
	else if(in_valid)begin
		for(int i=0;i<14;i=i+1)begin
			conv_shift_register[i]<=conv_shift_register[i+1];
		end
		conv_shift_register[14]<=img;
	end
end

//zero gating      :data_gating_conv_shift_register
always@(*)begin
	if(counter_14) begin
		data_gating_conv_shift_register[ 0]=(conv_shift_register[ 0]!=0)? conv_shift_register[ 0] : 0 ;
		data_gating_conv_shift_register[ 1]=(conv_shift_register[ 1]!=0)? conv_shift_register[ 1] : 0 ;
		data_gating_conv_shift_register[ 2]=(conv_shift_register[ 2]!=0)? conv_shift_register[ 2] : 0 ;
		data_gating_conv_shift_register[ 3]=(conv_shift_register[ 3]!=0)? conv_shift_register[ 3] : 0 ;
		data_gating_conv_shift_register[ 4]=(conv_shift_register[ 4]!=0)? conv_shift_register[ 4] : 0 ;
		data_gating_conv_shift_register[ 5]=(conv_shift_register[ 5]!=0)? conv_shift_register[ 5] : 0 ;
		data_gating_conv_shift_register[ 6]=(conv_shift_register[ 6]!=0)? conv_shift_register[ 6] : 0 ;
		data_gating_conv_shift_register[ 7]=(conv_shift_register[ 7]!=0)? conv_shift_register[ 7] : 0 ;
		data_gating_conv_shift_register[ 8]=(conv_shift_register[ 8]!=0)? conv_shift_register[ 8] : 0 ;
		data_gating_conv_shift_register[ 9]=(conv_shift_register[ 9]!=0)? conv_shift_register[ 9] : 0 ;
		data_gating_conv_shift_register[10]=(conv_shift_register[10]!=0)? conv_shift_register[10] : 0 ;
		data_gating_conv_shift_register[11]=(conv_shift_register[11]!=0)? conv_shift_register[11] : 0 ;
		data_gating_conv_shift_register[12]=(conv_shift_register[12]!=0)? conv_shift_register[12] : 0 ;
		data_gating_conv_shift_register[13]=(conv_shift_register[13]!=0)? conv_shift_register[13] : 0 ;
		data_gating_conv_shift_register[14]=(conv_shift_register[14]!=0)? conv_shift_register[14] : 0 ;
	end
	else begin
		data_gating_conv_shift_register[ 0]=0;
		data_gating_conv_shift_register[ 1]=0;
		data_gating_conv_shift_register[ 2]=0;
		data_gating_conv_shift_register[ 3]=0;
		data_gating_conv_shift_register[ 4]=0;
		data_gating_conv_shift_register[ 5]=0;
		data_gating_conv_shift_register[ 6]=0;
		data_gating_conv_shift_register[ 7]=0;
		data_gating_conv_shift_register[ 8]=0;
		data_gating_conv_shift_register[ 9]=0;
		data_gating_conv_shift_register[10]=0;
		data_gating_conv_shift_register[11]=0;
		data_gating_conv_shift_register[12]=0;
		data_gating_conv_shift_register[13]=0;
		data_gating_conv_shift_register[14]=0;
	end
end
//zero gating data_gating_ker_reg
always@(*)begin 
	if(counter_14) begin
		data_gating_ker_reg[0][0]=(ker_reg[0][0]!=0)?ker_reg[0][0]:0;
		data_gating_ker_reg[0][1]=(ker_reg[0][1]!=0)?ker_reg[0][1]:0;
		data_gating_ker_reg[0][2]=(ker_reg[0][2]!=0)?ker_reg[0][2]:0;
		data_gating_ker_reg[1][0]=(ker_reg[1][0]!=0)?ker_reg[1][0]:0;
		data_gating_ker_reg[1][1]=(ker_reg[1][1]!=0)?ker_reg[1][1]:0;
		data_gating_ker_reg[1][2]=(ker_reg[1][2]!=0)?ker_reg[1][2]:0;
		data_gating_ker_reg[2][0]=(ker_reg[2][0]!=0)?ker_reg[2][0]:0;
		data_gating_ker_reg[2][1]=(ker_reg[2][1]!=0)?ker_reg[2][1]:0;
		data_gating_ker_reg[2][2]=(ker_reg[2][2]!=0)?ker_reg[2][2]:0;
	end
	else begin
		data_gating_ker_reg[0][0]=0;
		data_gating_ker_reg[0][1]=0;
		data_gating_ker_reg[0][2]=0;
		data_gating_ker_reg[1][0]=0;
		data_gating_ker_reg[1][1]=0;
		data_gating_ker_reg[1][2]=0;
		data_gating_ker_reg[2][0]=0;
		data_gating_ker_reg[2][1]=0;
		data_gating_ker_reg[2][2]=0;
	end
end

MAC_3x3 mac_instance (
	    //.in_1_a  (conv_shift_register[ 0]),
        //.in_2_a  (conv_shift_register[ 1]),
        //.in_3_a  (conv_shift_register[ 2]),
        //.in_4_a  (conv_shift_register[ 6]),
        //.in_5_a  (conv_shift_register[ 7]),
        //.in_6_a  (conv_shift_register[ 8]),
        //.in_7_a  (conv_shift_register[12]),
        //.in_8_a  (conv_shift_register[13]),
		//.in_9_a  (img),
		.in_1_a  (data_gating_conv_shift_register[ 0]),
		.in_2_a  (data_gating_conv_shift_register[ 1]),
		.in_3_a  (data_gating_conv_shift_register[ 2]),
		.in_4_a  (data_gating_conv_shift_register[ 6]),
		.in_5_a  (data_gating_conv_shift_register[ 7]),
		.in_6_a  (data_gating_conv_shift_register[ 8]),
		.in_7_a  (data_gating_conv_shift_register[12]),
		.in_8_a  (data_gating_conv_shift_register[13]),
		.in_9_a  (data_gating_conv_shift_register[14]),

        .in_1_b  (data_gating_ker_reg[0][0]),
        .in_2_b  (data_gating_ker_reg[0][1]),
        .in_3_b  (data_gating_ker_reg[0][2]),
        .in_4_b  (data_gating_ker_reg[1][0]),
        .in_5_b  (data_gating_ker_reg[1][1]),
        .in_6_b  (data_gating_ker_reg[1][2]),
        .in_7_b  (data_gating_ker_reg[2][0]),
        .in_8_b  (data_gating_ker_reg[2][1]),
        .in_9_b  (data_gating_ker_reg[2][2]),
        .result    (conv_out));
/*
always@(posedge convolution_clk)begin	
	couv_out_reg<=data_gating_conv_shift_register[ 1]*data_gating_ker_reg[0][0]+ 
				  data_gating_conv_shift_register[ 2]*data_gating_ker_reg[0][1]+
				  data_gating_conv_shift_register[ 3]*data_gating_ker_reg[0][2]+
				  data_gating_conv_shift_register[ 7]*data_gating_ker_reg[1][0]+
				  data_gating_conv_shift_register[ 8]*data_gating_ker_reg[1][1]+
				  data_gating_conv_shift_register[ 9]*data_gating_ker_reg[1][2]+
				  data_gating_conv_shift_register[13]*data_gating_ker_reg[2][0]+
				  data_gating_conv_shift_register[14]*data_gating_ker_reg[2][1]+
				                                  img*data_gating_ker_reg[2][2];

end
*/

always@(*)begin
	if(convolution_enable==0)begin
		conv_shift_power[0]=conv_shift_register[ 1];
		conv_shift_power[1]=conv_shift_register[ 2];
		conv_shift_power[2]=conv_shift_register[ 3];
		conv_shift_power[3]=conv_shift_register[ 7];
		conv_shift_power[4]=conv_shift_register[ 8];
		conv_shift_power[5]=conv_shift_register[ 9];
		conv_shift_power[6]=conv_shift_register[13];
		conv_shift_power[7]=conv_shift_register[14];
		conv_shift_power[8]=img;
	end
	else begin
		//if(cg_en)begin
			conv_shift_power[0]=0;
			conv_shift_power[1]=0;
			conv_shift_power[2]=0;
			conv_shift_power[3]=0;
			conv_shift_power[4]=0;
			conv_shift_power[5]=0;
			conv_shift_power[6]=0;
			conv_shift_power[7]=0;
			conv_shift_power[8]=0;
		//end
		//else begin
		//	conv_shift_power[0]=couv_out_reg[7:0];
		//	conv_shift_power[1]=couv_out_reg[7:0];
		//	conv_shift_power[2]=couv_out_reg[7:0];
		//	conv_shift_power[3]=couv_out_reg[7:0];
		//	conv_shift_power[4]=couv_out_reg[7:0];
		//	conv_shift_power[5]=couv_out_reg[7:0];
		//	conv_shift_power[6]=couv_out_reg[7:0];
		//	conv_shift_power[7]=couv_out_reg[7:0];
		//	conv_shift_power[8]=couv_out_reg[7:0];
		//end
	end
end

always@(posedge clk)begin	

	couv_out_reg<=conv_shift_power[0]*ker_reg[0][0]+ 
				  conv_shift_power[1]*ker_reg[0][1]+
				  conv_shift_power[2]*ker_reg[0][2]+
				  conv_shift_power[3]*ker_reg[1][0]+
				  conv_shift_power[4]*ker_reg[1][1]+
				  conv_shift_power[5]*ker_reg[1][2]+
				  conv_shift_power[6]*ker_reg[2][0]+
				  conv_shift_power[7]*ker_reg[2][1]+
				  conv_shift_power[8]*ker_reg[2][2];


end
//always @(*) begin
//    case (counter)
//        14, 15, 16, 17: quautization1 = conv_out / 'd2295;
//        20, 21, 22, 23: quautization1 = conv_out / 'd2295;
//        26, 27, 28, 29: quautization1 = conv_out / 'd2295;
//        32, 33, 34, 35: quautization1 = conv_out / 'd2295;
//        50, 51, 52, 53: quautization1 = conv_out / 'd2295;
//        56, 57, 58, 59: quautization1 = conv_out / 'd2295;
//        62, 63, 64, 65: quautization1 = conv_out / 'd2295;
//        68, 69, 70, 71: quautization1 = conv_out / 'd2295;
//        default: quautization1 = 0;
//    endcase
//end



always @(*) begin
	if(counter_14)
		quautization1 = couv_out_reg / 'd2295;
	else
		quautization1 = 0;
end
/*
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		quautization_REG<=0;
	else
		quautization_REG<=couv_out_reg / 'd2295;
end

reg [7:0]compare1,compare2,compare3,compare4;
always @(*) begin

		compare1=quautization_REG;
end
always@(posedge clk)begin

	compare2<=compare1;
end
*/

/*
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin 
		compare[0]<=8'b0;
		compare[1]<=8'b0;
	end
	else if (counter==0)begin
		compare[0]<=8'b0;
		compare[1]<=8'b0;
	end
	else begin
		//case(counter)
		//14,20,26,32:compare[0]<=(quautization1>=compare[0])? quautization1 : compare[0];
		//15,21,27,33:compare[0]<=compare_result[0];
		//16,22,28,34:compare[1]<=(quautization1>=compare[1])? quautization1 : compare[1];
		//17,23,29,35:compare[1]<=compare_result[1];
		//24,36,60,72:    begin   compare[0]<=0; compare[1]<=0; end
		//50,56,62,68:compare[0]<=(quautization1>=compare[0])? quautization1 : compare[0];
		//51,57,63,69:compare[0]<=compare_result[0];
		//52,58,64,70:compare[1]<=(quautization1>=compare[1])? quautization1 : compare[1];
		//53,59,65,71:compare[1]<=compare_result[1];
		//endcase
		case(counter)
		15:compare[0]<=quautization1;
		16,21,27,33,22,28,34:compare[0]<=(quautization1>=compare[0])? quautization1 : compare[0];
		17:compare[1]<=quautization1;	
		18,23,29,35,24,30,36:compare[1]<=(quautization1>=compare[1])? quautization1 : compare[1];
		
		25,37,61,73:    begin   compare[0]<=0; compare[1]<=0; end
		51:compare[0]<=quautization1;
		52,57,63,69,58,64,70:compare[0]<=(quautization1>=compare[0])? quautization1 : compare[0];
		53:compare[1]<=quautization1;
		54,59,65,71,60,66,72:compare[1]<=(quautization1>=compare[1])? quautization1 : compare[1];
		
		endcase


	end
end
*/
function [7:0] max2;
	input [7:0] a, b;
	begin
		max2 = (a >= b) ? a : b;
	end
endfunction

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		compare[0] <= 8'd0;
		compare[1] <= 8'd0;
	end
	else begin
		case (counter)

			15, 51: 
			compare[0] <= quautization1;

			16, 21, 22, 27, 28, 33, 34,
			52, 57, 58, 63, 64, 69, 70:
			compare[0] <= max2(compare[0], quautization1);


			17, 53: compare[1] <= quautization1;
			18, 23, 24, 29, 30, 35, 36,
			54, 59, 60, 65, 66, 71, 72:
				compare[1] <= max2(compare[1], quautization1);
			// reset or clear up the value inside  compare[0] compare[1]
			25, 37, 61, 73: begin
				compare[0] <= 8'd0;
				compare[1] <= 8'd0;
			end
		endcase
	end
end

/*
always@(*)begin
	if(compare[0]>=quautization1)
		compare_result[0]=compare[0];
	else
		compare_result[0]=quautization1;
end
always@(*)begin
	if(compare[1]>=quautization1)
		compare_result[1]=compare[1];
	else
		compare_result[1]=quautization1;
end*/
/*
always@(*)begin
    case(counter)
    25:begin
        fully_connected1=compare[0]*weight_reg[0][0]+compare[1]*weight_reg[1][0];
        fully_connected2=compare[0]*weight_reg[0][1]+compare[1]*weight_reg[1][1];
    end
    37:begin
        fully_connected1=compare[0]*weight_reg[0][0]+compare[1]*weight_reg[1][0];
        fully_connected2=compare[0]*weight_reg[0][1]+compare[1]*weight_reg[1][1];
    end
    61:begin
        fully_connected1=compare[0]*weight_reg[0][0]+compare[1]*weight_reg[1][0];
        fully_connected2=compare[0]*weight_reg[0][1]+compare[1]*weight_reg[1][1];
    end
    73:begin
        fully_connected1=compare[0]*weight_reg[0][0]+compare[1]*weight_reg[1][0];
        fully_connected2=compare[0]*weight_reg[0][1]+compare[1]*weight_reg[1][1];
    end
    default:begin
        fully_connected1=0;
        fully_connected2=0;
    end
    endcase
end
*/
always @(*) begin
	if (counter == 25 || counter == 37 || counter == 61 || counter == 73) begin
		fully_connected1 = compare[0]*weight_reg[0][0] + compare[1]*weight_reg[1][0];
		fully_connected2 = compare[0]*weight_reg[0][1] + compare[1]*weight_reg[1][1];
	end
	else begin
		fully_connected1 = 0;
		fully_connected2 = 0;
	end
end




always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin 
        for(int i=0;i<8;i=i+1)begin
            encoding[i]<=0;
        end
    end
    else begin
        case (counter)
        25:begin
            encoding[0]<=fully_connected1 / 'd510;
            encoding[1]<=fully_connected2 / 'd510;
        end
        37:begin
            encoding[2]<=fully_connected1 / 'd510;
            encoding[3]<=fully_connected2 / 'd510;
        end
        61:begin
            encoding[4]<=fully_connected1 / 'd510;
            encoding[5]<=fully_connected2 / 'd510;
        end
        73:begin
            encoding[6]<=fully_connected1 / 'd510;
            encoding[7]<=fully_connected2 / 'd510;
        end
        endcase
    end
end
//zero gating
always@(*)begin
	if(counter_0)begin
		data_gating_encoding[0]=encoding[0];
		data_gating_encoding[1]=encoding[1];
		data_gating_encoding[2]=encoding[2];
		data_gating_encoding[3]=encoding[3];
		data_gating_encoding[4]=encoding[4];
		data_gating_encoding[5]=encoding[5];
		data_gating_encoding[6]=encoding[6];
		data_gating_encoding[7]=encoding[7];
	end
	else begin
		data_gating_encoding[0]=0;
		data_gating_encoding[1]=0;
		data_gating_encoding[2]=0;
		data_gating_encoding[3]=0;
		data_gating_encoding[4]=0;
		data_gating_encoding[5]=0;
		data_gating_encoding[6]=0;
		data_gating_encoding[7]=0;
	end
end
COMPARE_AND_MINUS_2 compare_temp1(
	.in_1_a(data_gating_encoding[0]),
	.in_1_b(data_gating_encoding[4]),
	.bigger(temp1)
);
COMPARE_AND_MINUS_2 compare_temp2(
	.in_1_a(data_gating_encoding[1]),
	.in_1_b(data_gating_encoding[5]),
	.bigger(temp2)
);

COMPARE_AND_MINUS_2 compare_temp3(
	.in_1_a(data_gating_encoding[2]),
	.in_1_b(data_gating_encoding[6]),
	.bigger(temp3)
);
COMPARE_AND_MINUS_2 compare_temp4(
	.in_1_a(data_gating_encoding[3]),
	.in_1_b(data_gating_encoding[7]),
	.bigger(temp4)
);


always@(*)begin
	if(counter_0)
		L1_distance=temp1+temp2+temp3+temp4;
	else
		L1_distance=0;
end


always@(*)begin
	if(counter_0)
		if(L1_distance<16)
			activation=0;
		else 
			activation=L1_distance;
	else 
		activation=0;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin 
		for(int i=0;i<3;i=i+1)begin
			for(int j=0;j<3;j=j+1)begin
				ker_reg[i][j]<=0;
			end
		end
	end
	else if(in_valid==1'b1 && counter<9)begin
		ker_reg[2][2]<=ker;
		ker_reg[2][1]<=ker_reg[2][2];
		ker_reg[2][0]<=ker_reg[2][1];
		ker_reg[1][2]<=ker_reg[2][0];
		ker_reg[1][1]<=ker_reg[1][2];
		ker_reg[1][0]<=ker_reg[1][1];
		ker_reg[0][2]<=ker_reg[1][0];
		ker_reg[0][1]<=ker_reg[0][2];
		ker_reg[0][0]<=ker_reg[0][1];
	end
end


always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin 
		for(int i=0;i<2;i=i+1)begin
			for(int j=0;j<2;j=j+1)begin
				weight_reg[i][j]<=0;
			end
		end
	end
	else if(in_valid==1'b1 ) begin
		case(counter)
		0:weight_reg[0][0]<=weight;
		1:weight_reg[0][1]<=weight;
		2:weight_reg[1][0]<=weight;
		3:weight_reg[1][1]<=weight;

		endcase
	end
	/*
	else if(in_valid==1'b1 && counter<4)begin
		weight_reg[1][1]<=weight;
		weight_reg[1][0]<=weight_reg[1][1];
		weight_reg[0][1]<=weight_reg[1][0];
		weight_reg[0][0]<=weight_reg[0][1];
	end*/
	/*else if(counter>=4 && counter<=23)begin
		weight_reg[0][0]<=weight_reg[0][1];
		weight_reg[0][1]<=weight_reg[0][0];
		weight_reg[1][0]<=weight_reg[1][1];
		weight_reg[1][1]<=weight_reg[1][0];
	end
	else if(counter>=25 && counter<=36)begin
		weight_reg[0][0]<=weight_reg[0][1];
		weight_reg[0][1]<=weight_reg[0][0];
		weight_reg[1][0]<=weight_reg[1][1];
		weight_reg[1][1]<=weight_reg[1][0];
	end*/
	/*else if(counter>=36 && counter<=60)begin
		weight_reg[0][0]<=weight_reg[0][1];
		weight_reg[0][1]<=weight_reg[0][0];
		weight_reg[1][0]<=weight_reg[1][1];
		weight_reg[1][1]<=weight_reg[1][0];
	end
	else if(counter>=60 && counter<=72)begin
		weight_reg[0][0]<=weight_reg[0][1];
		weight_reg[0][1]<=weight_reg[0][0];
		weight_reg[1][0]<=weight_reg[1][1];
		weight_reg[1][1]<=weight_reg[1][0];
	end*/

end








always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin 
		out_valid<=0;
	end 
	else if(counter==73)begin
		out_valid<=1;
	end
	else 
		out_valid<=0;
end
always@(*)begin
	if(out_valid==1'b1)
		out_data=activation;
	else 
		out_data=0;
end



endmodule

module MAC_3x3 (
	input  [7:0] in_1_a, in_2_a, in_3_a, in_4_a, in_5_a, in_6_a, in_7_a, in_8_a , in_9_a,
	input  [7:0] in_1_b, in_2_b, in_3_b, in_4_b, in_5_b, in_6_b, in_7_b, in_8_b , in_9_b,
	output [19:0] result
);

assign result = in_1_a * in_1_b + in_2_a * in_2_b + in_3_a * in_3_b + in_4_a * in_4_b + 
				in_5_a * in_5_b + in_6_a * in_6_b + in_7_a * in_7_b + in_8_a * in_8_b + in_9_a * in_9_b ;

endmodule


module COMPARE_AND_MINUS_2(
	input  [7:0] in_1_a,
	input  [7:0] in_1_b,
	output [7:0] bigger
);
assign bigger =(in_1_a>=in_1_b)? (in_1_a-in_1_b):(in_1_b-in_1_a);
endmodule