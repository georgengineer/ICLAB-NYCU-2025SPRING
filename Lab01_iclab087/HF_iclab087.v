module HF(
    // Input signals
    input [24:0] symbol_freq,
    // Output signals
    output reg [19:0] out_encoded
);

//================================================================
//    Wire & Registers 
//================================================================
// Declare the wire/reg you would use in your circuit
// remember 
// wire for port connection and cont. assignment
// reg for proc. assignment

//================================================================
//    DESIGN
//================================================================


wire [9:0]data1;
wire [9:0]data2;
wire [9:0]data3;
wire [9:0]data4;
wire [9:0]data5;
	  
wire [9:0]one_data1;                 
wire [9:0]one_data2;                 
wire [9:0]one_data3;                 
wire [9:0]one_data4;                 
wire [9:0]one_data5; 
wire [9:0]two_data1;
wire [9:0]two_data2;
wire [9:0]two_data3;
wire [9:0]two_data4;
wire [9:0]two_data5;
wire [9:0]three_data1;
wire [9:0]three_data2;
wire [9:0]three_data3;
wire [9:0]three_data4;
wire [9:0]three_data5;           
wire [9:0]four_data1;
wire [9:0]four_data2;
wire [9:0]four_data3;
wire [9:0]four_data4;
wire [9:0]four_data5;  

wire [12:0]five_data1;//5bit frequency  + 5bit tag 
wire [12:0]five_data2;
wire [12:0]five_data3;
wire [12:0]five_data4;
wire [12:0]five_data5; 

reg a_output; reg a_output_one; reg a_output_two; reg a_output_three; reg[3:0]a_output_four;
reg b_output; reg b_output_one; reg b_output_two; reg b_output_three; reg[3:0]b_output_four;
reg c_output; reg c_output_one; reg c_output_two; reg c_output_three; reg[3:0]c_output_four;
reg d_output; reg d_output_one; reg d_output_two; reg d_output_three; reg[3:0]d_output_four;
reg e_output; reg e_output_one; reg e_output_two; reg e_output_three; reg[3:0]e_output_four;

wire [10:0] one_add1;//(5bit+5bit) max_bit is 6bit +5bit_tag = 6+5=11 bit
wire [10:0]level2_one_data1; wire [10:0]level2_two_data1; reg [12:0]level2_three_data1;
wire [10:0]level2_one_data2; wire [10:0]level2_two_data2; reg [12:0]level2_three_data2;
wire [10:0]level2_one_data3; wire [10:0]level2_two_data3; reg [12:0]level2_three_data3;
wire [10:0]level2_one_data4; wire [10:0]level2_two_data4; reg [12:0]level2_three_data4;
                                                          reg [12:0]level2_three_data5; 
                                                         

wire [11:0] two_add1;//(6bit+5bit) max_bit is 7bit +5bit_tag = 7+5=12 bit
wire [11:0]level3_one_data1; wire [11:0]level3_two_data1; reg [11:0]level3_three_data1;
wire [11:0]level3_one_data2; wire [11:0]level3_two_data2; reg [11:0]level3_three_data2;
wire [11:0]level3_one_data3; wire [11:0]level3_two_data3; reg [11:0]level3_three_data3;

wire [12:0] three_add1;
reg [12:0]level4_three_data1;
reg [12:0]level4_three_data2;
reg [1:0]test;
wire zero;
assign zero=1'b0;
wire zeor_4bit=0;
assign zero_4bit=4'b0;

wire [2:0]count_a; wire [2:0]count_a_one;wire [2:0]count_a_two;wire [2:0]count_a_three;
wire [2:0]count_b; wire [2:0]count_b_one;wire [2:0]count_b_two;wire [2:0]count_b_three;
wire [2:0]count_c; wire [2:0]count_c_one;wire [2:0]count_c_two;wire [2:0]count_c_three;
wire [2:0]count_d; wire [2:0]count_d_one;wire [2:0]count_d_two;wire [2:0]count_d_three;
wire [2:0]count_e; wire [2:0]count_e_one;wire [2:0]count_e_two;wire [2:0]count_e_three;

wire [3:0]encode_two_array[0:4];//5*4array which means 4bit->[3:0] 5 ->[0:4]



assign count_a=(five_data1[0] || five_data2[0])?zero+1'b1:zero;
assign count_b=(five_data1[1] || five_data2[1])?zero+1'b1:zero;
assign count_c=(five_data1[2] || five_data2[2])?zero+1'b1:zero;
assign count_d=(five_data1[3] || five_data2[3])?zero+1'b1:zero;
assign count_e=(five_data1[4] || five_data2[4])?zero+1'b1:zero;

assign count_a_one=(level2_three_data1[0] || level2_three_data2[0])?count_a+1'b1:count_a;
assign count_b_one=(level2_three_data1[1] || level2_three_data2[1])?count_b+1'b1:count_b;
assign count_c_one=(level2_three_data1[2] || level2_three_data2[2])?count_c+1'b1:count_c;       
assign count_d_one=(level2_three_data1[3] || level2_three_data2[3])?count_d+1'b1:count_d;        
assign count_e_one=(level2_three_data1[4] || level2_three_data2[4])?count_e+1'b1:count_e;

assign count_a_two=(level3_three_data1[0] || level3_three_data2[0])?count_a_one+1'b1:count_a_one;
assign count_b_two=(level3_three_data1[1] || level3_three_data2[1])?count_b_one+1'b1:count_b_one;
assign count_c_two=(level3_three_data1[2] || level3_three_data2[2])?count_c_one+1'b1:count_c_one;
assign count_d_two=(level3_three_data1[3] || level3_three_data2[3])?count_d_one+1'b1:count_d_one;
assign count_e_two=(level3_three_data1[4] || level3_three_data2[4])?count_e_one+1'b1:count_e_one;

assign count_a_three=(level4_three_data1[0] || level4_three_data2[0])?count_a_two+1'b1:count_a_two;
assign count_b_three=(level4_three_data1[1] || level4_three_data2[1])?count_b_two+1'b1:count_b_two;
assign count_c_three=(level4_three_data1[2] || level4_three_data2[2])?count_c_two+1'b1:count_c_two;
assign count_d_three=(level4_three_data1[3] || level4_three_data2[3])?count_d_two+1'b1:count_d_two;
assign count_e_three=(level4_three_data1[4] || level4_three_data2[4])?count_e_two+1'b1:count_e_two;





assign data1={symbol_freq[24:20],5'b00001};//a 5bit 00001
assign data2={symbol_freq[19:15],5'b00010};//b 5bit 00010
assign data3={symbol_freq[14:10],5'b00100};//c 5bit 00100
assign data4={symbol_freq[9:5]  ,5'b01000};//d 5bit 01000
assign data5={symbol_freq[4:0]  ,5'b10000};//e 5bit 10000 



/*
assign one_data1=(data1[9:0]>data4[9:0])?data4:data1;
assign one_data4=(data1[9:0]>data4[9:0])?data1:data4;
assign one_data2=(data2[9:0]>data5[9:0])?data5:data2;
assign one_data5=(data2[9:0]>data5[9:0])?data2:data5;
assign one_data3=data3;


assign two_data1=(one_data1[9:0]>one_data3[9:0])?one_data3:one_data1; //small (small<big)?big:small;
assign two_data3=(one_data1[9:0]>one_data3[9:0])?one_data1:one_data3;
assign two_data2=(one_data2[9:0]>one_data4[9:0])?one_data4:one_data2;
assign two_data4=(one_data2[9:0]>one_data4[9:0])?one_data2:one_data4;
assign two_data5=one_data5;

assign three_data1=(two_data1[9:0]>two_data2[9:0])?two_data2:two_data1;
assign three_data2=(two_data1[9:0]>two_data2[9:0])?two_data1:two_data2;
assign three_data3=(two_data3[9:0]>two_data5[9:0])?two_data5:two_data3;
assign three_data5=(two_data3[9:0]>two_data5[9:0])?two_data3:two_data5;
assign three_data4=two_data4;

assign four_data2=(three_data2[9:0]>three_data3[9:0])?three_data3:three_data2;
assign four_data3=(three_data2[9:0]>three_data3[9:0])?three_data2:three_data3;
assign four_data4=(three_data4[9:0]>three_data5[9:0])?three_data5:three_data4;
assign four_data5=(three_data4[9:0]>three_data5[9:0])?three_data4:three_data5;
assign four_data1=three_data1;

assign five_data1=four_data1;
assign five_data2=four_data2;
assign five_data3=(four_data3[9:0]>four_data4[9:0])?four_data4:four_data3;
assign five_data4=(four_data3[9:0]>four_data4[9:0])?four_data3:four_data4;
assign five_data5=four_data5;*/
//smallest to biggest -> output_1 to output_5
Sorted_five_element Sort_5_A(
                            .input_1({3'b000,data1}),       
                            .input_2({3'b000,data2}),       
                            .input_3({3'b000,data3}),       
                            .input_4({3'b000,data4}),        
                            .input_5({3'b000,data5}),
                            .output_1(five_data1), 
                            .output_2(five_data2), 
                            .output_3(five_data3), 
                            .output_4(five_data4), 
                            .output_5(five_data5));

assign one_add1=five_data1+five_data2;
/*
Sorted_five_element Sort_5_B(
                            .input_1(13'b1_1111_1111_1111),
                            .input_2({8'b000,five_data5[9:5]}),   
                            .input_3({8'b000,five_data4[9:5]}),   
                            .input_4({8'b000,five_data3[9:5]}),   
                            .input_5({7'b000,one_add1[10:5]}),
                            .output_1(level2_three_data1), 
                            .output_2(level2_three_data2), 
                            .output_3(level2_three_data3), 
                            .output_4(level2_three_data4), 
                            .output_5(level2_three_data5));
*/

always@(*)begin
    if(one_add1[10:5]>five_data5[9:5])begin // 6 bit >5 bit
        level2_three_data4=one_add1;      
        level2_three_data3=five_data5;
        level2_three_data2=five_data4;
        level2_three_data1=five_data3;
    end
    else if(one_add1[10:5]>five_data4[9:5])begin
        level2_three_data4=five_data5;
        level2_three_data3=one_add1;
        level2_three_data2=five_data4;
        level2_three_data1=five_data3;
    end
    else if(one_add1[10:5]>five_data3[9:5])begin
        level2_three_data4=five_data5;
        level2_three_data3=five_data4;
        level2_three_data2=one_add1;
        level2_three_data1=five_data3;
    end
    else begin
        level2_three_data4=five_data5;
        level2_three_data3=five_data4;
        level2_three_data2=five_data3;
        level2_three_data1=one_add1;
    end

end

assign two_add1=level2_three_data1+level2_three_data2;
always@(*)begin
    if(two_add1[11:5]>level2_three_data4[10:5])begin
        level3_three_data3=two_add1;
        level3_three_data2=level2_three_data4;
        level3_three_data1=level2_three_data3;
    end
    else if(two_add1[11:5]>level2_three_data3[10:5])begin
        level3_three_data3=level2_three_data4;  
        level3_three_data2=two_add1;
        level3_three_data1=level2_three_data3;
    end
    else begin
        level3_three_data3=level2_three_data4;
        level3_three_data2=level2_three_data3;
        level3_three_data1=two_add1;
    end
end
assign three_add1=level3_three_data1+level3_three_data2;
always@(*)begin
    if(three_add1[12:5]>level3_three_data3[11:5])begin
        level4_three_data2=three_add1;
        level4_three_data1=level3_three_data3;
    end
    else begin
        level4_three_data2=level3_three_data3;
        level4_three_data1=three_add1;
    end
end



always@(*)begin
    case(encode_two_array[0]) // synopsys parallel_case
    //4'b0000:
    4'b0001:a_output_four={a_output,1'b0        ,1'b0,1'b0};
    4'b0010:a_output_four={a_output_one,1'b0,1'b0,1'b0};
    4'b0011:a_output_four={a_output,a_output_one,1'b0,1'b0};
    4'b0100:a_output_four={a_output_two,1'b0,1'b0,1'b0};
    4'b0101:a_output_four={a_output,a_output_two,1'b0,1'b0};
    4'b0110:a_output_four={a_output_one,a_output_two,1'b0,1'b0};
    4'b0111:a_output_four={a_output,a_output_one,a_output_two,1'b0};
    4'b1000:a_output_four={a_output_three,1'b0,1'b0,1'b0};
    4'b1001:a_output_four={a_output,a_output_three,1'b0,1'b0};
    4'b1010:a_output_four={a_output_one,a_output_three,1'b0,1'b0};
    4'b1011:a_output_four={a_output,a_output_one,a_output_three,1'b0};
    4'b1100:a_output_four={a_output_two,a_output_three,1'b0,1'b0};
    4'b1101:a_output_four={a_output,a_output_two,a_output_three,1'b0};
    4'b1110:a_output_four={a_output_one,a_output_two,a_output_three,1'b0};
    4'b1111:a_output_four= {a_output,a_output_one,a_output_two,a_output_three};
    default:a_output_four= 4'b0000;
    endcase
end
always@(*)begin
    case(encode_two_array[1]) // synopsys parallel_case
    //4'b0000:
    4'b0001:b_output_four={b_output,1'b0        ,1'b0,1'b0};
    4'b0010:b_output_four={b_output_one,1'b0,1'b0,1'b0};
    4'b0011:b_output_four={b_output,b_output_one,1'b0,1'b0};
    4'b0100:b_output_four={b_output_two,1'b0,1'b0,1'b0};
    4'b0101:b_output_four={b_output,b_output_two,1'b0,1'b0};
    4'b0110:b_output_four={b_output_one,b_output_two,1'b0,1'b0};
    4'b0111:b_output_four={b_output,b_output_one,b_output_two,1'b0};
    4'b1000:b_output_four={b_output_three,1'b0,1'b0,1'b0};
    4'b1001:b_output_four={b_output,b_output_three,1'b0,1'b0};
    4'b1010:b_output_four={b_output_one,b_output_three,1'b0,1'b0};
    4'b1011:b_output_four={b_output,b_output_one,b_output_three,1'b0};
    4'b1100:b_output_four={b_output_two,b_output_three,1'b0,1'b0};
    4'b1101:b_output_four={b_output,b_output_two,b_output_three,1'b0};
    4'b1110:b_output_four={b_output_one,b_output_two,b_output_three,1'b0};
    4'b1111:b_output_four= {b_output,b_output_one,b_output_two,b_output_three};
    default:b_output_four= 4'b0000;
    endcase
end

always@(*)begin
    case(encode_two_array[2]) // synopsys parallel_case
    //4'b0000:
    4'b0001:c_output_four={c_output,1'b0        ,1'b0,1'b0};
    4'b0010:c_output_four={c_output_one,1'b0,1'b0,1'b0};
    4'b0011:c_output_four={c_output,c_output_one,1'b0,1'b0};
    4'b0100:c_output_four={c_output_two,1'b0,1'b0,1'b0};
    4'b0101:c_output_four={c_output,c_output_two,1'b0,1'b0};
    4'b0110:c_output_four={c_output_one,c_output_two,1'b0,1'b0};
    4'b0111:c_output_four={c_output,c_output_one,c_output_two,1'b0};
    4'b1000:c_output_four={c_output_three,1'b0,1'b0,1'b0};
    4'b1001:c_output_four={c_output,c_output_three,1'b0,1'b0};
    4'b1010:c_output_four={c_output_one,c_output_three,1'b0,1'b0};
    4'b1011:c_output_four={c_output,c_output_one,c_output_three,1'b0};
    4'b1100:c_output_four={c_output_two,c_output_three,1'b0,1'b0};
    4'b1101:c_output_four={c_output,c_output_two,c_output_three,1'b0};
    4'b1110:c_output_four={c_output_one,c_output_two,c_output_three,1'b0};
    4'b1111:c_output_four= {c_output,c_output_one,c_output_two,c_output_three};
    default:c_output_four= 4'b0000;
    endcase
end

always@(*)begin
    case(encode_two_array[3]) // synopsys parallel_case
    //4'b0000:
    4'b0001:d_output_four={d_output,1'b0        ,1'b0,1'b0};
    4'b0010:d_output_four={d_output_one,1'b0,1'b0,1'b0};
    4'b0011:d_output_four={d_output,d_output_one,1'b0,1'b0};
    4'b0100:d_output_four={d_output_two,1'b0,1'b0,1'b0};
    4'b0101:d_output_four={d_output,d_output_two,1'b0,1'b0};
    4'b0110:d_output_four={d_output_one,d_output_two,1'b0,1'b0};
    4'b0111:d_output_four={d_output,d_output_one,d_output_two,1'b0};
    4'b1000:d_output_four={d_output_three,1'b0,1'b0,1'b0};
    4'b1001:d_output_four={d_output,d_output_three,1'b0,1'b0};
    4'b1010:d_output_four={d_output_one,d_output_three,1'b0,1'b0};
    4'b1011:d_output_four={d_output,d_output_one,d_output_three,1'b0};
    4'b1100:d_output_four={d_output_two,d_output_three,1'b0,1'b0};
    4'b1101:d_output_four={d_output,d_output_two,d_output_three,1'b0};
    4'b1110:d_output_four={d_output_one,d_output_two,d_output_three,1'b0};
    4'b1111:d_output_four= {d_output,d_output_one,d_output_two,d_output_three};
    default:d_output_four= 4'b0000;
    endcase
end

always@(*)begin
    case(encode_two_array[4]) // synopsys parallel_case
    //4'b0000:
    4'b0001:e_output_four={e_output,1'b0        ,1'b0,1'b0};
    4'b0010:e_output_four={e_output_one,1'b0,1'b0,1'b0};
    4'b0011:e_output_four={e_output,e_output_one,1'b0,1'b0};
    4'b0100:e_output_four={e_output_two,1'b0,1'b0,1'b0};
    4'b0101:e_output_four={e_output,e_output_two,1'b0,1'b0};
    4'b0110:e_output_four={e_output_one,e_output_two,1'b0,1'b0};
    4'b0111:e_output_four={e_output,e_output_one,e_output_two,1'b0};
    4'b1000:e_output_four={e_output_three,1'b0,1'b0,1'b0};
    4'b1001:e_output_four={e_output,e_output_three,1'b0,1'b0};
    4'b1010:e_output_four={e_output_one,e_output_three,1'b0,1'b0};
    4'b1011:e_output_four={e_output,e_output_one,e_output_three,1'b0};
    4'b1100:e_output_four={e_output_two,e_output_three,1'b0,1'b0};
    4'b1101:e_output_four={e_output,e_output_two,e_output_three,1'b0};
    4'b1110:e_output_four={e_output_one,e_output_two,e_output_three,1'b0};
    4'b1111:e_output_four= {e_output,e_output_one,e_output_two,e_output_three};
    default:e_output_four= 4'b0000;
    endcase
end


//////////////split line////////////////////
always@(*)begin
    case({level4_three_data2[0],level4_three_data1[0]})
    2'b01:  a_output_three=1'b0;
    2'b10:  a_output_three=1'b1;
    default:a_output_three=1'b0;
    endcase
end
always@(*)begin
    case({level4_three_data2[1],level4_three_data1[1]})
    2'b01:  b_output_three=1'b0;
    2'b10:  b_output_three=1'b1;
    default:b_output_three=1'b0;
    endcase
end
always@(*)begin//c
    case({level4_three_data2[2],level4_three_data1[2]})
    2'b01:  c_output_three=1'b0;
    2'b10:  c_output_three=1'b1;
    default:c_output_three=1'b0;
    endcase
end

always@(*)begin//d
    case({level4_three_data2[3],level4_three_data1[3]})
    2'b01:  d_output_three=1'b0;
    2'b10:  d_output_three=1'b1;
    default:d_output_three=1'b0;
    endcase
end
always@(*)begin//e
    case({level4_three_data2[4],level4_three_data1[4]})
    2'b01:  e_output_three=1'b0;
    2'b10:  e_output_three=1'b1;
    default:e_output_three=1'b0;
    endcase
end



/////////////////////////////////////////////////////////////////split line////
always@(*)begin
    case({level3_three_data2[0],level3_three_data1[0]})
    2'b01:  a_output_two=1'b0;
    2'b10:  a_output_two=1'b1;
    default:a_output_two=1'b0;
    endcase
end
always@(*)begin
    case({level3_three_data2[1],level3_three_data1[1]})
    2'b01:  b_output_two=1'b0;
    2'b10:  b_output_two=1'b1;
    default:b_output_two=1'b0;
    endcase
end
always@(*)begin
    case({level3_three_data2[2],level3_three_data1[2]})
    2'b01:  c_output_two=1'b0;
    2'b10:  c_output_two=1'b1;
    default:c_output_two=1'b0;
    endcase
end
always@(*)begin
    case({level3_three_data2[3],level3_three_data1[3]})
    2'b01:  d_output_two=1'b0;
    2'b10:  d_output_two=1'b1;
    default:d_output_two=1'b0;
    endcase
end
always@(*)begin
    case({level3_three_data2[4],level3_three_data1[4]})
    2'b01:  e_output_two=1'b0;
    2'b10:  e_output_two=1'b1;
    default:e_output_two=1'b0;
    endcase
end







///////////////////////////////////split line//////////////////////
always@(*)begin
    case({level2_three_data2[0],level2_three_data1[0]})
    2'b01:a_output_one=1'b0;
    2'b10:a_output_one=1'b1;
    default:a_output_one=1'b0;
    endcase
end
always@(*)begin
    case({level2_three_data2[1],level2_three_data1[1]})
    2'b01:b_output_one=1'b0;
    2'b10:b_output_one=1'b1;
    default:b_output_one=1'b0;
    endcase
end
always@(*)begin
    case({level2_three_data2[2],level2_three_data1[2]})
    2'b01:c_output_one=1'b0;
    2'b10:c_output_one=1'b1;
    default:c_output_one=1'b0;
    endcase
end


always@(*)begin
    case({level2_three_data2[3],level2_three_data1[3]})
    2'b01:d_output_one=1'b0;
    2'b10:d_output_one=1'b1;
    default:d_output_one=1'b0;
    endcase
end
always@(*)begin
    case({level2_three_data2[4],level2_three_data1[4]})
    2'b01:e_output_one=1'b0;
    2'b10:e_output_one=1'b1;
    default:e_output_one=1'b0;
    endcase
end






// 5bit frequency + 5bit tag
// Block_1 small
always@(*)begin
    //a_output = 4'b0;
    case({five_data2[0],five_data1[0]})
    2'b01:  a_output=1'b0;
    2'b10:  a_output=1'b1;
    default:a_output=1'b0;   
    endcase
end
always@(*)begin
    //b_output = 4'b0;
    case({five_data2[1],five_data1[1]})
    2'b01:  b_output=1'b0;
    2'b10:  b_output=1'b1;
    default:b_output=1'b0;  
    endcase
end
always@(*)begin
    //c_output = 4'b0;
    case({five_data2[2],five_data1[2]})
    2'b01:  c_output=1'b0;
    2'b10:  c_output=1'b1;
    default:c_output=1'b0;  
    endcase
end
always@(*)begin
    //d_output = 4'b0;
    case({five_data2[3],five_data1[3]})
    2'b01:  d_output=1'b0;
    2'b10:  d_output=1'b1;
    default:d_output=1'b0;  
    endcase
end

always@(*)begin
    //e_output = 4'b0;
    case({five_data2[4],five_data1[4]})
    2'b01:  e_output=1'b0;
    2'b10:  e_output=1'b1;
    default:e_output=1'b0;  
    endcase
end


//////////////////////////encode_two_array[x][0]
assign encode_two_array[0][0] = (!five_data2[0] & five_data1[0]) | 
                                (five_data2[0] & !five_data1[0]);

assign encode_two_array[1][0] = (!five_data2[1] & five_data1[1]) | 
                                (five_data2[1] & !five_data1[1]);

assign encode_two_array[2][0] = (!five_data2[2] & five_data1[2]) | 
                                (five_data2[2] & !five_data1[2]);

assign encode_two_array[3][0] = (!five_data2[3] & five_data1[3]) | 
                                (five_data2[3] & !five_data1[3]);

assign encode_two_array[4][0] = (!five_data2[4] & five_data1[4]) | 
                                (five_data2[4] & !five_data1[4]);
 
//////////////////////////encode_two_array[x][1]
assign encode_two_array[0][1] = (!level2_three_data2[0] & level2_three_data1[0]) | 
                                (level2_three_data2[0] & !level2_three_data1[0]);

assign encode_two_array[1][1] = (!level2_three_data2[1] & level2_three_data1[1]) | 
                                (level2_three_data2[1] & !level2_three_data1[1]);

assign encode_two_array[2][1] = (!level2_three_data2[2] & level2_three_data1[2]) | 
                                (level2_three_data2[2] & !level2_three_data1[2]);

assign encode_two_array[3][1] = (!level2_three_data2[3] & level2_three_data1[3]) | 
                                (level2_three_data2[3] & !level2_three_data1[3]);

assign encode_two_array[4][1] = (!level2_three_data2[4] & level2_three_data1[4]) | 
                                (level2_three_data2[4] & !level2_three_data1[4]);



//////////////////////////encode_two_array[x][2]
assign encode_two_array[0][2] = (!level3_three_data2[0] & level3_three_data1[0]) | 
                                (level3_three_data2[0] & !level3_three_data1[0]);

assign encode_two_array[1][2] = (!level3_three_data2[1] & level3_three_data1[1]) | 
                                (level3_three_data2[1] & !level3_three_data1[1]);

assign encode_two_array[2][2] = (!level3_three_data2[2] & level3_three_data1[2]) | 
                                (level3_three_data2[2] & !level3_three_data1[2]);

assign encode_two_array[3][2] = (!level3_three_data2[3] & level3_three_data1[3]) | 
                                (level3_three_data2[3] & !level3_three_data1[3]);

assign encode_two_array[4][2] = (!level3_three_data2[4] & level3_three_data1[4]) | 
                                (level3_three_data2[4] & !level3_three_data1[4]);

//////////////////////////encode_two_array[x][3]
assign encode_two_array[0][3] = (!level4_three_data2[0] & level4_three_data1[0]) | 
                                (level4_three_data2[0] & !level4_three_data1[0]);
//assign encode_two_array[0][3]=(level4_three_data2[0] & !level4_three_data1[0])?1'b1:(!level4_three_data2[0] & level4_three_data1[0])?1'b1:1'b0;
assign encode_two_array[1][3] = (!level4_three_data2[1] & level4_three_data1[1]) | 
                                (level4_three_data2[1] & !level4_three_data1[1]);

assign encode_two_array[2][3] = (!level4_three_data2[2] & level4_three_data1[2]) | 
                                (level4_three_data2[2] & !level4_three_data1[2]);

assign encode_two_array[3][3] = (!level4_three_data2[3] & level4_three_data1[3]) | 
                                (level4_three_data2[3] & !level4_three_data1[3]);

assign encode_two_array[4][3] = (!level4_three_data2[4] & level4_three_data1[4]) | 
                                (level4_three_data2[4] & !level4_three_data1[4]);
/*
integer i,j;
always@(*)begin
    for (i = 0; i < 5; i = i + 1) begin
        for (j = 0; j < 4; j = j + 1) begin
            encode_two_array[i][j] = 1'b1;
            $display("encode_two_array[%d][%d]=[%d]",i,j,encode_two_array[i][j]);
        end
    end

end*/

// Block_1 big //////////////////////////////////split ///////////////////
/*
always@(*)begin
    case(1) // synopsys parallel_case
    (five_data2[4]==1'b0 & five_data1[4]==1'b1):e_output={zero_4bit,1'b0};
    (five_data2[4]==1'b1 & five_data1[4]==1'b0):e_output={zero_4bit,1'b1};
    default:e_output=4'b0;
    endcase
    
end
*/


always @(*) begin
    out_encoded = {a_output_four[0], a_output_four[1], a_output_four[2], a_output_four[3],
                   b_output_four[0], b_output_four[1], b_output_four[2], b_output_four[3],
                   c_output_four[0], c_output_four[1], c_output_four[2], c_output_four[3],
                   d_output_four[0], d_output_four[1], d_output_four[2], d_output_four[3],
                   e_output_four[0], e_output_four[1], e_output_four[2], e_output_four[3]};
end




endmodule
/*
module encoding(
    input  data2,data1,
    output [3:0] out;
);*/





//Sorted five element module
module Sorted_five_element(
    input       [12:0]  input_1, input_2, input_3, input_4, input_5,
    output reg  [12:0] output_1,output_2,output_3,output_4,output_5 //smallest to biggest
);
//output_5 biggest
always@(*)begin
    case(1) // synopsys parallel_case
    (input_1>input_2 & input_1>input_3 & input_1>input_4 & input_1>input_5):output_5=input_1;  
    (input_2>input_1 & input_2>input_3 & input_2>input_4 & input_2>input_5):output_5=input_2;
    (input_3>input_1 & input_3>input_2 & input_3>input_4 & input_3>input_5):output_5=input_3;
    (input_4>input_1 & input_4>input_2 & input_4>input_3 & input_4>input_5):output_5=input_4;
    default:output_5=input_5;
    endcase
end
//output_4
always @(*) begin
    case(1) // synopsys parallel_case
        ((input_1 > input_2 & input_1 > input_3 & input_1 > input_4 & input_1 < input_5) | 
         (input_1 > input_2 & input_1 > input_3 & input_1 > input_5 & input_1 < input_4) | 
         (input_1 > input_2 & input_1 > input_4 & input_1 > input_5 & input_1 < input_3) | 
         (input_1 > input_3 & input_1 > input_4 & input_1 > input_5 & input_1 < input_2)) : output_4 = input_1;

        ((input_2 > input_1 & input_2 > input_3 & input_2 > input_4 & input_2 < input_5) | 
         (input_2 > input_1 & input_2 > input_3 & input_2 > input_5 & input_2 < input_4) | 
         (input_2 > input_1 & input_2 > input_4 & input_2 > input_5 & input_2 < input_3) | 
         (input_2 > input_3 & input_2 > input_4 & input_2 > input_5 & input_2 < input_1)) : output_4 = input_2;

        ((input_3 > input_1 & input_3 > input_2 & input_3 > input_4 & input_3 < input_5) | 
         (input_3 > input_1 & input_3 > input_2 & input_3 > input_5 & input_3 < input_4) | 
         (input_3 > input_1 & input_3 > input_4 & input_3 > input_5 & input_3 < input_2) | 
         (input_3 > input_2 & input_3 > input_4 & input_3 > input_5 & input_3 < input_1)) : output_4 = input_3;

        ((input_4 > input_1 & input_4 > input_2 & input_4 > input_3 & input_4 < input_5) | 
         (input_4 > input_1 & input_4 > input_2 & input_4 > input_5 & input_4 < input_3) | 
         (input_4 > input_1 & input_4 > input_3 & input_4 > input_5 & input_4 < input_2) | 
         (input_4 > input_2 & input_4 > input_3 & input_4 > input_5 & input_4 < input_1)) : output_4 = input_4;

        /*((input_5 > input_1 & input_5 > input_2 & input_5 > input_3 & input_5 < input_4) | 
         (input_5 > input_1 & input_5 > input_2 & input_5 > input_4 & input_5 < input_3) | 
         (input_5 > input_1 & input_5 > input_3 & input_5 > input_4 & input_5 < input_2) | 
         (input_5 > input_2 & input_5 > input_3 & input_5 > input_4 & input_5 < input_1)) : output_4 = input_5;*/
        default : output_4 = input_5;
    endcase
end
///output_3
always @(*) begin
    case(1) // synopsys parallel_case
        ((input_1 > input_2 & input_1 > input_3 & input_1 < input_4 & input_1 < input_5) | 
         (input_1 > input_2 & input_1 > input_4 & input_1 < input_3 & input_1 < input_5) | 
         (input_1 > input_2 & input_1 > input_5 & input_1 < input_3 & input_1 < input_4) | 
         (input_1 > input_3 & input_1 > input_4 & input_1 < input_2 & input_1 < input_5) | 
         (input_1 > input_3 & input_1 > input_5 & input_1 < input_2 & input_1 < input_4) | 
         (input_1 > input_4 & input_1 > input_5 & input_1 < input_2 & input_1 < input_3)) : output_3 = input_1;

        ((input_2 > input_1 & input_2 > input_3 & input_2 < input_4 & input_2 < input_5) | 
         (input_2 > input_1 & input_2 > input_4 & input_2 < input_3 & input_2 < input_5) | 
         (input_2 > input_1 & input_2 > input_5 & input_2 < input_3 & input_2 < input_4) | 
         (input_2 > input_3 & input_2 > input_4 & input_2 < input_1 & input_2 < input_5) | 
         (input_2 > input_3 & input_2 > input_5 & input_2 < input_1 & input_2 < input_4) | 
         (input_2 > input_4 & input_2 > input_5 & input_2 < input_1 & input_2 < input_3)) : output_3 = input_2;
        
        ((input_3 > input_1 & input_3 > input_2 & input_3 < input_4 & input_3 < input_5) | 
         (input_3 > input_1 & input_3 > input_4 & input_3 < input_2 & input_3 < input_5) | 
         (input_3 > input_1 & input_3 > input_5 & input_3 < input_2 & input_3 < input_4) | 
         (input_3 > input_2 & input_3 > input_4 & input_3 < input_1 & input_3 < input_5) | 
         (input_3 > input_2 & input_3 > input_5 & input_3 < input_1 & input_3 < input_4) | 
         (input_3 > input_4 & input_3 > input_5 & input_3 < input_1 & input_3 < input_2)) : output_3 = input_3;
        
        ((input_4 > input_1 & input_4 > input_2 & input_4 < input_3 & input_4 < input_5) | 
         (input_4 > input_1 & input_4 > input_3 & input_4 < input_2 & input_4 < input_5) | 
         (input_4 > input_1 & input_4 > input_5 & input_4 < input_2 & input_4 < input_3) | 
         (input_4 > input_2 & input_4 > input_3 & input_4 < input_1 & input_4 < input_5) | 
         (input_4 > input_2 & input_4 > input_5 & input_4 < input_1 & input_4 < input_3) | 
         (input_4 > input_3 & input_4 > input_5 & input_4 < input_1 & input_4 < input_2)) : output_3 = input_4;
        /*
        ((input_5 > input_1 & input_5 > input_2 & input_5 < input_3 & input_5 < input_4) | 
         (input_5 > input_1 & input_5 > input_3 & input_5 < input_2 & input_5 < input_4) | 
         (input_5 > input_1 & input_5 > input_4 & input_5 < input_2 & input_5 < input_3) | 
         (input_5 > input_2 & input_5 > input_3 & input_5 < input_1 & input_5 < input_4) | 
         (input_5 > input_2 & input_5 > input_4 & input_5 < input_1 & input_5 < input_3) | 
         (input_5 > input_3 & input_5 > input_4 & input_5 < input_1 & input_5 < input_2)) : output_3 = input_5;*/

        default : output_3 = input_5; 
    endcase
end
///output_2
always @(*) begin
    case(1) // synopsys parallel_case
        ((input_1 > input_2 & input_1 < input_3 & input_1 < input_4 & input_1 < input_5) | 
         (input_1 > input_3 & input_1 < input_2 & input_1 < input_4 & input_1 < input_5) | 
         (input_1 > input_4 & input_1 < input_2 & input_1 < input_3 & input_1 < input_5) | 
         (input_1 > input_5 & input_1 < input_2 & input_1 < input_3 & input_1 < input_4)) : output_2 = input_1;

        ((input_2 > input_1 & input_2 < input_3 & input_2 < input_4 & input_2 < input_5) | 
         (input_2 > input_3 & input_2 < input_1 & input_2 < input_4 & input_2 < input_5) | 
         (input_2 > input_4 & input_2 < input_1 & input_2 < input_3 & input_2 < input_5) | 
         (input_2 > input_5 & input_2 < input_1 & input_2 < input_3 & input_2 < input_4)) : output_2 = input_2;

        ((input_3 > input_1 & input_3 < input_2 & input_3 < input_4 & input_3 < input_5) | 
         (input_3 > input_2 & input_3 < input_1 & input_3 < input_4 & input_3 < input_5) | 
         (input_3 > input_4 & input_3 < input_1 & input_3 < input_2 & input_3 < input_5) | 
         (input_3 > input_5 & input_3 < input_1 & input_3 < input_2 & input_3 < input_4)) : output_2 = input_3;

        ((input_4 > input_1 & input_4 < input_2 & input_4 < input_3 & input_4 < input_5) | 
         (input_4 > input_2 & input_4 < input_1 & input_4 < input_3 & input_4 < input_5) | 
         (input_4 > input_3 & input_4 < input_1 & input_4 < input_2 & input_4 < input_5) | 
         (input_4 > input_5 & input_4 < input_1 & input_4 < input_2 & input_4 < input_3)) : output_2 = input_4;

        /*((input_5 > input_1 & input_5 < input_2 & input_5 < input_3 & input_5 < input_4) | 
         (input_5 > input_2 & input_5 < input_1 & input_5 < input_3 & input_5 < input_4) | 
         (input_5 > input_3 & input_5 < input_1 & input_5 < input_2 & input_5 < input_4) | 
         (input_5 > input_4 & input_5 < input_1 & input_5 < input_2 & input_5 < input_3)) : output_2 = input_5;*/

        default : output_2 = input_5; 
    endcase
end

///output_1
always@(*)begin
    case(1) // synopsys parallel_case
    (input_1<input_2 & input_1<input_3 & input_1<input_4 & input_1<input_5):output_1=input_1;  
    (input_2<input_1 & input_2<input_3 & input_2<input_4 & input_2<input_5):output_1=input_2;
    (input_3<input_1 & input_3<input_2 & input_3<input_4 & input_3<input_5):output_1=input_3;
    (input_4<input_1 & input_4<input_2 & input_4<input_3 & input_4<input_5):output_1=input_4;
    default:output_1=input_5;
    endcase
end


endmodule