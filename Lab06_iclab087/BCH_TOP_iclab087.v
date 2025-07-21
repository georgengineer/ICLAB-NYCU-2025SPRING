//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2025
//		Version		: v1.0
//   	File Name   : BCH_TOP.v
//   	Module Name : BCH_TOP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
  
`include "Division_IP.v"

module BCH_TOP(
    // Input signals
    clk,
	rst_n,
	in_valid,
    in_syndrome, 
    // Output signals
    out_valid, 
	out_location
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid;
input [3:0] in_syndrome;
output reg out_valid;
output reg [3:0] out_location;

parameter IP_WIDTH=7;
// ===============================================================
// Reg & Wire Declaration
// ===============================================================
reg [IP_WIDTH*4-1:0]  IN_Dividend;

reg [IP_WIDTH*4-1:0]  IN_Divisor;
reg [IP_WIDTH*4-1:0]  OUT_Quotient;
reg [IP_WIDTH*4-1:0]  Remainder;
reg [7:0]divide_1_quotient;
reg [15:0]x6_OUT_Quotient;
reg [19:0]x6_Remainder;
reg [23:0]second_OUT_Quotient;
reg [23:0]second_Remainder;
reg [3:0]counter;
reg [IP_WIDTH*4-1:0]receive;
reg [IP_WIDTH*4-1:0]temp_IN_Divisor;
reg [IP_WIDTH*4-1:0]temp_OUT_Quotient;
reg [IP_WIDTH*4-1:0]temp_Remainder;

wire [27:0]x6;
assign x6=28'h0ff_ffff;
reg flag;

wire [3:0]sigma_0;
wire [3:0]sigma_1;

reg [3:0]sigma_zero[5:0];
reg [3:0]sigma[5:0];
reg [3:0]q[5:0];
reg [3:0]sigma_reg[5:0];
reg [3:0]sigma_temp[5:0];
wire sigma_check;
wire omega_check;
assign sigma_check=(counter>=7&&sigma_reg[5]==4'hf && sigma_reg[4]==4'hf)?1'b1:1'b0;
assign omega_check=(counter>=7&&temp_Remainder[27:24]==4'hf && temp_Remainder[23:20]==4'hf &&temp_Remainder[19:16]==4'hf &&temp_Remainder[15:12]==4'hf)?1'b1:1'b0;
assign sigma_0=4'hf;//0
assign sigma_1=4'h0;//1
wire chein_check[14:0];
reg  output_flag[14:0];
reg  [7:0]no_matter_signal;
integer i;
reg [1:0]next_state,current_state;
reg output_enable;

assign chein_check[0]  = (get_alpha_index(get_alpha_index(minus(0 , sigma_reg[3]), minus(0 , sigma_reg[2])), get_alpha_index(minus(0 , sigma_reg[1]), minus(0 , sigma_reg[0]))) == 15) ? 1'b1 : 1'b0;
assign chein_check[1]  = (get_alpha_index(get_alpha_index(minus(12, sigma_reg[3]), minus(13, sigma_reg[2])), get_alpha_index(minus(14, sigma_reg[1]), minus(0 , sigma_reg[0]))) == 15) ? 1'b1 : 1'b0;
assign chein_check[2]  = (get_alpha_index(get_alpha_index(minus(9 , sigma_reg[3]), minus(11, sigma_reg[2])), get_alpha_index(minus(13, sigma_reg[1]), minus(0 , sigma_reg[0]))) == 15) ? 1'b1 : 1'b0;
assign chein_check[3]  = (get_alpha_index(get_alpha_index(minus(6 , sigma_reg[3]), minus(9 , sigma_reg[2])), get_alpha_index(minus(12, sigma_reg[1]), minus(0 , sigma_reg[0]))) == 15) ? 1'b1 : 1'b0;
assign chein_check[4]  = (get_alpha_index(get_alpha_index(minus(3 , sigma_reg[3]), minus(7 , sigma_reg[2])), get_alpha_index(minus(11, sigma_reg[1]), minus(0 , sigma_reg[0]))) == 15) ? 1'b1 : 1'b0;
assign chein_check[5]  = (get_alpha_index(get_alpha_index(minus(0 , sigma_reg[3]), minus(5 , sigma_reg[2])), get_alpha_index(minus(10, sigma_reg[1]), minus(0 , sigma_reg[0]))) == 15) ? 1'b1 : 1'b0;
assign chein_check[6]  = (get_alpha_index(get_alpha_index(minus(12, sigma_reg[3]), minus(3 , sigma_reg[2])), get_alpha_index(minus(9 , sigma_reg[1]), minus(0 , sigma_reg[0]))) == 15) ? 1'b1 : 1'b0;
assign chein_check[7]  = (get_alpha_index(get_alpha_index(minus(9 , sigma_reg[3]), minus(1 , sigma_reg[2])), get_alpha_index(minus(8 , sigma_reg[1]), minus(0 , sigma_reg[0]))) == 15) ? 1'b1 : 1'b0;
assign chein_check[8]  = (get_alpha_index(get_alpha_index(minus(6 , sigma_reg[3]), minus(14, sigma_reg[2])), get_alpha_index(minus(7 , sigma_reg[1]), minus(0 , sigma_reg[0]))) == 15) ? 1'b1 : 1'b0;
assign chein_check[9]  = (get_alpha_index(get_alpha_index(minus(3 , sigma_reg[3]), minus(12, sigma_reg[2])), get_alpha_index(minus(6 , sigma_reg[1]), minus(0 , sigma_reg[0]))) == 15) ? 1'b1 : 1'b0;
assign chein_check[10] = (get_alpha_index(get_alpha_index(minus(0 , sigma_reg[3]), minus(10, sigma_reg[2])), get_alpha_index(minus(5 , sigma_reg[1]), minus(0 , sigma_reg[0]))) == 15) ? 1'b1 : 1'b0;
assign chein_check[11] = (get_alpha_index(get_alpha_index(minus(12, sigma_reg[3]), minus(8 , sigma_reg[2])), get_alpha_index(minus(4 , sigma_reg[1]), minus(0 , sigma_reg[0]))) == 15) ? 1'b1 : 1'b0;
assign chein_check[12] = (get_alpha_index(get_alpha_index(minus(9 , sigma_reg[3]), minus(6 , sigma_reg[2])), get_alpha_index(minus(3 , sigma_reg[1]), minus(0 , sigma_reg[0]))) == 15) ? 1'b1 : 1'b0;
assign chein_check[13] = (get_alpha_index(get_alpha_index(minus(6 , sigma_reg[3]), minus(4 , sigma_reg[2])), get_alpha_index(minus(2 , sigma_reg[1]), minus(0 , sigma_reg[0]))) == 15) ? 1'b1 : 1'b0;
assign chein_check[14] = (get_alpha_index(get_alpha_index(minus(3 , sigma_reg[3]), minus(2 , sigma_reg[2])), get_alpha_index(minus(1 , sigma_reg[1]), minus(0 , sigma_reg[0]))) == 15) ? 1'b1 : 1'b0;


Division_IP_first_level x6_first_level (                                     .IN_Divisor(IN_Divisor[23:0]), .OUT_Quotient(x6_OUT_Quotient) , .Remainder(x6_Remainder));
Division_IP #(.IP_WIDTH(2)) I_Division_IP(.IN_Dividend({IN_Dividend[27:20]}),.IN_Divisor(8'hf0), .OUT_Quotient(divide_1_quotient)); 
Division_IP_Plus #(.IP_WIDTH(6)) instance1(.IN_Dividend(IN_Dividend[23:0]) ,.IN_Divisor(IN_Divisor[23:0]), .OUT_Quotient(second_OUT_Quotient), .Remainder(second_Remainder)); 

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        current_state<=0;
    end
    else begin
        current_state<=next_state;
    end
end
always@(*)begin
    case(current_state)
    0:next_state=(omega_check&&sigma_check)?1'b1:1'b0;
    1:next_state=2;
    2:next_state=3;
    3:next_state=0;
    default:next_state=0;
    endcase
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        counter<=0;
    end
    else if(next_state==1)
        counter<=0;
    else if(in_valid==1)
        counter<=counter+1'b1;
    else if(counter>=5)
        counter<=counter+1'b1;
    else begin
        counter<=counter;
    end
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        receive<=28'hfff_ffff;
    end
    else if(in_valid)begin
        case(counter)
        0:      receive[ 3: 0]<=in_syndrome;
        1:      receive[ 7: 4]<=in_syndrome;
        2:      receive[11: 8]<=in_syndrome;
        3:      receive[15:12]<=in_syndrome;
        4:      receive[19:16]<=in_syndrome;
        5:      receive[23:20]<=in_syndrome;
        //6:      receive[27:24]=4'hf;
        //7:      receive=x6;
        default:receive<=x6;
        endcase 
    end
    else begin
        receive<=IN_Divisor;
    end
end
///  control IP  /// 
always@(*)begin
    if(counter==6)
        IN_Dividend=28'h0ff_ffff;
    /*else if(omega_check&&sigma_check)
        IN_Dividend=28'h000_0000;*/
    else if(counter>=7)
        IN_Dividend=temp_IN_Divisor;
    else 
        IN_Dividend=28'hfff_ffff;
end
always@(*)begin
    if(counter==6)
        IN_Divisor=receive;
    /*else if(omega_check&&sigma_check)
        IN_Divisor=28'h000_0000;*/
    else if(counter>=7)
        IN_Divisor=temp_Remainder;
    else 
        IN_Divisor=28'hfff_ffff;
end



always@(posedge clk or negedge rst_n)begin //temp_IN_Divisor
    if(!rst_n)begin
        temp_IN_Divisor<=0;
    end
    else begin
        temp_IN_Divisor<=IN_Divisor;
    end
end


always@(posedge clk or negedge rst_n)begin //temp_OUT_Quotient
    if(!rst_n)begin
        temp_OUT_Quotient<=0;
    end
    else if(counter==6)begin
        temp_OUT_Quotient<={12'hfff,x6_OUT_Quotient};
    
    end
    else begin
        //$display("[Cycle %0t] temp_OUT_Quotient = %h (from %s)", $time,
        //temp_OUT_Quotient, (counter==6) ? "x6_OUT_Quotient" : "OUT_Quotient");

        temp_OUT_Quotient<={4'hf,second_OUT_Quotient[23:0]};//28bit
    end
end

always@(posedge clk or negedge rst_n)begin //temp_Remainder
    if(!rst_n)begin
        temp_Remainder<=0;
    end
    else if(counter==6)begin
        temp_Remainder<={8'hff,x6_Remainder};
    end
    else begin
        //$display("[Cycle %0t] temp_Remainder = %h (from %s)", $time,
        //temp_Remainder, (counter==6) ? "x6_Remainder" : "Remainder");
        temp_Remainder<={4'hf,second_Remainder[23:0]};//28bit
    end
end

always@(*)begin
    if(counter==6)begin
        q[5]=4'hf;
        q[4]=4'hf;
        q[3]=x6_OUT_Quotient[15:12];
        q[2]=x6_OUT_Quotient[11: 8];
        q[1]=x6_OUT_Quotient[ 7: 4];
        q[0]=x6_OUT_Quotient[ 3: 0];
    end
    else begin 
        q[5]=second_OUT_Quotient[23:20];
        q[4]=second_OUT_Quotient[19:16];
        q[3]=second_OUT_Quotient[15:12];
        q[2]=second_OUT_Quotient[11: 8];
        q[1]=second_OUT_Quotient[ 7: 4];
        q[0]=second_OUT_Quotient[ 3: 0];
    end
end
always@(*)begin
    if(counter==6)begin
        sigma_zero[5]=4'hf;
        sigma_zero[4]=4'hf;
        sigma_zero[3]=4'hf;
        sigma_zero[2]=4'hf;
        sigma_zero[1]=4'hf;
        sigma_zero[0]=4'hf;
    end
    else if(counter>=7)begin
        sigma_zero[5]=sigma_temp[5];
        sigma_zero[4]=sigma_temp[4];
        sigma_zero[3]=sigma_temp[3];
        sigma_zero[2]=sigma_temp[2];
        sigma_zero[1]=sigma_temp[1];
        sigma_zero[0]=sigma_temp[0];
    end
    else begin
        sigma_zero[5]=4'hf;
        sigma_zero[4]=4'hf;
        sigma_zero[3]=4'hf;
        sigma_zero[2]=4'hf;
        sigma_zero[1]=4'hf;
        sigma_zero[0]=4'hf;
    end
end

always@(*)begin
    if(counter==6)begin
        sigma[5]=4'hf;
        sigma[4]=4'hf;
        sigma[3]=4'hf;
        sigma[2]=4'hf;
        sigma[1]=4'hf;
        sigma[0]=4'h0;
    end
    else if(counter>=7)begin
        sigma[5]=sigma_reg[5];
        sigma[4]=sigma_reg[4];
        sigma[3]=sigma_reg[3];
        sigma[2]=sigma_reg[2];
        sigma[1]=sigma_reg[1];
        sigma[0]=sigma_reg[0];
    end
    else begin
        sigma[5]=4'hf;
        sigma[4]=4'hf;
        sigma[3]=4'hf;
        sigma[2]=4'hf;
        sigma[1]=4'hf;
        sigma[0]=4'h0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(int i=0;i<6;i=i+1)begin
            sigma_temp[i]<=4'hf;
        end
    end
    else begin
        sigma_temp[5]<=sigma[5];
        sigma_temp[4]<=sigma[4];
        sigma_temp[3]<=sigma[3];
        sigma_temp[2]<=sigma[2];
        sigma_temp[1]<=sigma[1];
        sigma_temp[0]<=sigma[0];
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(int i=0;i<6;i=i+1)begin
            sigma_reg[i]<=4'hf;
        end
    end
    else if(next_state==1||next_state==2)begin
        for(int i=0;i<6;i=i+1)begin
            sigma_reg[i]<=sigma_reg[i];
        end
    end
    else begin
        sigma_reg[5]<= get_alpha_index(
                        get_alpha_index(
                            get_alpha_index(
                                get_alpha_index(minus(q[5], sigma[0]), minus(q[4], sigma[1])),
                                get_alpha_index(minus(q[3], sigma[2]), minus(q[2], sigma[3]))
                            ),
                            get_alpha_index(minus(q[1], sigma[4]), minus(q[0], sigma[5]))
                        ),
                        sigma_zero[5]
                    );
        sigma_reg[4]<= get_alpha_index(
                                            get_alpha_index(
                                                get_alpha_index(minus(q[4], sigma[0]), minus(q[3], sigma[1])),
                                                get_alpha_index(minus(q[2], sigma[2]), minus(q[1], sigma[3]))),
                                            get_alpha_index(minus(q[0], q[4]), sigma_zero[4])
                                        );
        sigma_reg[3]<= get_alpha_index(
                            get_alpha_index(
                                get_alpha_index(minus(q[3], sigma[0]), minus(q[2], sigma[1])),
                                get_alpha_index(minus(q[1], sigma[2]), minus(q[0], sigma[3]))
                            ),
                            sigma_zero[3]
                        );
        sigma_reg[2]<= get_alpha_index(
                            get_alpha_index(
                                get_alpha_index(minus(q[2], sigma[0]), minus(q[1], sigma[1])),
                                minus(q[0], sigma[2])
                            ),
                            sigma_zero[2]
                        );  
        sigma_reg[1]<=get_alpha_index(
                        get_alpha_index(minus(q[1], sigma[0]), minus(q[0], sigma[1])),
                        sigma_zero[1]
                    );  
        sigma_reg[0]<= get_alpha_index(
                            minus(q[0], sigma[0]),
                            sigma_zero[0]
                        );
        
    end
end


///       output     /////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        out_valid<=1'b0;
    else if(next_state==1 || next_state==2 || next_state==3)
        out_valid<=1'b1;
    else 
        out_valid<=1'b0;
    
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        out_location<=0;
        for(int i=0;i<15;i=i+1)begin
            output_flag[i]<=0;
        end
    end
    else if (current_state==3)begin
        for(int i=0;i<15;i=i+1)begin
            output_flag[i]<=0;
        end
            out_location<=0;

    end
    else if(next_state==1 || next_state==2 || next_state==3)begin
        if (chein_check[0] == 1 && output_flag[0] == 0) begin
            out_location <= 0;
            output_flag[0] <= 1;
        end 
        else if (chein_check[1] == 1 && output_flag[1] == 0) begin
            out_location <= (1&&divide_1_quotient);
            output_flag[1] <= 1;
        end 
        else if (chein_check[2] == 1 && output_flag[2] == 0) begin
            out_location <= 2;
            output_flag[2] <= 1;
        end 
        else if (chein_check[3] == 1 && output_flag[3] == 0) begin
            out_location <= 3;
            output_flag[3] <= 1;
        end 
        else if (chein_check[4] == 1 && output_flag[4] == 0) begin
            out_location <= 4;
            output_flag[4] <= 1;
        end 
        else if (chein_check[5] == 1 && output_flag[5] == 0) begin
            out_location <= 5;
            output_flag[5] <= 1;
        end 
        else if (chein_check[6] == 1 && output_flag[6] == 0) begin
            out_location <= 6;
            output_flag[6] <= 1;
        end 
        else if (chein_check[7] == 1 && output_flag[7] == 0) begin
            out_location <= 7;
            output_flag[7] <= 1;
        end 
        else if (chein_check[8] == 1 && output_flag[8] == 0) begin
            out_location <= 8;
            output_flag[8] <= 1;
        end 
        else if (chein_check[9] == 1 && output_flag[9] == 0) begin
            out_location <= 9;
            output_flag[9] <= 1;
        end 
        else if (chein_check[10] == 1 && output_flag[10] == 0) begin
            out_location <= 10;
            output_flag[10] <= 1;
        end 
        else if (chein_check[11] == 1 && output_flag[11] == 0) begin
            out_location <= 11;
            output_flag[11] <= 1;
        end 
        else if (chein_check[12] == 1 && output_flag[12] == 0) begin
            out_location <= 12;
            output_flag[12] <= 1;
        end 
        else if (chein_check[13] == 1 && output_flag[13] == 0) begin
            out_location <= 13;
            output_flag[13] <= 1;
        end 
        else if (chein_check[14] == 1 && output_flag[14] == 0) begin
            out_location <= 14;
            output_flag[14] <= 1;
        end
        else begin
            out_location <= 15;
        end
    end
    else 
        out_location<=0;
end

///    function    ///
wire [3:0]alpha_power[0:15]; //[power] = [value]
assign alpha_power[0 ]=4'd1;
assign alpha_power[1 ]=4'd2;
assign alpha_power[2 ]=4'd4;
assign alpha_power[3 ]=4'd8;
assign alpha_power[4 ]=4'd3;
assign alpha_power[5 ]=4'd6;
assign alpha_power[6 ]=4'd12;
assign alpha_power[7 ]=4'd11;
assign alpha_power[8 ]=4'd5;
assign alpha_power[9 ]=4'd10;
assign alpha_power[10]=4'd7;
assign alpha_power[11]=4'd14;
assign alpha_power[12]=4'd15;
assign alpha_power[13]=4'd13;
assign alpha_power[14]=4'd9;
assign alpha_power[15]=4'd0;


function [3:0] get_alpha_index;
    input [3:0]a,b;
	reg [3:0]index;
    begin
        index=alpha_power[a]^alpha_power[b]; //xor
        case(index)
            4'd1:  get_alpha_index = 0;
            4'd2:  get_alpha_index = 1;
            4'd4:  get_alpha_index = 2;
            4'd8:  get_alpha_index = 3;
            4'd3:  get_alpha_index = 4;
            4'd6:  get_alpha_index = 5;
            4'd12: get_alpha_index = 6;
            4'd11: get_alpha_index = 7;
            4'd5:  get_alpha_index = 8;
            4'd10: get_alpha_index = 9;
            4'd7:  get_alpha_index = 10;
            4'd14: get_alpha_index = 11;
            4'd15: get_alpha_index = 12;
            4'd13: get_alpha_index = 13;
            4'd9:  get_alpha_index = 14;
            4'd0:  get_alpha_index = 15;
            default: get_alpha_index = 15;
        endcase
	end
endfunction



function [3:0]add;
    input [3:0]in_b;
    input [3:0]in_a;
    if(in_b>in_a)
        add=(in_a+15)-in_b;
    else 
        add=in_a-in_b;
endfunction

function [3:0]minus;
    input[3:0]in_c;
    input[3:0]in_d;
    if(in_c==15||in_d==15)
        minus=15;
    else if((in_c+in_d)>=15)  
        minus=(in_c+in_d)-15;
    else
        minus=(in_c+in_d);
endfunction

function [3:0]fifteen;
    input[3:0]in_e;
    input[3:0]in_f;
    if((in_e+in_f)>=15)
        fifteen=(in_e+in_f)-15;
    else
        fifteen=(in_e+in_f);
endfunction

endmodule


//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2023/10
//		Version		: v1.0
//   	File Name   : Division_IP.v
//   	Module Name : Division_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module Division_IP_Plus #(parameter IP_WIDTH = 6) (
    // Input signals
    IN_Dividend, IN_Divisor,
    // Output signals
    OUT_Quotient,
    Remainder
);

// ===============================================================
// Input & Output
// ===============================================================
input [IP_WIDTH*4-1:0]  IN_Dividend;
input [IP_WIDTH*4-1:0]  IN_Divisor;

output reg [IP_WIDTH*4-1:0] OUT_Quotient;
output reg [IP_WIDTH*4-1:0] Remainder;
reg [27:0]dividend_1;
reg [27:0]divisor_1;
reg [27:0]dividend_2;
reg [27:0]divisor_2;
reg [27:0]degree;
reg [6:0]degree_dividend;
reg [6:0]degree_div;
reg [27:0]q;
reg [2:0]dividend_count;
reg [2:0]divisor_count;
wire[27:0]x6;

/*
wire [3:0]data[0:6];
assign data[0]=IN_Dividend[27:24];
assign data[1]=IN_Dividend[23:20];
assign data[2]=IN_Dividend[19:16];
assign data[3]=IN_Dividend[15:12];
assign data[4]=IN_Dividend[11: 8];
assign data[5]=IN_Dividend[ 7: 4];
assign data[6]=IN_Dividend[ 3: 0];
*/
reg [3:0]a_data  [6:0];        //dividend
reg [3:0]a_data_1[6:0];        //dividend
reg [3:0]a_data_2[6:0];        //dividend
reg [3:0]a_data_3[6:0];        //dividend
reg [3:0]a_data_4[6:0];        //dividend
reg [3:0]a_data_5[6:0];        //dividend
reg [3:0]a_data_6[6:0];        //dividend

reg [3:0]b_data[6:0];          //divisor
reg [3:0]c_data[6:0];          //quotient

reg [3:0]d_data[6:0];          //reminder
integer i;
//===============================================================
//                             Design
//================================================================

always@(*)begin //Divisor
    if({b_data[6],b_data[5],b_data[4],b_data[3],b_data[2],b_data[1]}==24'b1111_1111_1111_1111_1111_1111)begin //6's 15 1's not 15
        degree_div[6] = 1; 
        degree_div[5] = 0;  
        degree_div[4] = 0;  
        degree_div[3] = 0;
        degree_div[2] = 0;
        degree_div[1] = 0;
        degree_div[0] = 0;
        divisor_count=6;
    end
    else if({b_data[6],b_data[5],b_data[4],b_data[3],b_data[2]}==20'b1111_1111_1111_1111_1111)begin//5's 1111
        degree_div[6] = 0; 
        degree_div[5] = 1;  
        degree_div[4] = 0;  
        degree_div[3] = 0;
        degree_div[2] = 0;
        degree_div[1] = 0;
        degree_div[0] = 0;
        divisor_count=5;
    end
    else if({b_data[6],b_data[5],b_data[4],b_data[3]}==16'b1111_1111_1111_1111)begin
        degree_div[6] = 0; 
        degree_div[5] = 0;  
        degree_div[4] = 1;  
        degree_div[3] = 0;
        degree_div[2] = 0;
        degree_div[1] = 0;
        degree_div[0] = 0;
        divisor_count=4;
    end
    else if({b_data[6],b_data[5],b_data[4]}== 12'b1111_1111_1111) begin
        degree_div[6] = 0; 
        degree_div[5] = 0;  
        degree_div[4] = 0;  
        degree_div[3] = 1;
        degree_div[2] = 0;
        degree_div[1] = 0;
        degree_div[0] = 0;
        divisor_count=3;
    end
    else if({b_data[6],b_data[5]} == 8'b1111_1111) begin
        degree_div[6] = 0; 
        degree_div[5] = 0;  
        degree_div[4] = 0;  
        degree_div[3] = 0;
        degree_div[2] = 1;
        degree_div[1] = 0;
        degree_div[0] = 0;
        divisor_count=2;
    end
    else if(b_data[6]== 4'b1111) begin
        degree_div[6] = 0; 
        degree_div[5] = 0;  
        degree_div[4] = 0;  
        degree_div[3] = 0;
        degree_div[2] = 0;
        degree_div[1] = 1;
        degree_div[0] = 0;
        divisor_count=1;
    end
    else begin 
       degree_div[6] = 0;
       degree_div[5] = 0;
       degree_div[4] = 0;
       degree_div[3] = 0;
       degree_div[2] = 0;
       degree_div[1] = 0;
       degree_div[0] = 1;
            divisor_count=0;
    end
end
/*
always@(*)begin
    case(degree_div)
    1:      divisor_1={IN_Divisor[3 : 0],IN_Divisor[27: 4]};
    3:      divisor_1={IN_Divisor[7 : 0],IN_Divisor[27: 8]};
    7:      divisor_1={IN_Divisor[11: 0],IN_Divisor[27:12]};
    15:     divisor_1={IN_Divisor[15: 0],IN_Divisor[27:16]};
    31:     divisor_1={IN_Divisor[19: 0],IN_Divisor[27:20]};
    63:     divisor_1={IN_Divisor[23: 0],IN_Divisor[27:24]};
    127:    divisor_1=IN_Divisor[27: 0]; 
    default:divisor_1=IN_Divisor[27: 0];     


    endcase
end
*/



always @(*) begin //a_data(IN_Dividend)
    case(IP_WIDTH)
        2: begin
            a_data[6] = 4'hf;
            a_data[5] = 4'hf;
            a_data[4] = 4'hf;
            a_data[3] = 4'hf;
            a_data[2] = 4'hf;
            a_data[1] = IN_Dividend[7:4];
            a_data[0] = IN_Dividend[3:0];
        end
        3: begin
            a_data[6] = 4'hf;
            a_data[5] = 4'hf;
            a_data[4] = 4'hf;
            a_data[3] = 4'hf;
            a_data[2] = IN_Dividend[11:8];
            a_data[1] = IN_Dividend[7:4];
            a_data[0] = IN_Dividend[3:0];
        end
        4: begin
            a_data[6] = 4'hf;
            a_data[5] = 4'hf;
            a_data[4] = 4'hf;
            a_data[3] = IN_Dividend[15:12];
            a_data[2] = IN_Dividend[11:8];
            a_data[1] = IN_Dividend[7:4];
            a_data[0] = IN_Dividend[3:0];
        end
        5: begin
            a_data[6] = 4'hf;
            a_data[5] = 4'hf;
            a_data[4] = IN_Dividend[19:16];
            a_data[3] = IN_Dividend[15:12];
            a_data[2] = IN_Dividend[11:8];
            a_data[1] = IN_Dividend[7:4];
            a_data[0] = IN_Dividend[3:0];
        end
        6: begin
            a_data[6] = 4'hf;
            a_data[5] = IN_Dividend[23:20];
            a_data[4] = IN_Dividend[19:16];
            a_data[3] = IN_Dividend[15:12];
            a_data[2] = IN_Dividend[11:8];
            a_data[1] = IN_Dividend[7:4];
            a_data[0] = IN_Dividend[3:0];
        end
        /*7: begin
            a_data[6] = IN_Dividend[27:24];
            a_data[5] = IN_Dividend[23:20];
            a_data[4] = IN_Dividend[19:16];
            a_data[3] = IN_Dividend[15:12];
            a_data[2] = IN_Dividend[11:8];
            a_data[1] = IN_Dividend[7:4];
            a_data[0] = IN_Dividend[3:0];
        end*/
        default: begin
            a_data[6] = IN_Dividend[27:24];
            a_data[5] = IN_Dividend[23:20];
            a_data[4] = IN_Dividend[19:16];
            a_data[3] = IN_Dividend[15:12];
            a_data[2] = IN_Dividend[11:8];
            a_data[1] = IN_Dividend[7:4];
            a_data[0] = IN_Dividend[3:0];
        end
    endcase
end
always @(*) begin //b_data(IN_Divisor)
    case(IP_WIDTH)
        2: begin
            b_data[6] = 4'hf;
            b_data[5] = 4'hf;
            b_data[4] = 4'hf;
            b_data[3] = 4'hf;
            b_data[2] = 4'hf;
            b_data[1] = IN_Divisor[7:4];
            b_data[0] = IN_Divisor[3:0];
        end
        3: begin
            b_data[6] = 4'hf;
            b_data[5] = 4'hf;
            b_data[4] = 4'hf;
            b_data[3] = 4'hf;
            b_data[2] = IN_Divisor[11:8];
            b_data[1] = IN_Divisor[7:4];
            b_data[0] = IN_Divisor[3:0];
        end
        4: begin
            b_data[6] = 4'hf;
            b_data[5] = 4'hf;
            b_data[4] = 4'hf;
            b_data[3] = IN_Divisor[15:12];
            b_data[2] = IN_Divisor[11:8];
            b_data[1] = IN_Divisor[7:4];
            b_data[0] = IN_Divisor[3:0];
        end
        5: begin
            b_data[6] = 4'hf;
            b_data[5] = 4'hf;
            b_data[4] = IN_Divisor[19:16];
            b_data[3] = IN_Divisor[15:12];
            b_data[2] = IN_Divisor[11:8];
            b_data[1] = IN_Divisor[7:4];
            b_data[0] = IN_Divisor[3:0];
        end
        6: begin
            b_data[6] = 4'hf;
            b_data[5] = IN_Divisor[23:20];
            b_data[4] = IN_Divisor[19:16];
            b_data[3] = IN_Divisor[15:12];
            b_data[2] = IN_Divisor[11:8];
            b_data[1] = IN_Divisor[7:4];
            b_data[0] = IN_Divisor[3:0];
        end
        /*7: begin
            b_data[6] = IN_Divisor[27:24];
            b_data[5] = IN_Divisor[23:20];
            b_data[4] = IN_Divisor[19:16];
            b_data[3] = IN_Divisor[15:12];
            b_data[2] = IN_Divisor[11:8];
            b_data[1] = IN_Divisor[7:4];
            b_data[0] = IN_Divisor[3:0];
        end*/
        default: begin
            b_data[6] = IN_Divisor[27:24];
            b_data[5] = IN_Divisor[23:20];
            b_data[4] = IN_Divisor[19:16];
            b_data[3] = IN_Divisor[15:12];
            b_data[2] = IN_Divisor[11:8];
            b_data[1] = IN_Divisor[7:4];
            b_data[0] = IN_Divisor[3:0];
        end
    endcase
end

always@(*)begin

    c_data[6]=4'hf;a_data_1[6]=4'hf;a_data_2[6]=4'hf;a_data_3[6]=4'hf;a_data_4[6]=4'hf;a_data_5[6]=4'hf;a_data_6[6]=4'hf;
    c_data[5]=4'hf;a_data_1[5]=4'hf;a_data_2[5]=4'hf;a_data_3[5]=4'hf;a_data_4[5]=4'hf;a_data_5[5]=4'hf;a_data_6[5]=4'hf;
    c_data[4]=4'hf;a_data_1[4]=4'hf;a_data_2[4]=4'hf;a_data_3[4]=4'hf;a_data_4[4]=4'hf;a_data_5[4]=4'hf;a_data_6[4]=4'hf;
    c_data[3]=4'hf;a_data_1[3]=4'hf;a_data_2[3]=4'hf;a_data_3[3]=4'hf;a_data_4[3]=4'hf;a_data_5[3]=4'hf;a_data_6[3]=4'hf;
    c_data[2]=4'hf;a_data_1[2]=4'hf;a_data_2[2]=4'hf;a_data_3[2]=4'hf;a_data_4[2]=4'hf;a_data_5[2]=4'hf;a_data_6[2]=4'hf;
    c_data[1]=4'hf;a_data_1[1]=4'hf;a_data_2[1]=4'hf;a_data_3[1]=4'hf;a_data_4[1]=4'hf;a_data_5[1]=4'hf;a_data_6[1]=4'hf;
    c_data[0]=4'hf;a_data_1[0]=4'hf;a_data_2[0]=4'hf;a_data_3[0]=4'hf;a_data_4[0]=4'hf;a_data_5[0]=4'hf;a_data_6[0]=4'hf;


    d_data[6]=4'hf;
    d_data[5]=4'hf;
    d_data[4]=4'hf;
    d_data[3]=4'hf;
    d_data[2]=4'hf;
    d_data[1]=4'hf;
    d_data[0]=4'hf;
    if (degree_div<degree_dividend)begin
        c_data[6]=4'hf;
        c_data[5]=4'hf;
        c_data[4]=4'hf;
        c_data[3]=4'hf;
        c_data[2]=4'hf;
        c_data[1]=4'hf;
        c_data[0]=4'hf;
    end
    else

    case(degree_div)
    /*7'b1000000:begin//6's ffffff
        if(a_data[6]==15)
            c_data[6]= 4'hf;
        else
            c_data[6]=add(b_data[0], a_data[6]);
        a_data_1[6]=a_data[5];
        a_data_1[5]=a_data[4];
        a_data_1[4]=a_data[3];
        a_data_1[3]=a_data[2];
        a_data_1[2]=a_data[1];
        a_data_1[1]=a_data[0];
        a_data_1[0]=4'hf;
        //--------- split --------//
        if(a_data_1[6]==15)
            c_data[5]= 4'hf;
        else 
            c_data[5]=add(b_data[0],a_data_1[6]);

        a_data_2[6]=a_data_1[5];
        a_data_2[5]=a_data_1[4];
        a_data_2[4]=a_data_1[3];
        a_data_2[3]=a_data_1[2];
        a_data_2[2]=a_data_1[1];
        a_data_2[1]=4'hf;
        a_data_2[0]=4'hf;
        //--------- split --------//
        if(a_data_2[6]==15)
            c_data[4]= 4'hf;
        else 
            c_data[4]=add(b_data[0],a_data_2[6]);
        a_data_3[6]=a_data_2[5];
        a_data_3[5]=a_data_2[4];
        a_data_3[4]=a_data_2[3];
        a_data_3[3]=a_data_2[2];
        a_data_3[2]=4'hf;
        a_data_3[1]=4'hf;
        a_data_3[0]=4'hf;
        //--------- split --------//
        if(a_data_3[6]==15)
            c_data[3]= 4'hf;
        else 
            c_data[3]=add(b_data[0],a_data_3[6]);
        a_data_4[6]=a_data_3[5];
        a_data_4[5]=a_data_3[4];
        a_data_4[4]=a_data_3[3];
        a_data_4[3]=4'hf;
        a_data_4[2]=4'hf;
        a_data_4[1]=4'hf;
        a_data_4[0]=4'hf;
        //--------- split --------//
        if(a_data_4[6]==15)
            c_data[2]= 4'hf;
        else 
            c_data[2]=add(b_data[0],a_data_4[6]);
        a_data_5[6]=a_data_4[5];
        a_data_5[5]=a_data_4[4];
        a_data_5[4]=4'hf;
        a_data_5[3]=4'hf;
        a_data_5[2]=4'hf;
        a_data_5[1]=4'hf;
        a_data_5[0]=4'hf;
        if(a_data_5[6]==15)
            c_data[1]= 4'hf;
        else 
            c_data[1]=add(b_data[0],a_data_5[6]);
        a_data_6[6]=a_data_5[5];
        a_data_6[5]=4'hf;
        a_data_6[4]=4'hf;
        a_data_6[3]=4'hf;
        a_data_6[2]=4'hf;
        a_data_6[1]=4'hf;
        a_data_6[0]=4'hf;
        if(a_data_6[6]==15)begin
            c_data[0]= 4'hf;

            d_data[6]=4'hf;
            d_data[5]=4'hf;
            d_data[4]=4'hf;
            d_data[3]=4'hf;
            d_data[2]=4'hf;
            d_data[1]=4'hf;
            d_data[0]=4'hf;
        end
        else begin
            c_data[0]=add(b_data[0],a_data_6[6]);

            d_data[6]=get_alpha_index(4'hf                      ,a_data_6[5]);
            d_data[5]=get_alpha_index(4'hf                      ,a_data_6[4]);
            d_data[4]=get_alpha_index(4'hf                      ,a_data_6[3]);
            d_data[3]=get_alpha_index(4'hf                      ,a_data_6[2]);
            d_data[2]=get_alpha_index(4'hf                      ,a_data_6[1]);
            d_data[1]=get_alpha_index(4'hf                      ,a_data_6[0]);
            d_data[0]=get_alpha_index(check(b_data[0],c_data[0]),a_data_6[6]);

        end
    end*/
    7'b0100000:begin
    if(a_data[6] == 15)begin
        c_data[5] = 4'hf;
        a_data_1[6] = a_data[5];   
        a_data_1[5] = a_data[4];   
        a_data_1[4] = a_data[3];
        a_data_1[3] = a_data[2];
        a_data_1[2] = a_data[1];
        a_data_1[1] = a_data[0];
        a_data_1[0] = 4'hf;
    end
    else begin
        c_data[5] = add(b_data[1], a_data[6]);
        if(b_data[0] == 15)
            a_data_1[6] = get_alpha_index(a_data[5], b_data[0]);
        else
            a_data_1[6] = get_alpha_index(minus(b_data[0], c_data[5]), a_data[5]);
        a_data_1[5] = a_data[4];   
        a_data_1[4] = a_data[3];
        a_data_1[3] = a_data[2];
        a_data_1[2] = a_data[1];
        a_data_1[1] = a_data[0];
        a_data_1[0] = 4'hf;
    end
    //--------- split --------//
    if(a_data_1[6] == 15)begin
        c_data[4] = 4'hf;
        a_data_2[6] =a_data_1[5];
        a_data_2[5] =a_data_1[4];
        a_data_2[4] =a_data_1[3];
        a_data_2[3] =a_data_1[2];
        a_data_2[2] =a_data_1[1];
        a_data_2[1] =a_data_1[0];
        a_data_2[0] =4'hf;
    end
    else begin
        c_data[4] = add(b_data[1], a_data_1[6]);

        if(b_data[0] == 15)
            a_data_2[6] = get_alpha_index(a_data_1[5], b_data[0]);
        else
            a_data_2[6] = get_alpha_index(minus(b_data[0], c_data[4]), a_data_1[5]);
        a_data_2[5] = a_data_1[4];
        a_data_2[4] = a_data_1[3];
        a_data_2[3] = a_data_1[2];
        a_data_2[2] = a_data_1[1];
        a_data_2[1] = 4'hf;
        a_data_2[0] = 4'hf;
    end
    //--------- split --------//
    if(a_data_2[6] == 15)begin
        c_data[3] = 4'hf;
        a_data_3[6] =a_data_2[5];
        a_data_3[5] =a_data_2[4];
        a_data_3[4] =a_data_2[3];
        a_data_3[3] =a_data_2[2];
        a_data_3[2] =a_data_2[1];
        a_data_3[1] =a_data_2[0];
        a_data_3[0] =4'hf;
    end
    else begin
        c_data[3] = add(b_data[1], a_data_2[6]);

        if(b_data[0] == 15)
            a_data_3[6] = get_alpha_index(a_data_2[5], b_data[0]);
        else
            a_data_3[6] = get_alpha_index(minus(b_data[0], c_data[3]),a_data_2[5]);
        a_data_3[5] =  a_data_2[4];
        a_data_3[4] =  a_data_2[3];
        a_data_3[3] =  a_data_2[2];
        a_data_3[2] =  4'hf;
        a_data_3[1] =  4'hf;
        a_data_3[0] =  4'hf;
    end
    //--------- split --------//
    if(a_data_3[6] == 15)begin
        c_data[2] = 4'hf;
        a_data_4[6] =a_data_3[5];
        a_data_4[5] =a_data_3[4];
        a_data_4[4] =a_data_3[3];
        a_data_4[3] =a_data_3[2];
        a_data_4[2] =a_data_3[1];
        a_data_4[1] =a_data_3[0];
        a_data_4[0] =4'hf;
    end
    else begin
        c_data[2] = add(b_data[1], a_data_3[6]);
        if(b_data[0] == 15)
            a_data_4[6] = get_alpha_index(a_data_3[5], b_data[0]);
        else
            a_data_4[6] = get_alpha_index(minus(b_data[0], c_data[2]),a_data_3[5]);
        a_data_4[5] =  a_data_3[4];
        a_data_4[4] =  a_data_3[3];
        a_data_4[3] =  4'hf;
        a_data_4[2] =  4'hf;
        a_data_4[1] =  4'hf;
        a_data_4[0] =  4'hf;
    end
    //--------- split --------//
    if(a_data_4[6] == 15)begin
        c_data[1] = 4'hf;
        a_data_5[6] =a_data_4[5];
        a_data_5[5] =a_data_4[4];
        a_data_5[4] =a_data_4[3];
        a_data_5[3] =a_data_4[2];
        a_data_5[2] =a_data_4[1];
        a_data_5[1] =a_data_4[0];
        a_data_5[0] =4'hf;
    end
    else begin
        c_data[1] = add(b_data[1], a_data_4[6]);
        if(b_data[0] == 15)
            a_data_5[6] = get_alpha_index(a_data_4[5], b_data[0]);
        else
            a_data_5[6] = get_alpha_index(minus(b_data[0], c_data[1]), a_data_4[5]);
        a_data_5[5] = a_data_4[4];
        a_data_5[4] = 4'hf;
        a_data_5[3] = 4'hf;
        a_data_5[2] = 4'hf;
        a_data_5[1] = 4'hf;
        a_data_5[0] = 4'hf;
    end
    //--------- split --------//
    if(a_data_5[6] == 15)begin
        c_data[0] = 4'hf;
        d_data[6]=4'hf;
        d_data[5]=4'hf;
        d_data[4]=4'hf;
        d_data[3]=4'hf;
        d_data[2]=4'hf;
        d_data[1]=4'hf;
        d_data[0]=a_data_5[5];

    end
    else begin
        c_data[0] = add(b_data[1], a_data_5[6]);
        /*
        d_data[6]=get_alpha_index(minus(b_data[1],c_data[0]),a_data_5[6]);
        d_data[5]=get_alpha_index(minus(b_data[0],c_data[0]),a_data_5[5]);
        d_data[4]=get_alpha_index(4'hf                      ,a_data_5[4]);
        d_data[3]=get_alpha_index(4'hf                      ,a_data_5[3]);
        d_data[2]=get_alpha_index(4'hf                      ,a_data_5[2]);
        d_data[1]=get_alpha_index(4'hf                      ,a_data_5[1]);
        d_data[0]=get_alpha_index(4'hf                      ,a_data_5[0]);
        */
        d_data[6]=get_alpha_index(4'hf                      ,a_data_5[4]);
        d_data[5]=get_alpha_index(4'hf                      ,a_data_5[3]);
        d_data[4]=get_alpha_index(4'hf                      ,a_data_5[2]);
        d_data[3]=get_alpha_index(4'hf                      ,a_data_5[1]);
        d_data[2]=get_alpha_index(4'hf                      ,a_data_5[0]);
        d_data[1]=get_alpha_index(check(b_data[1],c_data[0]),a_data_5[6]);
        d_data[0]=get_alpha_index(check(b_data[0],c_data[0]),a_data_5[5]);
    end

    end
    7'b0010000:begin
    if(a_data[6] == 15) begin
        c_data[4] = 4'hf;
        a_data_1[6] =a_data[5];
        a_data_1[5] =a_data[4];
        a_data_1[4] =a_data[3];
        a_data_1[3] =a_data[2];
        a_data_1[2] =a_data[1];
        a_data_1[1] =a_data[0];
        a_data_1[0] =4'hf;
    end
    else begin
        c_data[4] = add(b_data[2], a_data[6]);
        if(b_data[1] == 15)
            a_data_1[6] = get_alpha_index(a_data[5], b_data[1]);
        else
            a_data_1[6] = get_alpha_index(minus(b_data[1], c_data[4]), a_data[5]);

        if(b_data[0] == 15)
            a_data_1[5] = get_alpha_index(a_data[4], b_data[0]);
        else
            a_data_1[5] = get_alpha_index(minus(b_data[0], c_data[4]), a_data[4]);
        a_data_1[4] = a_data[3];
        a_data_1[3] = a_data[2];
        a_data_1[2] = a_data[1];
        a_data_1[1] = a_data[0];
        a_data_1[0] = 4'hf;
    end
    //--------- split --------//
    if(a_data_1[6] == 15)begin
        c_data[3] = 4'hf;
        a_data_2[6] =a_data_1[5];
        a_data_2[5] =a_data_1[4];
        a_data_2[4] =a_data_1[3];
        a_data_2[3] =a_data_1[2];
        a_data_2[2] =a_data_1[1];
        a_data_2[1] =a_data_1[0];
        a_data_2[0] =4'hf;
    end
    else begin
        c_data[3] = add(b_data[2], a_data_1[6]);

        if(b_data[1] == 15)
            a_data_2[6] = get_alpha_index(a_data_1[5], b_data[1]);
        else
            a_data_2[6] = get_alpha_index(minus(b_data[1], c_data[3]), a_data_1[5]);

        if(b_data[0] == 15)
            a_data_2[5] = get_alpha_index(a_data_1[4], b_data[0]);
        else
            a_data_2[5] = get_alpha_index(minus(b_data[0], c_data[3]), a_data_1[4]);

        a_data_2[4] = a_data_1[3];
        a_data_2[3] = a_data_1[2];
        a_data_2[2] = a_data_1[1];
        a_data_2[1] = 4'hf;
        a_data_2[0] = 4'hf;
    end
    //--------- split --------//
    if(a_data_2[6] == 15) begin
        c_data[2] = 4'hf;
        a_data_3[6] =a_data_2[5];
        a_data_3[5] =a_data_2[4];
        a_data_3[4] =a_data_2[3];
        a_data_3[3] =a_data_2[2];
        a_data_3[2] =a_data_2[1];
        a_data_3[1] =a_data_2[0];
        a_data_3[0] =4'hf;
    end
    else begin
        c_data[2] = add(b_data[2], a_data_2[6]);

        if(b_data[1] == 15)
            a_data_3[6] = get_alpha_index(a_data_2[5], b_data[1]);
        else
            a_data_3[6] = get_alpha_index(minus(b_data[1], c_data[2]), a_data_2[5]);

        if(b_data[0] == 15)
            a_data_3[5] = get_alpha_index(a_data_2[4], b_data[0]);
        else
            a_data_3[5] = get_alpha_index(minus(b_data[0], c_data[2]), a_data_2[4]);

        a_data_3[4] = a_data_2[3];
        a_data_3[3] = a_data_2[2];
        a_data_3[2] = 4'hf;
        a_data_3[1] = 4'hf;
        a_data_3[0] = 4'hf;
    end
    //--------- split --------//
    if(a_data_3[6] == 15) begin
        c_data[1] = 4'hf;
        a_data_4[6] =a_data_3[5];
        a_data_4[5] =a_data_3[4];
        a_data_4[4] =a_data_3[3];
        a_data_4[3] =a_data_3[2];
        a_data_4[2] =a_data_3[1];
        a_data_4[1] =a_data_3[0];
        a_data_4[0] =4'hf;
    end
    else begin
        c_data[1] = add(b_data[2], a_data_3[6]);

        if(b_data[1] == 15)
            a_data_4[6] = get_alpha_index(a_data_3[5], b_data[1]);
        else
            a_data_4[6] = get_alpha_index(minus(b_data[1], c_data[1]), a_data_3[5]);

        if(b_data[0] == 15)
            a_data_4[5] = get_alpha_index(a_data_3[4], b_data[0]);
        else
            a_data_4[5] = get_alpha_index(minus(b_data[0], c_data[1]), a_data_3[4]);
        a_data_4[4] = a_data_3[3];
        a_data_4[3] = 4'hf;
        a_data_4[2] = 4'hf;
        a_data_4[1] = 4'hf;
        a_data_4[0] = 4'hf;
    end
    //--------- split --------//
    if(a_data_4[6] == 15)begin
        c_data[0] = 4'hf;
            d_data[6]=4'hf;
            d_data[5]=4'hf;
            d_data[4]=4'hf;
            d_data[3]=4'hf;
            d_data[2]=4'hf;
            d_data[1]=a_data_4[5];
            d_data[0]=a_data_4[4];
    end
    else begin
        c_data[0] = add(b_data[2], a_data_4[6]);
        /*d_data[6]=get_alpha_index(minus(b_data[2],c_data[0]),a_data_4[6]);
        d_data[5]=get_alpha_index(minus(b_data[1],c_data[0]),a_data_4[5]);
        d_data[4]=get_alpha_index(minus(b_data[0],c_data[0]),a_data_4[4]);
        d_data[3]=get_alpha_index(4'hf                      ,a_data_4[3]);
        d_data[2]=get_alpha_index(4'hf                      ,a_data_4[2]);
        d_data[1]=get_alpha_index(4'hf                      ,a_data_4[1]);
        d_data[0]=get_alpha_index(4'hf                      ,a_data_4[0]);
                */

        d_data[6]=get_alpha_index(4'hf                      ,a_data_4[3]);
        d_data[5]=get_alpha_index(4'hf                      ,a_data_4[2]);
        d_data[4]=get_alpha_index(4'hf                      ,a_data_4[1]);
        d_data[3]=get_alpha_index(4'hf                      ,a_data_4[0]);
        d_data[2]=get_alpha_index(check(b_data[2],c_data[0]),a_data_4[6]);
        d_data[1]=get_alpha_index(check(b_data[1],c_data[0]),a_data_4[5]);
        d_data[0]=get_alpha_index(check(b_data[0],c_data[0]),a_data_4[4]);
    end




    end
    7'b0001000:begin //modify
        if(a_data[6] == 15)begin
            c_data[3] = 4'hf;
            a_data_1[6]=a_data[5];
            a_data_1[5]=a_data[4];
            a_data_1[4]=a_data[3];
            a_data_1[3]=a_data[2];
            a_data_1[2]=a_data[1];
            a_data_1[1]=a_data[0];
            a_data_1[0]=4'hf;
        end
        else begin 
            c_data[3] = add(b_data[3], a_data[6]);

            if(b_data[2] == 15)
                a_data_1[6] = get_alpha_index(a_data[5], b_data[2]);
            else
                a_data_1[6] = get_alpha_index(minus(b_data[2], c_data[3]), a_data[5]);

            if(b_data[1] == 15)
                a_data_1[5] = get_alpha_index(a_data[4], b_data[1]);
            else
                a_data_1[5] = get_alpha_index(minus(b_data[1], c_data[3]), a_data[4]);

            if(b_data[0] == 15)
                a_data_1[4] = get_alpha_index(a_data[3], b_data[0]);
            else
                a_data_1[4] = get_alpha_index(minus(b_data[0], c_data[3]), a_data[3]);

            a_data_1[3] = a_data[2];
            a_data_1[2] = a_data[1];
            a_data_1[1] = a_data[0];
            a_data_1[0] = 4'hf;
        end
     //--------- split --------//
        if(a_data_1[6] == 15)begin
            c_data[2] = 4'hf;
            
            a_data_2[6]=a_data_1[5];
            a_data_2[5]=a_data_1[4];
            a_data_2[4]=a_data_1[3];
            a_data_2[3]=a_data_1[2];
            a_data_2[2]=a_data_1[1];
            a_data_2[1]=a_data_1[0];
            a_data_2[0]=4'hf;
        end
        else begin
            c_data[2] = add(b_data[3], a_data_1[6]);
 
            if(b_data[2] == 15)
                a_data_2[6] = get_alpha_index(a_data_1[5], b_data[2]);
            else
                a_data_2[6] = get_alpha_index(minus(b_data[2], c_data[2]), a_data_1[5]);
    
            if(b_data[1] == 15)
                a_data_2[5] = get_alpha_index(a_data_1[4], b_data[1]);
            else
                a_data_2[5] = get_alpha_index(minus(b_data[1], c_data[2]), a_data_1[4]);
    
            if(b_data[0] == 15)
                a_data_2[4] = get_alpha_index(a_data_1[3], b_data[0]);
            else
                a_data_2[4] = get_alpha_index(minus(b_data[0], c_data[2]), a_data_1[3]);
    
            a_data_2[3] = a_data_1[2];
            a_data_2[2] = a_data_1[1];
            a_data_2[1] = 4'hf;
            a_data_2[0] = 4'hf;
        end
     //--------- split --------//
        if(a_data_2[6] == 15)begin
            c_data[1] = 4'hf;
            a_data_3[6]=a_data_2[5];
            a_data_3[5]=a_data_2[4];
            a_data_3[4]=a_data_2[3];
            a_data_3[3]=a_data_2[2];
            a_data_3[2]=a_data_2[1];
            a_data_3[1]=a_data_2[0];
            a_data_3[0]=4'hf;
        end
        else begin
            c_data[1] = add(b_data[3], a_data_2[6]);

            if(b_data[2] == 15)
                a_data_3[6] = get_alpha_index(a_data_2[5], b_data[2]);
            else
                a_data_3[6] = get_alpha_index(minus(b_data[2], c_data[1]), a_data_2[5]);
    
            if(b_data[1] == 15)
                a_data_3[5] = get_alpha_index(a_data_2[4], b_data[1]);
            else
                a_data_3[5] = get_alpha_index(minus(b_data[1], c_data[1]), a_data_2[4]);
    
            if(b_data[0] == 15)
                a_data_3[4] = get_alpha_index(a_data_2[3], b_data[0]);
            else
                a_data_3[4] = get_alpha_index(minus(b_data[0], c_data[1]), a_data_2[3]);
    
            a_data_3[3] = a_data_2[2];
            a_data_3[2] = 4'hf;
            a_data_3[1] = 4'hf;
            a_data_3[0] = 4'hf;
        end
        //--------- split --------//
        if(a_data_3[6] == 15)begin
            c_data[0] = 4'hf;

            d_data[6]=4'hf;
            d_data[5]=4'hf;
            d_data[4]=4'hf;
            d_data[3]=4'hf;
            d_data[2]=a_data_3[5];
            d_data[1]=a_data_3[4];
            d_data[0]=a_data_3[3];
        end
        else begin
            c_data[0] = add(b_data[3], a_data_3[6]);

            d_data[6]=get_alpha_index(4'hf                      ,a_data_3[2]);
            d_data[5]=get_alpha_index(4'hf                      ,a_data_3[1]);
            d_data[4]=get_alpha_index(4'hf                      ,a_data_3[0]);
            d_data[3]=get_alpha_index(check(b_data[3],c_data[0]),a_data_3[6]);
            d_data[2]=get_alpha_index(check(b_data[2],c_data[0]),a_data_3[5]);
            d_data[1]=get_alpha_index(check(b_data[1],c_data[0]),a_data_3[4]);
            d_data[0]=get_alpha_index(check(b_data[0],c_data[0]),a_data_3[3]);
        end











    end
    7'b0000100:begin
        if(a_data[6]==15) begin
            c_data[2]=4'hf;
            a_data_1[6] =a_data[5];
            a_data_1[5] =a_data[4];
            a_data_1[4] =a_data[3];
            a_data_1[3] =a_data[2];
            a_data_1[2] =a_data[1];
            a_data_1[1] =a_data[0];
            a_data_1[0] =4'hf;
        end
        else begin
            c_data[2]=add(b_data[4],a_data[6]);
    
            if(b_data[3]==15)
                a_data_1[6]=get_alpha_index(a_data[5],b_data[3]);
            else 
                a_data_1[6]=get_alpha_index(minus(b_data[3],c_data[2]),a_data[5]);
            if(b_data[2]==15)
                a_data_1[5]=get_alpha_index(a_data[4],b_data[2]);
            else 
                a_data_1[5]=get_alpha_index(minus(b_data[2],c_data[2]),a_data[4]);
            if(b_data[1]==15)
                a_data_1[4]=get_alpha_index(a_data[3],b_data[1]);
            else 
                a_data_1[4]=get_alpha_index(minus(b_data[1],c_data[2]),a_data[3]);
            if(b_data[0]==15)
                a_data_1[3]=get_alpha_index(a_data[2],b_data[0]);
            else 
                a_data_1[3]=get_alpha_index(minus(b_data[0],c_data[2]),a_data[2]);
            a_data_1[2]=a_data[1];
            a_data_1[1]=a_data[0];
            a_data_1[0]=4'hf;
        end
        //-----split -----//
        if(a_data_1[6]==15) begin
            c_data[1]=4'hf;
            a_data_2[6] =a_data_1[5];
            a_data_2[5] =a_data_1[4];
            a_data_2[4] =a_data_1[3];
            a_data_2[3] =a_data_1[2];
            a_data_2[2] =a_data_1[1];
            a_data_2[1] =a_data_1[0];
            a_data_2[0] =4'hf;

        end
        else begin 
            c_data[1]=add(b_data[4],a_data_1[6]);
            if(b_data[3]==15)
                a_data_2[6]=get_alpha_index(a_data_1[5],b_data[3]);
            else 
                a_data_2[6]=get_alpha_index(minus(b_data[3],c_data[1]),a_data_1[5]);
            if(b_data[2]==15)
                a_data_2[5]=get_alpha_index(a_data_1[4],b_data[2]);
            else 
                a_data_2[5]=get_alpha_index(minus(b_data[2],c_data[1]),a_data_1[4]);
            if(b_data[1]==15)
                a_data_2[4]=get_alpha_index(a_data_1[3],b_data[1]);
            else 
                a_data_2[4]=get_alpha_index(minus(b_data[1],c_data[1]),a_data_1[3]);
            if(b_data[0]==15)
                a_data_2[3]=get_alpha_index(a_data_1[2],b_data[0]);
            else 
                a_data_2[3]=get_alpha_index(minus(b_data[0],c_data[1]),a_data_1[2]);
            a_data_2[2]=a_data_1[1];
            a_data_2[1]=4'hf;
            a_data_2[0]=4'hf;
        end
        //--------- split --------//
        if(a_data_2[6]==15)begin
            c_data[0]=4'hf;
            
            d_data[6]=4'hf;
            d_data[5]=4'hf;
            d_data[4]=4'hf;
            d_data[3]=a_data_2[5];
            d_data[2]=a_data_2[4];
            d_data[1]=a_data_2[3];
            d_data[0]=a_data_2[2];
        end
        else begin
            c_data[0]=add(b_data[4],a_data_2[6]);
        
            d_data[6]=get_alpha_index(4'hf                      ,a_data_2[1]);
            d_data[5]=get_alpha_index(4'hf                      ,a_data_2[0]);
            d_data[4]=get_alpha_index(check(b_data[4],c_data[0]),a_data_2[6]);
            d_data[3]=get_alpha_index(check(b_data[3],c_data[0]),a_data_2[5]);
            d_data[2]=get_alpha_index(check(b_data[2],c_data[0]),a_data_2[4]);//....//
            d_data[1]=get_alpha_index(check(b_data[1],c_data[0]),a_data_2[3]);
            d_data[0]=get_alpha_index(check(b_data[0],c_data[0]),a_data_2[2]);
        
        end



    end
    7'b0000010:begin
        if(a_data[6]==15) begin
            c_data[1]=4'hf;
            a_data_1[6] =a_data[5];
            a_data_1[5] =a_data[4];
            a_data_1[4] =a_data[3];
            a_data_1[3] =a_data[2];
            a_data_1[2] =a_data[1];
            a_data_1[1] =a_data[0];
            a_data_1[0] =4'hf;
        end
        else begin
            c_data[1]=add(b_data[5],a_data[6]);
        
            if(b_data[4]==15)
                a_data_1[6]=get_alpha_index(a_data[5],b_data[4]);
            else begin
                a_data_1[6]=get_alpha_index( minus(b_data[4],c_data[1]) , a_data[5]);
            end
            if(b_data[3]==15)
                a_data_1[5]=get_alpha_index(a_data[4],b_data[3]);
            else begin
                a_data_1[5]=get_alpha_index(minus(b_data[3],c_data[1]) , a_data[4]);
            end
            if(b_data[2]==15)
                a_data_1[4]=get_alpha_index(a_data[3],b_data[2]);
            else begin
                a_data_1[4]=get_alpha_index(minus(b_data[2],c_data[1]) , a_data[3]);
            end
            if(b_data[1]==15)
                a_data_1[3]=get_alpha_index(a_data[2],b_data[1]);
            else begin
                a_data_1[3]=get_alpha_index(minus(b_data[1],c_data[1]) , a_data[2]);
            end       
            if(b_data[0]==15)
                a_data_1[2]=get_alpha_index(a_data[1],b_data[0]);
            else begin
                a_data_1[2]=get_alpha_index(minus(b_data[0],c_data[1]) , a_data[1]);
            end
            a_data_1[1]=a_data[0];
            a_data_1[0]=4'hf;
        end
        //--------- split --------//
        if(a_data_1[6]==15)begin
            c_data[0]=4'hf;

            d_data[6]=4'hf;
            d_data[5]=4'hf;
            d_data[4]=a_data_1[5];
            d_data[3]=a_data_1[4];
            d_data[2]=a_data_1[3];
            d_data[1]=a_data_1[2];
            d_data[0]=a_data_1[1];
        end
        else begin
            c_data[0]=add(b_data[5],a_data_1[6]);

            d_data[6]=get_alpha_index(4'hf                      ,a_data_1[0]);
            d_data[5]=get_alpha_index(check(b_data[5],c_data[0]),a_data_1[6]);
            d_data[4]=get_alpha_index(check(b_data[4],c_data[0]),a_data_1[5]);
            d_data[3]=get_alpha_index(check(b_data[3],c_data[0]),a_data_1[4]);
            d_data[2]=get_alpha_index(check(b_data[2],c_data[0]),a_data_1[3]);
            d_data[1]=get_alpha_index(check(b_data[1],c_data[0]),a_data_1[2]);
            d_data[0]=get_alpha_index(check(b_data[0],c_data[0]),a_data_1[1]);
        end





    end
    7'b0000001:begin//
        if(a_data[6]==15)begin
            c_data[6]=4'hf;
            c_data[5]=4'hf;
            c_data[4]=4'hf;
            c_data[3]=4'hf;
            c_data[2]=4'hf;
            c_data[1]=4'hf;
            c_data[0]=4'hf;

            d_data[6]=4'hf;
            d_data[5]=a_data[5];
            d_data[4]=a_data[4];
            d_data[3]=a_data[3];
            d_data[2]=a_data[2];
            d_data[1]=a_data[1];
            d_data[0]=a_data[0];
        end
        else begin
            
            c_data[0]=add(b_data[6],a_data[6]);

            d_data[6]=get_alpha_index(check(b_data[6],c_data[0]),a_data[6]);
            d_data[5]=get_alpha_index(check(b_data[5],c_data[0]),a_data[5]);
            d_data[4]=get_alpha_index(check(b_data[4],c_data[0]),a_data[4]);
            d_data[3]=get_alpha_index(check(b_data[3],c_data[0]),a_data[3]);
            d_data[2]=get_alpha_index(check(b_data[2],c_data[0]),a_data[2]);
            d_data[1]=get_alpha_index(check(b_data[1],c_data[0]),a_data[1]);
            d_data[0]=get_alpha_index(check(b_data[0],c_data[0]),a_data[0]);
        end
    end
    default:begin
            c_data[6]=4'hf;
            c_data[5]=4'hf;
            c_data[4]=4'hf;
            c_data[3]=4'hf;
            c_data[2]=4'hf;
            c_data[1]=4'hf;
            c_data[0]=4'hf;
    end
    endcase
end




wire [3:0]alpha_power[0:15]; //[power] = [value]
assign alpha_power[0 ]=4'd1;
assign alpha_power[1 ]=4'd2;
assign alpha_power[2 ]=4'd4;
assign alpha_power[3 ]=4'd8;
assign alpha_power[4 ]=4'd3;
assign alpha_power[5 ]=4'd6;
assign alpha_power[6 ]=4'd12;
assign alpha_power[7 ]=4'd11;
assign alpha_power[8 ]=4'd5;
assign alpha_power[9 ]=4'd10;
assign alpha_power[10]=4'd7;
assign alpha_power[11]=4'd14;
assign alpha_power[12]=4'd15;
assign alpha_power[13]=4'd13;
assign alpha_power[14]=4'd9;
assign alpha_power[15]=4'd0;


function [3:0] get_alpha_index;
    input [3:0]a,b;
	reg [3:0]index;
    begin
        index=alpha_power[a]^alpha_power[b]; //xor
        case(index)
            4'd1:  get_alpha_index = 0;
            4'd2:  get_alpha_index = 1;
            4'd4:  get_alpha_index = 2;
            4'd8:  get_alpha_index = 3;
            4'd3:  get_alpha_index = 4;
            4'd6:  get_alpha_index = 5;
            4'd12: get_alpha_index = 6;
            4'd11: get_alpha_index = 7;
            4'd5:  get_alpha_index = 8;
            4'd10: get_alpha_index = 9;
            4'd7:  get_alpha_index = 10;
            4'd14: get_alpha_index = 11;
            4'd15: get_alpha_index = 12;
            4'd13: get_alpha_index = 13;
            4'd9:  get_alpha_index = 14;
            4'd0:  get_alpha_index = 15;
            default: get_alpha_index = 15;
        endcase
	end
endfunction

function [3:0]check;
    input[3:0]in_e;
    input[3:0]in_f;
    if(in_e==15)
        check=15;
    else if((in_e+in_f)>=15)
        check=(in_e+in_f)-15;
    else
        check=(in_e+in_f);
endfunction


function [3:0]add;
    input [3:0]in_b;
    input [3:0]in_a;
    if(in_b>in_a)
        add=(in_a+15)-in_b;
    else 
        add=in_a-in_b;
endfunction

function [3:0]minus;
    input[3:0]in_c;
    input[3:0]in_d;
    if((in_c+in_d)>=15)
        minus=(in_c+in_d)-15;
    else
        minus=(in_c+in_d);
endfunction

always@(*)begin
    OUT_Quotient={c_data[5],c_data[4],c_data[3],c_data[2],c_data[1],c_data[0]};
    
end
always@(*)begin
    Remainder={d_data[5],d_data[4],d_data[3],d_data[2],d_data[1],d_data[0]};
end

endmodule
///////////////////////////////////////////////////////////////////////////////// =============================== split_module===============================////////////////

module Division_IP_first_level(
    // Input signals
    IN_Divisor,
    // Output signals
    OUT_Quotient,
    Remainder
);

// ===============================================================
// Input & Output
// ===============================================================
input [23:0]  IN_Divisor; //x^5 ~ x^0

output reg [15:0] OUT_Quotient; //4bit *4
output reg [19:0] Remainder;    //4bit *5
reg [27:0]dividend_1;
reg [27:0]divisor_1;
reg [27:0]dividend_2;
reg [27:0]divisor_2;
reg [27:0]degree;
reg [6:0]degree_dividend;
reg [1:0]degree_div;
reg [27:0]q;
reg [2:0]dividend_count;
reg [2:0]divisor_count;
wire[27:0]x6;
assign x6=28'h0ff_ffff;
/*
wire [3:0]data[0:6];
assign data[0]=IN_Dividend[27:24];
assign data[1]=IN_Dividend[23:20];
assign data[2]=IN_Dividend[19:16];
assign data[3]=IN_Dividend[15:12];
assign data[4]=IN_Dividend[11: 8];
assign data[5]=IN_Dividend[ 7: 4];
assign data[6]=IN_Dividend[ 3: 0];
*/
reg [3:0]a_data  [6:0];        //dividend
reg [3:0]a_data_1[6:0];        //dividend
reg [3:0]a_data_2[6:0];        //dividend
reg [3:0]a_data_3[6:0];        //dividend
reg [3:0]a_data_4[6:0];        //dividend
reg [3:0]a_data_5[6:0];        //dividend
reg [3:0]a_data_6[6:0];        //dividend

reg [3:0]b_data[6:0];          //divisor
reg [3:0]c_data[6:0];          //quotient

reg [3:0]d_data[6:0];          //reminder
integer i;
//===============================================================
//                             Design
//================================================================


always@(*)begin //Divisor
    if({b_data[5],b_data[4]}==8'b1111_1111)begin        //2's ff
        degree_div=2'd2;
    end
    else if({b_data[5]}==4'b1111)begin                  //1's f
        degree_div=2'd1;

    end
    else begin                                          //0's 
       degree_div=2'd0;
    end
end
/*
always@(*)begin
    case(degree_div)
    1:      divisor_1={IN_Divisor[3 : 0],IN_Divisor[27: 4]};
    3:      divisor_1={IN_Divisor[7 : 0],IN_Divisor[27: 8]};
    7:      divisor_1={IN_Divisor[11: 0],IN_Divisor[27:12]};
    15:     divisor_1={IN_Divisor[15: 0],IN_Divisor[27:16]};
    31:     divisor_1={IN_Divisor[19: 0],IN_Divisor[27:20]};
    63:     divisor_1={IN_Divisor[23: 0],IN_Divisor[27:24]};
    127:    divisor_1=IN_Divisor[27: 0]; 
    default:divisor_1=IN_Divisor[27: 0];     


    endcase
end
*/



always @(*) begin //a_data(IN_Dividend)
    a_data[6] = x6[27:24];
    a_data[5] = x6[23:20];
    a_data[4] = x6[19:16];
    a_data[3] = x6[15:12];
    a_data[2] = x6[11: 8];
    a_data[1] = x6[ 7: 4];
    a_data[0] = x6[ 3: 0];
end
always @(*) begin //b_data(IN_Divisor)
    b_data[5] = IN_Divisor[23:20];
    b_data[4] = IN_Divisor[19:16];
    b_data[3] = IN_Divisor[15:12];
    b_data[2] = IN_Divisor[11: 8];
    b_data[1] = IN_Divisor[ 7: 4];
    b_data[0] = IN_Divisor[ 3: 0];
end

always@(*)begin

    c_data[6]=4'hf;a_data_1[6]=4'hf;a_data_2[6]=4'hf;a_data_3[6]=4'hf;a_data_4[6]=4'hf;a_data_5[6]=4'hf;a_data_6[6]=4'hf;
    c_data[5]=4'hf;a_data_1[5]=4'hf;a_data_2[5]=4'hf;a_data_3[5]=4'hf;a_data_4[5]=4'hf;a_data_5[5]=4'hf;a_data_6[5]=4'hf;
    c_data[4]=4'hf;a_data_1[4]=4'hf;a_data_2[4]=4'hf;a_data_3[4]=4'hf;a_data_4[4]=4'hf;a_data_5[4]=4'hf;a_data_6[4]=4'hf;
    c_data[3]=4'hf;a_data_1[3]=4'hf;a_data_2[3]=4'hf;a_data_3[3]=4'hf;a_data_4[3]=4'hf;a_data_5[3]=4'hf;a_data_6[3]=4'hf;
    c_data[2]=4'hf;a_data_1[2]=4'hf;a_data_2[2]=4'hf;a_data_3[2]=4'hf;a_data_4[2]=4'hf;a_data_5[2]=4'hf;a_data_6[2]=4'hf;
    c_data[1]=4'hf;a_data_1[1]=4'hf;a_data_2[1]=4'hf;a_data_3[1]=4'hf;a_data_4[1]=4'hf;a_data_5[1]=4'hf;a_data_6[1]=4'hf;
    c_data[0]=4'hf;a_data_1[0]=4'hf;a_data_2[0]=4'hf;a_data_3[0]=4'hf;a_data_4[0]=4'hf;a_data_5[0]=4'hf;a_data_6[0]=4'hf;


    d_data[6]=4'hf;
    d_data[5]=4'hf;
    d_data[4]=4'hf;
    d_data[3]=4'hf;
    d_data[2]=4'hf;
    d_data[1]=4'hf;
    d_data[0]=4'hf;

    case(degree_div)
    2'd2:begin
        c_data[3] = add(b_data[3], a_data[6]);
        if(b_data[2] == 15)
            a_data_1[6] = get_alpha_index(a_data[5], b_data[2]);
        else
            a_data_1[6] = get_alpha_index(minus(b_data[2], c_data[3]), a_data[5]);
        if(b_data[1] == 15)
            a_data_1[5] = get_alpha_index(a_data[4], b_data[1]);
        else
            a_data_1[5] = get_alpha_index(minus(b_data[1], c_data[3]), a_data[4]);
        if(b_data[0] == 15)
            a_data_1[4] = get_alpha_index(a_data[3], b_data[0]);
        else
            a_data_1[4] = get_alpha_index(minus(b_data[0], c_data[3]), a_data[3]);
        a_data_1[3] = a_data[2];
        a_data_1[2] = a_data[1];
        a_data_1[1] = a_data[0];
        a_data_1[0] = 4'hf;
     //--------- split --------//
        if(a_data_1[6] == 15)begin
            c_data[2] = 4'hf;
            
            a_data_2[6]=a_data_1[5];
            a_data_2[5]=a_data_1[4];
            a_data_2[4]=a_data_1[3];
            a_data_2[3]=a_data_1[2];
            a_data_2[2]=a_data_1[1];
            a_data_2[1]=a_data_1[0];
            a_data_2[0]=4'hf;
        end
        else begin
            c_data[2] = add(b_data[3], a_data_1[6]);
 
            if(b_data[2] == 15)
                a_data_2[6] = get_alpha_index(a_data_1[5], b_data[2]);
            else
                a_data_2[6] = get_alpha_index(minus(b_data[2], c_data[2]), a_data_1[5]);
    
            if(b_data[1] == 15)
                a_data_2[5] = get_alpha_index(a_data_1[4], b_data[1]);
            else
                a_data_2[5] = get_alpha_index(minus(b_data[1], c_data[2]), a_data_1[4]);
    
            if(b_data[0] == 15)
                a_data_2[4] = get_alpha_index(a_data_1[3], b_data[0]);
            else
                a_data_2[4] = get_alpha_index(minus(b_data[0], c_data[2]), a_data_1[3]);
    
            a_data_2[3] = a_data_1[2];
            a_data_2[2] = a_data_1[1];
            a_data_2[1] = 4'hf;
            a_data_2[0] = 4'hf;
        end
     //--------- split --------//
        if(a_data_2[6] == 15)begin
            c_data[1] = 4'hf;
            a_data_3[6]=a_data_2[5];
            a_data_3[5]=a_data_2[4];
            a_data_3[4]=a_data_2[3];
            a_data_3[3]=a_data_2[2];
            a_data_3[2]=a_data_2[1];
            a_data_3[1]=a_data_2[0];
            a_data_3[0]=4'hf;
        end
        else begin
            c_data[1] = add(b_data[3], a_data_2[6]);

            if(b_data[2] == 15)
                a_data_3[6] = get_alpha_index(a_data_2[5], b_data[2]);
            else
                a_data_3[6] = get_alpha_index(minus(b_data[2], c_data[1]), a_data_2[5]);
    
            if(b_data[1] == 15)
                a_data_3[5] = get_alpha_index(a_data_2[4], b_data[1]);
            else
                a_data_3[5] = get_alpha_index(minus(b_data[1], c_data[1]), a_data_2[4]);
    
            if(b_data[0] == 15)
                a_data_3[4] = get_alpha_index(a_data_2[3], b_data[0]);
            else
                a_data_3[4] = get_alpha_index(minus(b_data[0], c_data[1]), a_data_2[3]);
    
            a_data_3[3] = a_data_2[2];
            a_data_3[2] = 4'hf;
            a_data_3[1] = 4'hf;
            a_data_3[0] = 4'hf;
        end
        //--------- split --------//
        if(a_data_3[6] == 15)begin
            c_data[0] = 4'hf;

            d_data[4]=4'hf;
            d_data[3]=4'hf;
            d_data[2]=a_data_3[5];
            d_data[1]=a_data_3[4];
            d_data[0]=a_data_3[3];
        end
        else begin
            c_data[0] = add(b_data[3], a_data_3[6]);
            d_data[2]=get_alpha_index(check(b_data[2],c_data[0]),a_data_3[5]);
            d_data[1]=get_alpha_index(check(b_data[1],c_data[0]),a_data_3[4]);
            d_data[0]=get_alpha_index(check(b_data[0],c_data[0]),a_data_3[3]);
        end
    end
    2'd1:begin //1's f
        c_data[2]=add(b_data[4],a_data[6]);

        if(b_data[3]==15)
            a_data_1[6]=get_alpha_index(a_data[5],b_data[3]);
        else 
            a_data_1[6]=get_alpha_index(minus(b_data[3],c_data[2]),a_data[5]);
        if(b_data[2]==15)
            a_data_1[5]=get_alpha_index(a_data[4],b_data[2]);
        else 
            a_data_1[5]=get_alpha_index(minus(b_data[2],c_data[2]),a_data[4]);
        if(b_data[1]==15)
            a_data_1[4]=get_alpha_index(a_data[3],b_data[1]);
        else 
            a_data_1[4]=get_alpha_index(minus(b_data[1],c_data[2]),a_data[3]);
        if(b_data[0]==15)
            a_data_1[3]=get_alpha_index(a_data[2],b_data[0]);
        else 
            a_data_1[3]=get_alpha_index(minus(b_data[0],c_data[2]),a_data[2]);
        a_data_1[2]=a_data[1];
        a_data_1[1]=a_data[0];
        a_data_1[0]=4'hf;

        //-----split -----//
        if(a_data_1[6]==15) begin
            c_data[1]=4'hf;
            a_data_2[6] =a_data_1[5];
            a_data_2[5] =a_data_1[4];
            a_data_2[4] =a_data_1[3];
            a_data_2[3] =a_data_1[2];
            a_data_2[2] =a_data_1[1];
            a_data_2[1] =a_data_1[0];
            a_data_2[0] =4'hf;

        end
        else begin 
            c_data[1]=add(b_data[4],a_data_1[6]);
            if(b_data[3]==15)
                a_data_2[6]=get_alpha_index(a_data_1[5],b_data[3]);
            else 
                a_data_2[6]=get_alpha_index(minus(b_data[3],c_data[1]),a_data_1[5]);
            if(b_data[2]==15)
                a_data_2[5]=get_alpha_index(a_data_1[4],b_data[2]);
            else 
                a_data_2[5]=get_alpha_index(minus(b_data[2],c_data[1]),a_data_1[4]);
            if(b_data[1]==15)
                a_data_2[4]=get_alpha_index(a_data_1[3],b_data[1]);
            else 
                a_data_2[4]=get_alpha_index(minus(b_data[1],c_data[1]),a_data_1[3]);
            if(b_data[0]==15)
                a_data_2[3]=get_alpha_index(a_data_1[2],b_data[0]);
            else 
                a_data_2[3]=get_alpha_index(minus(b_data[0],c_data[1]),a_data_1[2]);
            a_data_2[2]=a_data_1[1];
            a_data_2[1]=4'hf;
            a_data_2[0]=4'hf;
        end
        //--------- split --------//
        if(a_data_2[6]==15)begin
            c_data[0]=4'hf;

            d_data[4]=4'hf;
            d_data[3]=a_data_2[5];
            d_data[2]=a_data_2[4];
            d_data[1]=a_data_2[3];
            d_data[0]=a_data_2[2];
        end
        else begin
            c_data[0]=add(b_data[4],a_data_2[6]);

            d_data[3]=get_alpha_index(check(b_data[3],c_data[0]),a_data_2[5]);
            d_data[2]=get_alpha_index(check(b_data[2],c_data[0]),a_data_2[4]);
            d_data[1]=get_alpha_index(check(b_data[1],c_data[0]),a_data_2[3]);
            d_data[0]=get_alpha_index(check(b_data[0],c_data[0]),a_data_2[2]);
        
        end



    end
    2'd0:begin//0's f 
        c_data[1]=add(b_data[5],a_data[6]);
        if(b_data[4]==15)
            a_data_1[6]=get_alpha_index(a_data[5],b_data[4]);
        else begin
            a_data_1[6]=get_alpha_index( minus(b_data[4],c_data[1]) , a_data[5]);
        end
        if(b_data[3]==15)
            a_data_1[5]=get_alpha_index(a_data[4],b_data[3]);
        else begin
            a_data_1[5]=get_alpha_index(minus(b_data[3],c_data[1]) , a_data[4]);
        end
        if(b_data[2]==15)
            a_data_1[4]=get_alpha_index(a_data[3],b_data[2]);
        else begin
            a_data_1[4]=get_alpha_index(minus(b_data[2],c_data[1]) , a_data[3]);
        end
        if(b_data[1]==15)
            a_data_1[3]=get_alpha_index(a_data[2],b_data[1]);
        else begin
            a_data_1[3]=get_alpha_index(minus(b_data[1],c_data[1]) , a_data[2]);
        end       
        if(b_data[0]==15)
            a_data_1[2]=get_alpha_index(a_data[1],b_data[0]);
        else begin
            a_data_1[2]=get_alpha_index(minus(b_data[0],c_data[1]) , a_data[1]);
        end
        a_data_1[1]=a_data[0];
        a_data_1[0]=4'hf;

        //--------- split --------//
        if(a_data_1[6]==15)begin
            c_data[0]=4'hf;
            
            d_data[4]=a_data_1[5];
            d_data[3]=a_data_1[4];
            d_data[2]=a_data_1[3];
            d_data[1]=a_data_1[2];
            d_data[0]=a_data_1[1];
        end
        else begin
            c_data[0]=add(b_data[5],a_data_1[6]);

            d_data[4]=get_alpha_index(check(b_data[4],c_data[0]),a_data_1[5]);
            d_data[3]=get_alpha_index(check(b_data[3],c_data[0]),a_data_1[4]);
            d_data[2]=get_alpha_index(check(b_data[2],c_data[0]),a_data_1[3]);
            d_data[1]=get_alpha_index(check(b_data[1],c_data[0]),a_data_1[2]);
            d_data[0]=get_alpha_index(check(b_data[0],c_data[0]),a_data_1[1]);
        end
    end
    endcase
end




wire [3:0]alpha_power[0:15]; //[power] = [value]
assign alpha_power[0 ]=4'd1;
assign alpha_power[1 ]=4'd2;
assign alpha_power[2 ]=4'd4;
assign alpha_power[3 ]=4'd8;
assign alpha_power[4 ]=4'd3;
assign alpha_power[5 ]=4'd6;
assign alpha_power[6 ]=4'd12;
assign alpha_power[7 ]=4'd11;
assign alpha_power[8 ]=4'd5;
assign alpha_power[9 ]=4'd10;
assign alpha_power[10]=4'd7;
assign alpha_power[11]=4'd14;
assign alpha_power[12]=4'd15;
assign alpha_power[13]=4'd13;
assign alpha_power[14]=4'd9;
assign alpha_power[15]=4'd0;


function [3:0] get_alpha_index;
    input [3:0]a,b;
	reg [3:0]index;
    begin
        index=alpha_power[a]^alpha_power[b]; //xor
        case(index)
            4'd1:  get_alpha_index = 0;
            4'd2:  get_alpha_index = 1;
            4'd4:  get_alpha_index = 2;
            4'd8:  get_alpha_index = 3;
            4'd3:  get_alpha_index = 4;
            4'd6:  get_alpha_index = 5;
            4'd12: get_alpha_index = 6;
            4'd11: get_alpha_index = 7;
            4'd5:  get_alpha_index = 8;
            4'd10: get_alpha_index = 9;
            4'd7:  get_alpha_index = 10;
            4'd14: get_alpha_index = 11;
            4'd15: get_alpha_index = 12;
            4'd13: get_alpha_index = 13;
            4'd9:  get_alpha_index = 14;
            4'd0:  get_alpha_index = 15;
            default: get_alpha_index = 15;
        endcase
	end
endfunction

function [3:0]check;
    input[3:0]in_e;
    input[3:0]in_f;
    if(in_e==15)
        check=15;
    else if((in_e+in_f)>=15)
        check=(in_e+in_f)-15;
    else
        check=(in_e+in_f);
endfunction


function [3:0]add;
    input [3:0]in_b;
    input [3:0]in_a;
    if(in_b>in_a)
        add=(in_a+15)-in_b;
    else 
        add=in_a-in_b;
endfunction

function [3:0]minus;
    input[3:0]in_c;
    input[3:0]in_d;
    if((in_c+in_d)>=15)
        minus=(in_c+in_d)-15;
    else
        minus=(in_c+in_d);
endfunction

always@(*)begin//OUT_Quotient[15:0]
    OUT_Quotient={c_data[3],c_data[2],c_data[1],c_data[0]};
    
end
always@(*)begin//Remainder[19:0]
    Remainder={d_data[4],d_data[3],d_data[2],d_data[1],d_data[0]};
end

endmodule