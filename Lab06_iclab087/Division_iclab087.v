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
module Division_IP #(parameter IP_WIDTH = 7) (
    // Input signals
    IN_Dividend, IN_Divisor,
    // Output signals
    OUT_Quotient
);

// ===============================================================
// Input & Output
// ===============================================================
input [IP_WIDTH*4-1:0]  IN_Dividend;
input [IP_WIDTH*4-1:0]  IN_Divisor;

output reg [IP_WIDTH*4-1:0] OUT_Quotient;

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

reg [3:0]b_data  [6:0];        //divisor
reg [3:0]c_data[6:0];          //quotient
integer i;
//===============================================================
//                             Design
//================================================================
always@(*)begin //Dividend
    //if(IN_Dividend[27:0]==28'b1111_1111_1111_1111_1111_1111_1111)begin
    //    degree_dividend[6]=1;
    //end
    dividend_count=0;
    if({a_data[6],a_data[5],a_data[4],a_data[3],a_data[2],a_data[1]}==24'b1111_1111_1111_1111_1111_1111)begin //6's 15 1's not 15
        degree_dividend[6] = 1;
        degree_dividend[5] = 0;
        degree_dividend[4] = 0;
        degree_dividend[3] = 0;
        degree_dividend[2] = 0;
        degree_dividend[1] = 0;
        degree_dividend[0] = 0;

        dividend_count=6;
    end
    else if({a_data[6],a_data[5],a_data[4],a_data[3],a_data[2]}== 20'b1111_1111_1111_1111_1111) begin
        degree_dividend[6] = 0;
        degree_dividend[5] = 1;
        degree_dividend[4] = 0;
        degree_dividend[3] = 0;
        degree_dividend[2] = 0;
        degree_dividend[1] = 0;
        degree_dividend[0] = 0;
        
        dividend_count=5;
    end
    else if({a_data[6],a_data[5],a_data[4],a_data[3]}== 16'b1111_1111_1111_1111) begin
        degree_dividend[6] = 0;
        degree_dividend[5] = 0;
        degree_dividend[4] = 1;
        degree_dividend[3] = 0;
        degree_dividend[2] = 0;
        degree_dividend[1] = 0;
        degree_dividend[0] = 0;
        
        dividend_count=4;
    end
    else if({a_data[6],a_data[5],a_data[4]}== 12'b1111_1111_1111) begin
        degree_dividend[6] = 0;
        degree_dividend[5] = 0;
        degree_dividend[4] = 0;
        degree_dividend[3] = 1;
        degree_dividend[2] = 0;
        degree_dividend[1] = 0;
        degree_dividend[0] = 0;

        dividend_count=3;
    end
    else if({a_data[6],a_data[5]} == 8'b1111_1111) begin
        degree_dividend[6] = 0;
        degree_dividend[5] = 0;
        degree_dividend[4] = 0;
        degree_dividend[3] = 0;
        degree_dividend[2] = 1;
        degree_dividend[1] = 0;
        degree_dividend[0] = 0;

        dividend_count=2;
    end
    else if(a_data[6]== 4'b1111) begin
        degree_dividend[6] = 0;
        degree_dividend[5] = 0;
        degree_dividend[4] = 0;
        degree_dividend[3] = 0;
        degree_dividend[2] = 0;
        degree_dividend[1] = 1;
        degree_dividend[0] = 0;

        dividend_count=1;
    end
    else begin 
        degree_dividend[6] = 0;
        degree_dividend[5] = 0;
        degree_dividend[4] = 0;
        degree_dividend[3] = 0;
        degree_dividend[2] = 0;
        degree_dividend[1] = 0;
        degree_dividend[0] = 1;
        dividend_count=0;
       
    end
    
end

always@(*)begin //Divisor
    //if(IN_Divisor[27:0]==28'b1111_1111_1111_1111_1111_1111_1111)begin
    //    degree_div[6]=1;
    //end
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
        7: begin
            a_data[6] = IN_Dividend[27:24];
            a_data[5] = IN_Dividend[23:20];
            a_data[4] = IN_Dividend[19:16];
            a_data[3] = IN_Dividend[15:12];
            a_data[2] = IN_Dividend[11:8];
            a_data[1] = IN_Dividend[7:4];
            a_data[0] = IN_Dividend[3:0];
        end
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
        7: begin
            b_data[6] = IN_Divisor[27:24];
            b_data[5] = IN_Divisor[23:20];
            b_data[4] = IN_Divisor[19:16];
            b_data[3] = IN_Divisor[15:12];
            b_data[2] = IN_Divisor[11:8];
            b_data[1] = IN_Divisor[7:4];
            b_data[0] = IN_Divisor[3:0];
        end
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
    7'b1000000:begin//6's ffffff
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
        if(a_data_6[6]==15)
            c_data[0]= 4'hf;
        else 
            c_data[0]=add(b_data[0],a_data_6[6]);
    end
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
    if(a_data_5[6] == 15)
        c_data[0] = 4'hf;
    else
        c_data[0] = add(b_data[1], a_data_5[6]);




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
    if(a_data_4[6] == 15)
        c_data[0] = 4'hf;
    else
        c_data[0] = add(b_data[2], a_data_4[6]);






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
        if(a_data_3[6] == 15)
            c_data[0] = 4'hf;
        else
            c_data[0] = add(b_data[3], a_data_3[6]);













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
        if(a_data_2[6]==15)
            c_data[0]=4'hf;
        else begin
            c_data[0]=add(b_data[4],a_data_2[6]);
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
        if(a_data_1[6]==15)
            c_data[0]=4'hf;
        else begin
            c_data[0]=add(b_data[5],a_data_1[6]);
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
        end
        else begin

            c_data[0]=add(b_data[6],a_data[6]);

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

/* //Not usage
always@(*)begin
    case(degree_dividend)
    1:      dividend_1={IN_Dividend[3 : 0],IN_Dividend[27: 4]};
    3:      dividend_1={IN_Dividend[7 : 0],IN_Dividend[27: 8]};
    7:      dividend_1={IN_Dividend[11: 0],IN_Dividend[27:12]};
    15:     dividend_1={IN_Dividend[15: 0],IN_Dividend[27:16]};
    31:     dividend_1={IN_Dividend[19: 0],IN_Dividend[27:20]};
    63:     dividend_1={IN_Dividend[23: 0],IN_Dividend[27:24]};
    127:    dividend_1=IN_Dividend[27: 0]; 
    default:dividend_1=IN_Dividend[27: 0];     


    endcase
end

*/


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
    if((in_c+in_d)>=15)
        minus=(in_c+in_d)-15;
    else
        minus=(in_c+in_d);
endfunction

always@(*)begin
    OUT_Quotient={c_data[6],c_data[5],c_data[4],c_data[3],c_data[2],c_data[1],c_data[0]};
    //OUT_Quotient=get_alpha_index(14,15);
end


/*
always(*)begin
    if(IN_Divisor[27:24]!=15)
        degree_div[6]=1;
    else if(IN_Divisor[23:20]!=15)
        degree_div[5]=1;
    else if(IN_Divisor[19:16]!=15)
        degree_div[4]=1;
    else if(IN_Divisor[15:12]!=15)
        degree_div[3]=1;
    else if(IN_Divisor[11: 8]!=15)
        degree_div[2]=1;
    else if(IN_Divisor[ 7: 4]!=15)
        degree_div[1]=1;
    else if(IN_Divisor[ 3: 0]!=15)
        degree_div[0]=1;
    else beign 
        for(int i=0;i<7;i=i+1)begin
            degree_div[i]=1;
    end
    
end
*/


















/*
parameter   A_WIDTH = 7;
parameter   B_WIDTH = 7;
// IN_Dividend/IN_Divisor = div_data------remain_data




wire   [A_WIDTH - 1 : 0]                             div_data_tmp    ;
wire   [A_WIDTH - 1 : 0] [A_WIDTH + B_WIDTH - 1 : 0] aIN_Divisor_tmp     ;
wire   [A_WIDTH - 1 : 0] [A_WIDTH - 1 : 0]           IN_Dividend_tmp      ; 
wire   [B_WIDTH - 1 : 0]                             remain_data_tmp ;

assign  aIN_Divisor_tmp[A_WIDTH - 1]   = IN_Divisor << (A_WIDTH - 1);
assign  div_data_tmp[A_WIDTH - 1]  = {{B_WIDTH{1'b0}}, IN_Dividend} >= aIN_Divisor_tmp[A_WIDTH - 1] ? 1'b1 : 1'b0;
assign  IN_Dividend_tmp[A_WIDTH - 1]    = div_data_tmp[A_WIDTH - 1] ? {{B_WIDTH{1'b0}},IN_Dividend} - aIN_Divisor_tmp[A_WIDTH - 1] : IN_Dividend;

genvar i;
generate 
    for(i = A_WIDTH - 2; i >= 0; i--)
        begin:div
            assign aIN_Divisor_tmp[i]  = (IN_Divisor << i);
            assign div_data_tmp[i] = {{B_WIDTH{1'b0}}, IN_Dividend_tmp[i+1]} >= aIN_Divisor_tmp[i] ? 1'b1 : 1'b0;
            assign IN_Dividend_tmp[i]   = div_data_tmp[i] ? {{B_WIDTH{1'b0}},IN_Dividend_tmp[i+1]} - aIN_Divisor_tmp[i] : IN_Dividend_tmp[i + 1];
        end
endgenerate

assign remain_data_tmp = {{B_WIDTH{1'b0}}, IN_Dividend} - div_data_tmp * IN_Divisor;


always@(*)begin
    OUT_Quotient=div_data_tmp;
end
*/
endmodule