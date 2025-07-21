//############################################################################
//   2025 ICLAB Spring Course
//   Sparse Matrix Multiplier (SMM)
//############################################################################

module SMM(
  // Input Port
  clk,
  rst_n,
  in_valid_size,
  in_size,
  in_valid_a,
  in_row_a,
  in_col_a,
  in_val_a,
  in_valid_b,
  in_row_b,
  in_col_b,
  in_val_b,
  // Output Port
  out_valid,
  out_row,
  out_col,
  out_val
);



//==============================================//
//                   PARAMETER                  //
//==============================================//



//==============================================//
//                   I/O PORTS                  //
//==============================================//
input             clk, rst_n, in_valid_size, in_valid_a, in_valid_b;
input             in_size;
input      [4:0]  in_row_a, in_col_a, in_row_b, in_col_b;
input      [3:0]  in_val_a, in_val_b;
output reg        out_valid;
output reg [4:0]  out_row, out_col;
output reg [8:0] out_val;

reg [8:0]matrix[0:31][0:31];
reg [8:0]matrix_a[0:31][0:31];
reg [8:0]matrix_b[0:31][0:31];
reg [8:0]temp0, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8, temp9, temp10, temp11, temp12, temp13, temp14, temp15, temp16, temp17, temp18, temp19, temp20, temp21, temp22, temp23, temp24, temp25, temp26, temp27, temp28, temp29, temp30, temp31;
reg [8:0]add;
reg [8:0]add_wire;
reg [8:0]total;
reg [8:0]x[0:63];
reg [8:0]y[0:63];
reg [8:0]value[0:63];
integer i,j;
//==============================================//
//            reg & wire declaration            //
//==============================================//
reg [10:0]counter;
reg [4:0]counter_x,counter_y,counter_1,counter_2;
reg [4:0]counter_s,counter_t;
reg [3:0]current_state,next_state;
always@(*)begin
  temp0=0; temp1=0; temp2=0; temp3=0; temp4=0; temp5=0; temp6=0; temp7=0; temp8=0; temp9=0; temp10=0; temp11=0; temp12=0; temp13=0; temp14=0; temp15=0; temp16=0; temp17=0; temp18=0; temp19=0; temp20=0; temp21=0; temp22=0; temp23=0; temp24=0; temp25=0; temp26=0; temp27=0; temp28=0; temp29=0; temp30=0; temp31=0; 
    if(current_state==2)begin
      temp0 =matrix_a[0+counter_x][ 0+counter_y]*matrix_b[ 0+counter_1][0+counter_2];
      temp1 =matrix_a[0+counter_x][ 1+counter_y]*matrix_b[ 1+counter_1][0+counter_2];
      temp2 =matrix_a[0+counter_x][ 2+counter_y]*matrix_b[ 2+counter_1][0+counter_2];
      temp3 =matrix_a[0+counter_x][ 3+counter_y]*matrix_b[ 3+counter_1][0+counter_2];
      temp4 =matrix_a[0+counter_x][ 4+counter_y]*matrix_b[ 4+counter_1][0+counter_2];
      temp5 =matrix_a[0+counter_x][ 5+counter_y]*matrix_b[ 5+counter_1][0+counter_2];
      temp6 =matrix_a[0+counter_x][ 6+counter_y]*matrix_b[ 6+counter_1][0+counter_2];
      temp7 =matrix_a[0+counter_x][ 7+counter_y]*matrix_b[ 7+counter_1][0+counter_2];
      temp8 =matrix_a[0+counter_x][ 8+counter_y]*matrix_b[ 8+counter_1][0+counter_2];
      temp9 =matrix_a[0+counter_x][ 9+counter_y]*matrix_b[ 9+counter_1][0+counter_2];
      temp10=matrix_a[0+counter_x][10+counter_y]*matrix_b[10+counter_1][0+counter_2];
      temp11=matrix_a[0+counter_x][11+counter_y]*matrix_b[11+counter_1][0+counter_2];
      temp12=matrix_a[0+counter_x][12+counter_y]*matrix_b[12+counter_1][0+counter_2];
      temp13=matrix_a[0+counter_x][13+counter_y]*matrix_b[13+counter_1][0+counter_2];
      temp14=matrix_a[0+counter_x][14+counter_y]*matrix_b[14+counter_1][0+counter_2];
      temp15=matrix_a[0+counter_x][15+counter_y]*matrix_b[15+counter_1][0+counter_2];
      temp16=matrix_a[0+counter_x][16+counter_y]*matrix_b[16+counter_1][0+counter_2];
      temp17=matrix_a[0+counter_x][17+counter_y]*matrix_b[17+counter_1][0+counter_2];
      temp18=matrix_a[0+counter_x][18+counter_y]*matrix_b[18+counter_1][0+counter_2];
      temp19=matrix_a[0+counter_x][19+counter_y]*matrix_b[19+counter_1][0+counter_2];
      temp20=matrix_a[0+counter_x][20+counter_y]*matrix_b[20+counter_1][0+counter_2];
      temp21=matrix_a[0+counter_x][21+counter_y]*matrix_b[21+counter_1][0+counter_2];
      temp22=matrix_a[0+counter_x][22+counter_y]*matrix_b[22+counter_1][0+counter_2];
      temp23=matrix_a[0+counter_x][23+counter_y]*matrix_b[23+counter_1][0+counter_2];
      temp24=matrix_a[0+counter_x][24+counter_y]*matrix_b[24+counter_1][0+counter_2];
      temp25=matrix_a[0+counter_x][25+counter_y]*matrix_b[25+counter_1][0+counter_2];
      temp26=matrix_a[0+counter_x][26+counter_y]*matrix_b[26+counter_1][0+counter_2];
      temp27=matrix_a[0+counter_x][27+counter_y]*matrix_b[27+counter_1][0+counter_2];
      temp28=matrix_a[0+counter_x][28+counter_y]*matrix_b[28+counter_1][0+counter_2];
      temp29=matrix_a[0+counter_x][29+counter_y]*matrix_b[29+counter_1][0+counter_2];
      temp30=matrix_a[0+counter_x][30+counter_y]*matrix_b[30+counter_1][0+counter_2];
      temp31=matrix_a[0+counter_x][31+counter_y]*matrix_b[31+counter_1][0+counter_2];
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        add<=0;
    else if(current_state==2)
        add<=temp0+temp1+temp2+temp3+temp4+temp5+temp6+temp7+temp8+temp9+temp10+temp11+temp12+temp13+temp14+temp15+temp16+temp17+temp18+temp19+temp20+temp21+temp22+temp23+temp24+temp25+temp26+temp27+temp28+temp29+temp30+temp31;
end
always@(*)begin
  add_wire=0;
  if(current_state==2)
    add_wire=temp0+temp1+temp2+temp3+temp4+temp5+temp6+temp7+temp8+temp9+temp10+temp11+temp12+temp13+temp14+temp15+temp16+temp17+temp18+temp19+temp20+temp21+temp22+temp23+temp24+temp25+temp26+temp27+temp28+temp29+temp30+temp31;

end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        current_state<=0;
    else 
        current_state<=next_state;
end
//////////////////////////////////////////////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        counter<=0;
    else if(next_state==0)
        counter<=0;
    else if(current_state==2)
        counter<=counter+1'b1;
end
//////////////////////////////////////////////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        counter_x<=0;
    else if(next_state==0)
        counter_x<=0;
    else if(current_state==2)
        if(counter_2==31)
        counter_x<=counter_x+1'b1;
        else
        counter_x<=counter_x;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        counter_y<=0;
    else if(next_state==0)
        counter_y<=0;
    else if(current_state==2)
        //counter_y<=counter_y+1'b1;
        counter_y<=0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        counter_1<=0;
    else if(next_state==0)
        counter_1<=0;
    else if(current_state==2)
        //counter_1<=counter_1+1'b1;
        counter_1<=0;
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        counter_2<=0;
    else if(next_state==0)
        counter_2<=0;
    else if(current_state==2)
        //counter_2<=counter_2+1'b1;
        if(counter_2==31)
          counter_2<=0;
        else 
          counter_2<=counter_2+1'b1;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        counter_s<=0;
    else if(next_state==0)
        counter_s<=0;
    else if(current_state==2&&counter>=600)
        if(counter_s==31)
        counter_s<=0;
        
        else 
        counter_s<=counter_s+1'b1;
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        counter_t<=0;
    else if(next_state==0)
        counter_t<=0;
    else if(current_state==2&&counter>=600  )
        if(counter_s==31)
        counter_t<=counter_t+1'b1;

        else 
        counter_t<=counter_t;
end
always@(*)begin
    case(current_state)
        0:begin
            next_state=(in_valid_a||in_valid_b)? 1:0;
        end
        1:begin  
            next_state=(in_valid_a==0 &&in_valid_b==0)?2:1;
            
        end
        2:begin 
            //next_state=(counter_x==31 &&counter_2==31)?3:2;

            next_state=(counter_s==31 &&counter_t==31)?4:2;        
        end
        /*3:begin
            next_state=(counter_s==31 &&counter_t==31)?4:3;
            
        end*/
        4:begin
          next_state=(total==1)?0:4;
        end
    default:next_state=0;
    endcase

end
reg [8:0]cnt;
/*
always@(*)begin
  if(current_state==3)
    for (int i=0;i<64;i=i+1)begin
          for (int j=0;j<64;j=j+1)begin
              if(matrix[i][j]!=0)
          end
    end



end*/
always@(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    total<=0;
    for (int i=0;i<64;i=i+1)begin
          x[i]<=0;
          y[i]<=0;
          value[i]<=0;
    end
  cnt<=0;
  end
  else if(next_state==0)begin
    total<=0;
    for (int i=0;i<64;i=i+1)begin
          x[i]<=0;
          y[i]<=0;
          value[i]<=0;
    end
  cnt<=0;
  end
  else if(current_state==2 &&counter>=600)begin
      if(matrix[counter_t][counter_s]!=0)begin
        x[cnt]<=counter_t;
        y[cnt]<=counter_s;
        value[cnt]<=matrix[counter_t][counter_s];
        total<=total+1'b1;
        cnt<=cnt+1'b1;
      end
  end
  else if(current_state==4)
    if(total>0)begin
      total<=total-1'b1;
        for (int i=1;i<64;i=i+1)begin
          x[i-1]<=   x[i];
          y[i-1]<=   y[i];
          value[i-1]<=value[i];
        end
    end
end
//==============================================//
//                   Design                     //
//==============================================//
always@(posedge clk or negedge rst_n)begin
  if(!rst_n)
    for (int i=0;i<32;i=i+1)begin
        for (int j=0;j<32;j=j+1)begin
          matrix_a[i][j]<=0;
        end
    end
  else if(next_state==0)begin
    for (int i=0;i<32;i=i+1)begin
        for (int j=0;j<32;j=j+1)begin
          matrix_a[i][j]<=0;
        end
    end


  end
  else if(in_valid_a)begin
    for (int i=0;i<32;i=i+1)begin
        for (int j=0;j<32;j=j+1)begin
         if(i==in_row_a && j==in_col_a)
            matrix_a[i][j]<=in_val_a;
        end
    end
  end
  
end

always@(posedge clk or negedge rst_n)begin
  if(!rst_n)
    for (int i=0;i<32;i=i+1)begin
        for (int j=0;j<32;j=j+1)begin
          matrix_b[i][j]<=0 ;
        end
    end
    else if(next_state==0)begin
    for (int i=0;i<32;i=i+1)begin
        for (int j=0;j<32;j=j+1)begin
          matrix_b[i][j]<=0;
        end
    end
    end
  else if(in_valid_b)begin
    for (int i=0;i<32;i=i+1)begin
        for (int j=0;j<32;j=j+1)begin
         if(i==in_row_b && j==in_col_b)
            matrix_b[i][j]<=in_val_b;
        end
    end
  end
end

always@(posedge clk or negedge rst_n)begin
  if(!rst_n)
    for (int i=0;i<32;i=i+1)begin
        for (int j=0;j<32;j=j+1)begin
          matrix[i][j]<=0 ;
        end
    end

      else if(next_state==0)begin
        for (int i=0;i<32;i=i+1)begin
        for (int j=0;j<32;j=j+1)begin
          matrix[i][j]<=0 ;
        end
        end

  end
  else if(current_state==2)begin
    if(add_wire!=0)
           matrix[counter_x][counter_2]<=add_wire;


  end
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    out_valid <= 1'b0;
  else if(current_state==4)
		out_valid <= 1'b1;	
  else 	
    out_valid <= 1'b0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
    out_row<= 5'b0;
  else if(current_state==4)
		out_row<= x[0];
  else 
    out_row<=0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
    out_col<= 5'b0;
  else if(current_state==4)
		out_col<=y[0];
  else 
    out_col<=0;
end
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
    out_val<= 9'b0;
  else if(current_state==4)
		out_val<= value[0];
  else 
  		out_val<= 9'b0;
end

endmodule