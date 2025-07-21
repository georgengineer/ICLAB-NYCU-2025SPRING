module MVDM(
    // input signals
    clk,
    rst_n,
    in_valid, 
    in_valid2,
    in_data,
    // output signals
    out_valid,
    out_sad
    );

input clk;
input rst_n;
input in_valid;
input in_valid2;
input [11:0] in_data;

output reg out_valid;
output reg out_sad;



//=======================================================
//                   Memory Control Reg 
//=======================================================
reg [13:0]SRAM_16384X8_L0_addr ,SRAM_16384X8_L1_addr;
reg[7:0]SRAM_16384X8_L0_in_reg ,SRAM_16384X8_L1_in_reg;
reg[7:0]SRAM_16384X8_L0_out_reg,SRAM_16384X8_L1_out_reg;
reg SRAM_16384X8_L0_WEB,SRAM_16384X8_L1_WEB;
//=======================================================
//                   Reg/Wire
//=======================================================

//===== FSM =====
reg [3:0]next_state;
reg [3:0]current_state;


reg in_valid_reg;
wire[7:0]data_wire;
assign data_wire=in_data[11:4];
reg [11:0]MV_reg[0:7];
reg [8:0]MV_counter;
integer i,j;

reg [11:0]L0_reg[0:10];
reg [11:0]L1_reg[0:10];
reg [7:0]L0_A1_temp[0:2];
reg [7:0]L0_A2_temp[0:2];

reg [11:0]L0_B1_temp[0:3];
reg [11:0]L1_B1_temp[0:3];
reg [7:0]L1_A1_temp[0:2];
reg [7:0]L1_A2_temp[0:2];

reg L0_compare;
reg L1_compare;
reg L0_B1_compare;
reg L1_B1_compare;

reg [11:0]L0_A1_compare;
reg [11:0]L0_A1_compare_2;
reg [15:0]L0_A2_compare;
reg [15:0]L0_A2_compare_2;
reg [15:0]L0_BI[0:9][0:9];

reg [11:0]L1_A1_compare;
reg [11:0]L1_A1_compare_2;
reg [15:0]L1_A2_compare;
reg [15:0]L1_A2_compare_2;
reg [15:0]L1_BI[0:9][0:9];

reg [7:0]L0_BI_counter;
reg [55:0]out_reg;
reg [5:0]out_counter;
wire MV_counter_divide_two_equal_zero;
wire MV_counter_divide_two_equal_one;

assign MV_counter_divide_two_equal_zero=(MV_counter%2==0)?1'b1:1'b0;
assign MV_counter_divide_two_equal_one=(MV_counter%2==1)?1'b1:1'b0;

//WEB =1'b0 write in memory mode
//WEB =1'b1 read from memory mode
//16384X8  means [7:0]SRAM[0:16383]
SRAM_16384X8_one SRAM_16384X8_L0(.CLK(clk),.CS(1'b1),.OE(1'b1), .WEB(SRAM_16384X8_L0_WEB), .A(SRAM_16384X8_L0_addr), .DI(SRAM_16384X8_L0_in_reg), .DO(SRAM_16384X8_L0_out_reg));
SRAM_16384X8_one SRAM_16384X8_L1(.CLK(clk),.CS(1'b1),.OE(1'b1), .WEB(SRAM_16384X8_L1_WEB), .A(SRAM_16384X8_L1_addr), .DI(SRAM_16384X8_L1_in_reg), .DO(SRAM_16384X8_L1_out_reg));

//=======================================================
//                   Design
//=======================================================


//FSM
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        current_state<=0;
    end
    else begin
        current_state<=next_state;
    end
end
//FSM combinational logic
always@(*)begin
    case(current_state)
    0:begin 
        if(in_valid==1'b1)
            next_state=1;
        else if(in_valid2==1'b1)
            next_state=4;
        else 
            next_state=0;
    end
    1:      next_state=(SRAM_16384X8_L0_addr==16383)?2:1;
    2:      next_state=(SRAM_16384X8_L1_addr==16383)?3:2;
    3:      next_state=(in_valid2)?4:3;
    4:      next_state=(MV_counter==313)?5:4;
    5:      next_state=(MV_counter==313)?6:5;
    6:      next_state=(MV_counter==55)?0:6;
    default:next_state=0;

    endcase
end
always@(posedge clk or negedge rst_n)begin //in_valid_reg
    if(!rst_n)begin
        in_valid_reg<=0;
    end  
    else if(in_valid)begin
        in_valid_reg<=1'b1;
    end
    else begin
        in_valid_reg<=1'b0;
    end
end

always@(posedge clk or negedge rst_n)begin //SRAM_16384X8_L0_WEB
    if(!rst_n)begin
        SRAM_16384X8_L0_WEB<=1'b1;
    end
    else if(next_state==1'b1)
        SRAM_16384X8_L0_WEB<=1'b0;//write in memory
    else begin
        SRAM_16384X8_L0_WEB<=1'b1;
    end

end
always@(posedge clk or negedge rst_n)begin //SRAM_16384X8_L1_WEB
    if(!rst_n)begin
        SRAM_16384X8_L1_WEB<=1'b1;
    end

    else if(next_state==2) begin
        SRAM_16384X8_L1_WEB<=1'b0;//write in memory
    end
    else begin
        SRAM_16384X8_L1_WEB<=1'b1;
    end

end

always@(posedge clk or negedge rst_n)begin //SRAM_16384X8_L0_addr
    if(!rst_n)begin
        SRAM_16384X8_L0_addr<=0;
    end 
    else if(next_state==0)
        SRAM_16384X8_L0_addr<=0;
    else if(in_valid_reg)begin
        SRAM_16384X8_L0_addr<=SRAM_16384X8_L0_addr+1'b1;
    end
    else if(current_state==5 && MV_counter>=2)begin
        if(MV_counter==2)
            SRAM_16384X8_L0_addr<=(MV_reg[5][11:4]<<7)+(MV_reg[4][11:4]); 
        else if(MV_counter%11==2)
            SRAM_16384X8_L0_addr<=SRAM_16384X8_L0_addr+118;
        else if(MV_counter>2)
            SRAM_16384X8_L0_addr<=SRAM_16384X8_L0_addr+1'b1;
    end    
    else if(current_state==4 && MV_counter>=2)begin
        if(MV_counter==2)
            SRAM_16384X8_L0_addr<=(MV_reg[1][11:4]<<7)+(MV_reg[0][11:4]); //1167
        else if(MV_counter%11==2)
            SRAM_16384X8_L0_addr<=SRAM_16384X8_L0_addr+118;
        else if(MV_counter>2)
            SRAM_16384X8_L0_addr<=SRAM_16384X8_L0_addr+1'b1;
    end
    else begin
        SRAM_16384X8_L0_addr<=SRAM_16384X8_L0_addr;
    end
end

always@(posedge clk or negedge rst_n)begin //SRAM_16384X8_L1_addr
    if(!rst_n)begin
        SRAM_16384X8_L1_addr<=0;
    end    
    else if(next_state==0)
        SRAM_16384X8_L1_addr<=0;
    else if(in_valid_reg)begin
        SRAM_16384X8_L1_addr<=SRAM_16384X8_L1_addr+1'b1; 
    end
    else if(current_state==5 && MV_counter>=4)begin
        if(MV_counter==4)
            SRAM_16384X8_L1_addr<=(MV_reg[7][11:4]<<7)+(MV_reg[6][11:4]); 
        else if(MV_counter%11==4)
            SRAM_16384X8_L1_addr<=SRAM_16384X8_L1_addr+118;
        else if(MV_counter>4)
            SRAM_16384X8_L1_addr<=SRAM_16384X8_L1_addr+1'b1;
    end    
    else if(current_state==4 && MV_counter>=4)begin
        if(MV_counter==4)
            SRAM_16384X8_L1_addr<=(MV_reg[3][11:4]<<7)+(MV_reg[2][11:4]); //1167
        else if(MV_counter%11==4)
            SRAM_16384X8_L1_addr<=SRAM_16384X8_L1_addr+118;
        else if(MV_counter>4)
            SRAM_16384X8_L1_addr<=SRAM_16384X8_L1_addr+1'b1;
    end
    else begin
        SRAM_16384X8_L1_addr<=SRAM_16384X8_L1_addr;
    end
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(int i=0;i<11;i=i+1)begin
            L0_reg[i]<=0;
        end
    end
    else if(next_state==0)begin
        for(int i=0;i<11;i=i+1)begin
            L0_reg[i]<=0;
        end
    end
    //else if((current_state==4 && MV_counter>=8)||(current_state==5 && MV_counter>=8))begin
    else if (MV_counter == 18 || MV_counter == 29 || MV_counter == 40 || MV_counter == 51 ||
            MV_counter == 62 || MV_counter == 73 || MV_counter == 84 || MV_counter == 95 ||
            MV_counter == 106 || MV_counter == 117) begin
            for(int i=0;i<11;i=i+1)begin
                L0_reg[i]<=L0_reg[i];
            end
    end
    else begin         
        L0_reg[0]<=L0_A1_compare_2;
        for(int i=1;i<11;i=i+1)begin
            L0_reg[i]<=L0_reg[i-1];
        end
    end
        
    
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(int i=0;i<3;i=i+1)begin
            L0_A1_temp[i]<=0; 
        end
    end

    //else if((current_state==4 && MV_counter>=4)||(current_state==5 && MV_counter>=4))begin
    else begin
        L0_A1_temp[2]<=SRAM_16384X8_L0_out_reg;
        L0_A1_temp[1]<=L0_A1_temp[2];
        L0_A1_temp[0]<=L0_A1_temp[1];
    end
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        L0_compare<=0;
    else begin
        if(L0_A1_temp[2]>=L0_A1_temp[1])
            L0_compare<=1'b1;
        else
            L0_compare<=1'b0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L0_A1_compare<=0;
    end
    else begin
        if(L0_A1_temp[2]>=L0_A1_temp[1]) //2 is back 1 is front
            //(MV_reg[0][3:0]<<4)*(L0_A1_temp[1]-L0_A1_temp[0]);
            L0_A1_compare<= (L0_A1_temp[2]-L0_A1_temp[1]); //() +  (4bit*8bit=12bit)  
        else
            L0_A1_compare<= (L0_A1_temp[1]-L0_A1_temp[2]);
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L0_A1_compare_2<=0;
    end
    else if(current_state==5)begin
        if(L0_compare==1'b1) 
            L0_A1_compare_2<=(L0_A1_temp[0]<<4)+(MV_reg[4][3:0]*L0_A1_compare);
        else
            L0_A1_compare_2<=(L0_A1_temp[0]<<4)-(MV_reg[4][3:0]*L0_A1_compare);

    end
    else if(current_state==4)begin
        if(L0_compare==1'b1) 
            L0_A1_compare_2<=(L0_A1_temp[0]<<4)+(MV_reg[0][3:0]*L0_A1_compare);
        else
            L0_A1_compare_2<=(L0_A1_temp[0]<<4)-(MV_reg[0][3:0]*L0_A1_compare);
    end
    else begin
        L0_A1_compare_2<=L0_A1_compare_2;
    end
end



always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(int i=0;i<4;i=i+1)begin
            L0_B1_temp[i]<=12'b0;
        end
    end
    else begin
       if((current_state==4 && MV_counter>=19)||(current_state==5 && MV_counter>=19))begin
            L0_B1_temp[3]<=L0_A1_compare_2;  //2750 A2 
            L0_B1_temp[2]<=0; //1696 A1
            L0_B1_temp[1]<=L0_B1_temp[3];
            L0_B1_temp[0]<=L0_B1_temp[2];
        end
        else begin
            L0_B1_temp[3]<=L0_B1_temp[3];
            L0_B1_temp[2]<=L0_B1_temp[2];
            L0_B1_temp[1]<=L0_B1_temp[1];
            L0_B1_temp[0]<=L0_B1_temp[0];   
        end
    end
end

wire temp1;
assign temp1=(L0_A1_compare_2>=L0_reg[9])?1'b1:1'b0;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        L0_B1_compare<=0;
    else begin
        //if(L0_A1_compare_2>=L0_reg[9])
        if(temp1)
            L0_B1_compare<=1'b1;
        else
            L0_B1_compare<=1'b0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        L0_A2_compare<=0;
    else begin
        //if(L0_A1_compare_2>=L0_reg[9])
        if(temp1)
            L0_A2_compare<=L0_A1_compare_2-L0_reg[9];
        else
            L0_A2_compare<=L0_reg[9]-L0_A1_compare_2;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L0_A2_compare_2<=0;
    end
    else if(current_state==5 && L0_B1_compare==1'b1)
            L0_A2_compare_2<=(L0_reg[10]<<4)+(MV_reg[5][3:0]*L0_A2_compare);
    else if(current_state==5 && L0_B1_compare==1'b0)
            L0_A2_compare_2<=(L0_reg[10]<<4)-(MV_reg[5][3:0]*L0_A2_compare);
    else if(current_state==4 &&L0_B1_compare==1'b1)
        L0_A2_compare_2<=(L0_reg[10]<<4)+(MV_reg[1][3:0]*L0_A2_compare);
    else if(current_state==4 &&L0_B1_compare==1'b0)
        L0_A2_compare_2<=(L0_reg[10]<<4)-(MV_reg[1][3:0]*L0_A2_compare);
    else 
        L0_A2_compare_2<=L0_A2_compare_2;
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for (int i = 0; i < 10; i = i + 1) begin
            for (int j = 0; j < 10; j = j + 1) begin
                L0_BI[i][j] <= 0;
            end
        end
    end
    else if(next_state==0)begin
        for (int i = 0; i < 10; i = i + 1) begin
            for (int j = 0; j < 10; j = j + 1) begin
                L0_BI[i][j] <= 0;
            end
        end
    end
    else if(MV_counter>=21 && MV_counter<=129)begin
        if (MV_counter == 31 || MV_counter == 42 || MV_counter == 53 || MV_counter == 64 ||
            MV_counter == 75 || MV_counter == 86 || MV_counter == 97 || MV_counter == 108 ||
            MV_counter == 119) begin
            for (int i = 0; i < 10; i = i + 1) begin
                for (int j = 0; j < 10; j = j + 1) begin
                    L0_BI[i][j] <= L0_BI[i][j];
                end
            end
        end
        else begin
            for (int i = 0; i < 10; i = i + 1) begin
                for (int j = 0; j < 10; j = j + 1) begin
                    if (i == 9 && j == 9) begin
                        L0_BI[i][j] <= L0_A2_compare_2; 
                    end 
                    else if (j == 9) begin
                        L0_BI[i][j] <= L0_BI[i+1][0]; 
                    end 
                    else begin
                        L0_BI[i][j] <= L0_BI[i][j+1]; 
                    end
                end
            end
        end
    end
    else begin
        for (int i = 0; i < 10; i = i + 1) begin
            for (int j = 0; j < 10; j = j + 1) begin
                L0_BI[i][j] <= L0_BI[i][j];
            end
        end
    end
end
//-----------------------------------
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(int i=0;i<11;i=i+1)begin
            L1_reg[i]<=0;
        end
    end
    else if(next_state==0)begin
        for(int i=0;i<11;i=i+1)begin
            L1_reg[i]<=0;
        end
    end
    else if((current_state==4 && MV_counter>=10)||(current_state==5 && MV_counter>=10))begin
        if (MV_counter == 20 || MV_counter == 31 || MV_counter == 42 || MV_counter == 53 ||
            MV_counter == 64 || MV_counter == 75 || MV_counter == 86 || MV_counter == 97 ||
            MV_counter == 108 || MV_counter == 119) begin
            for(int i=0;i<11;i=i+1)begin
                L1_reg[i]<=L1_reg[i];
            end
        end
        else begin         
            L1_reg[0]<=L1_A1_compare_2;
            for(int i=1;i<11;i=i+1)begin
                L1_reg[i]<=L1_reg[i-1];
            end
        end
        
    end
    else begin
        for(int i=0;i<11;i=i+1)begin
            L1_reg[i]<=L1_reg[i];
        end
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(int i=0;i<3;i=i+1)begin
            L1_A1_temp[i]<=0; 
        end
    end
    else if((current_state==4 && MV_counter>=6)||(current_state==5 && MV_counter>=6))begin
        L1_A1_temp[2]<=SRAM_16384X8_L1_out_reg;
        L1_A1_temp[1]<=L1_A1_temp[2];
        L1_A1_temp[0]<=L1_A1_temp[1];
    end
    else begin
        L1_A1_temp[2]<=L1_A1_temp[2];
        L1_A1_temp[1]<=L1_A1_temp[1];
        L1_A1_temp[0]<=L1_A1_temp[0];
    end
end
wire temp2;
assign temp2=(L1_A1_temp[2]>=L1_A1_temp[1])?1'b1:1'b0;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        L1_compare<=0;
    else begin
        //if(L1_A1_temp[2]>=L1_A1_temp[1])
        if(temp2)
            L1_compare<=1'b1;
        else
            L1_compare<=1'b0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L1_A1_compare<=0;
    end
    else begin
        //if(L1_A1_temp[2]>=L1_A1_temp[1])
        if(temp2) 
            L1_A1_compare<= (L1_A1_temp[2]-L1_A1_temp[1]); 
        else
            L1_A1_compare<= (L1_A1_temp[1]-L1_A1_temp[2]);
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L1_A1_compare_2<=0;
    end
    else if(current_state==5 &&L1_compare==1'b1)
        L1_A1_compare_2<=(L1_A1_temp[0]<<4)+(MV_reg[6][3:0]*L1_A1_compare);
    else if(current_state==5 &&L1_compare==1'b0)
        L1_A1_compare_2<=(L1_A1_temp[0]<<4)-(MV_reg[6][3:0]*L1_A1_compare);
    else if(current_state==4 &&L1_compare==1'b1)
        L1_A1_compare_2<=(L1_A1_temp[0]<<4)+(MV_reg[2][3:0]*L1_A1_compare);
    else if(current_state==4 &&L1_compare==1'b0)
        L1_A1_compare_2<=(L1_A1_temp[0]<<4)-(MV_reg[2][3:0]*L1_A1_compare);
    else 
        L1_A1_compare_2<=L1_A1_compare_2;
end
always@(posedge clk or negedge rst_n)begin //6
    if(!rst_n)begin
        for(int i=0;i<4;i=i+1)begin
            L1_B1_temp[i]<=12'b0;
        end
    end
    else begin
       if((current_state==4 && MV_counter>=21)||(current_state==5 && MV_counter>=21))begin
            L1_B1_temp[3]<=L1_A1_compare_2;  
            L1_B1_temp[2]<=0; 
            L1_B1_temp[1]<=L1_B1_temp[3];
            L1_B1_temp[0]<=L1_B1_temp[2];
        end
        else begin
            L1_B1_temp[3]<=L1_B1_temp[3];
            L1_B1_temp[2]<=L1_B1_temp[2];
            L1_B1_temp[1]<=L1_B1_temp[1];
            L1_B1_temp[0]<=L1_B1_temp[0];
        end
    end
end
always@(posedge clk or negedge rst_n)begin //7
    if(!rst_n)
        L1_B1_compare<=0;
    else begin
        if(L1_A1_compare_2>=L1_reg[9])
            L1_B1_compare<=1'b1;
        else
            L1_B1_compare<=1'b0;
    end
end

always@(posedge clk or negedge rst_n)begin //8
    if(!rst_n)
        L1_A2_compare<=0;
    else begin
        if(L1_A1_compare_2>=L1_reg[9])//A2-A1
            L1_A2_compare<=L1_A1_compare_2-L1_reg[9];
        else
            L1_A2_compare<=L1_reg[9]-L1_A1_compare_2;
    end
end

always@(posedge clk or negedge rst_n)begin //9
    if(!rst_n)begin
        L1_A2_compare_2<=0;
    end
    else if(current_state==5)begin
        if(L1_B1_compare==1'b1) 
            L1_A2_compare_2<=(L1_reg[10]<<4)+(MV_reg[7][3:0]*L1_A2_compare);
        else
            L1_A2_compare_2<=(L1_reg[10]<<4)-(MV_reg[7][3:0]*L1_A2_compare);
    end
    else if(current_state==4)begin
        if(L1_B1_compare==1'b1) 
            L1_A2_compare_2<=(L1_reg[10]<<4)+(MV_reg[3][3:0]*L1_A2_compare);
        else
            L1_A2_compare_2<=(L1_reg[10]<<4)-(MV_reg[3][3:0]*L1_A2_compare);
    end
    else begin
        L1_A2_compare_2<=L1_A2_compare_2;
    end
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for (int i = 0; i < 10; i = i + 1) begin
            for (int j = 0; j < 10; j = j + 1) begin
                L1_BI[i][j] <= 0;
            end
        end
    end
    else if(next_state==0)begin
        for (int i = 0; i < 10; i = i + 1) begin
            for (int j = 0; j < 10; j = j + 1) begin
                L1_BI[i][j] <= 0;
            end
        end
    end
    else if(MV_counter>=23 && MV_counter<=131)begin
        if (MV_counter == 33 || MV_counter == 44 || MV_counter == 55 || MV_counter == 66 ||
            MV_counter == 77 || MV_counter == 88 || MV_counter == 99 || MV_counter == 110 ||
            MV_counter == 121 || MV_counter == 132) begin
            for (int i = 0; i < 10; i = i + 1) begin
                for (int j = 0; j < 10; j = j + 1) begin
                    L1_BI[i][j] <= L1_BI[i][j];
                end
            end
        end
        else begin
            for (int i = 0; i < 10; i = i + 1) begin
                for (int j = 0; j < 10; j = j + 1) begin
                    if (i == 9 && j == 9) begin
                        L1_BI[i][j] <= L1_A2_compare_2; 
                    end 
                    else if (j == 9) begin
                        L1_BI[i][j] <= L1_BI[i+1][0]; 
                    end 
                    else begin
                        L1_BI[i][j] <= L1_BI[i][j+1]; 
                    end
                end
            end
        end
    end
    else begin
        for (int i = 0; i < 10; i = i + 1) begin
            for (int j = 0; j < 10; j = j + 1) begin
                L1_BI[i][j] <= L1_BI[i][j];
            end
        end

    end
end


reg L0_SAD_comparator_0,L0_SAD_comparator_1,L0_SAD_comparator_2,L0_SAD_comparator_3,L0_SAD_comparator_4,L0_SAD_comparator_5,L0_SAD_comparator_6,L0_SAD_comparator_7;
//reg L1_SAD_comparator[0:7];
reg [15:0]L0_SAD_temp0,L0_SAD_temp1,L0_SAD_temp2,L0_SAD_temp3,L0_SAD_temp4,L0_SAD_temp5,L0_SAD_temp6,L0_SAD_temp7;
reg [3:0]idx,idy;
reg [3:0]x,y;
reg [23:0]L0_SAD_temp0_one,L0_SAD_temp1_one,L0_SAD_temp2_one,L0_SAD_temp3_one; //level 1
reg [23:0]L0_SAD_temp0_two,L0_SAD_temp1_two;
reg [23:0]L0_SAD_temp0_three;
reg [23:0]SAD_reg[0:8];

//---------------------SAD----------------//

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        x<=0;
        y<=0;
    end
    else if (next_state==0)begin
        x<=0;
        y<=0;
    end
    else if (current_state==5 && MV_counter==1)begin
        x<=0;
        y<=0;
    end
    else begin
        case (MV_counter)
            151: begin x <= 1; y <= 0; end
            171: begin x <= 2; y <= 0; end
            191: begin x <= 0; y <= 1; end
            211: begin x <= 1; y <= 1; end
            231: begin x <= 2; y <= 1; end
            251: begin x <= 0; y <= 2; end
            271: begin x <= 1; y <= 2; end
            291: begin x <= 2; y <= 2; end
            default: begin x <= x; y <= y; end 
        endcase
    end
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        idx<=0;
        idy<=0;

    end
    else if (next_state==0)begin
        idx<=0;
        idy<=0;
    end    
    else if (current_state==5 && MV_counter==1)begin
        idx<=0;
        idy<=0;
    end
     else if(MV_counter>=133 && MV_counter<=151)begin
        if (idx==9 && MV_counter==151)
            idx<=0;
        //else if(MV_counter==133||MV_counter==135||MV_counter==137||MV_counter==139||MV_counter==141||MV_counter==143||MV_counter==145||MV_counter==147||MV_counter==149)
        else if(MV_counter_divide_two_equal_one)
            idx<=idx+1'b1;
        else 
            idx<=idx;
    end
    else if(MV_counter>=153 && MV_counter<=171)begin
        if (idx==9 && MV_counter==171)
            idx<=0;
        //else if(MV_counter==153||MV_counter==155||MV_counter==157||MV_counter==159||MV_counter==161||MV_counter==163||MV_counter==165||MV_counter==167||MV_counter==169)
        else if(MV_counter_divide_two_equal_one)
            idx<=idx+1'b1;
        else 
            idx<=idx;
    end
    else if(MV_counter>=173 && MV_counter<=191)begin
        if (idx==9 && MV_counter==191)
            idx<=0;
        //else if(MV_counter==173||MV_counter==175||MV_counter==177||MV_counter==179||MV_counter==181||MV_counter==183||MV_counter==185||MV_counter==187||MV_counter==189)
        else if(MV_counter_divide_two_equal_one)
            idx<=idx+1'b1;
        else 
            idx<=idx;
    end
    else if(MV_counter>=193 && MV_counter<=211)begin
        if (idx==9 && MV_counter==211)
            idx<=0;
        //else if(MV_counter==193||MV_counter==195||MV_counter==197||MV_counter==199||MV_counter==201||MV_counter==203||MV_counter==205||MV_counter==207||MV_counter==209)
        else if(MV_counter_divide_two_equal_one)
            idx<=idx+1'b1;
        else 
            idx<=idx;
    end
    else if(MV_counter>=213 && MV_counter<=231)begin
        if (idx==9 && MV_counter==231)
            idx<=0;
        //else if(MV_counter==213||MV_counter==215||MV_counter==217||MV_counter==219||MV_counter==221||MV_counter==223||MV_counter==225||MV_counter==227||MV_counter==229)
        else if(MV_counter_divide_two_equal_one)
            idx<=idx+1'b1;
        else 
            idx<=idx;
    end
    else if(MV_counter>=233 && MV_counter<=251)begin
        if (idx==9 && MV_counter==251)
            idx<=0;
        //else if(MV_counter==233||MV_counter==235||MV_counter==237||MV_counter==239||MV_counter==241||MV_counter==243||MV_counter==245||MV_counter==247||MV_counter==249)
        else if(MV_counter_divide_two_equal_one)        
            idx<=idx+1'b1;
        else 
            idx<=idx;
    end
    else if(MV_counter>=253 && MV_counter<=271)begin
        if (idx==9 && MV_counter==271)
            idx<=0;
        //else if(MV_counter==253||MV_counter==255||MV_counter==257||MV_counter==259||MV_counter==261||MV_counter==263||MV_counter==265||MV_counter==267||MV_counter==269)
        else if(MV_counter_divide_two_equal_one)
            idx<=idx+1'b1;
        else 
            idx<=idx;
    end
    else if(MV_counter>=273 && MV_counter<=291)begin
        if (idx==9 && MV_counter==291)
            idx<=0;
        //else if(MV_counter==273||MV_counter==275||MV_counter==277||MV_counter==279||MV_counter==281||MV_counter==283||MV_counter==285||MV_counter==287||MV_counter==289)
        else if(MV_counter_divide_two_equal_one)
            idx<=idx+1'b1;
        else 
            idx<=idx;
    end
    else if(MV_counter>=293 && MV_counter<=311)begin
        if (idx==9 && MV_counter==311)
            idx<=0;
        //else if(MV_counter==293||MV_counter==295||MV_counter==297||MV_counter==299||MV_counter==301||MV_counter==303||MV_counter==305||MV_counter==307||MV_counter==309)
        else if(MV_counter_divide_two_equal_one)
            idx<=idx+1'b1;
        else 
            idx<=idx;
    end
    else begin
        idx<=idx;
        idy<=idy;
    end
end



always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L0_SAD_comparator_0<=0;
    end
    //else if(MV_counter>=132)begin
    else begin
        if(L0_BI[idx+x][idy+y]>=L1_BI[idx+2-x][idy+2-y])
            L0_SAD_comparator_0<=1'b1;
        else 
            L0_SAD_comparator_0<=1'b0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L0_SAD_temp0<=0;
    end
    else begin
        if(L0_SAD_comparator_0)
            L0_SAD_temp0<=L0_BI[idx+x][idy+y]-L1_BI[idx+2-x][idy+2-y];
        else 
            L0_SAD_temp0<=L1_BI[idx+2-x][idy+2-y]-L0_BI[idx+x][idy+y];
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L0_SAD_comparator_1<=0;
    end
    //else if(MV_counter>=132)begin
    else begin
        if(L0_BI[idx+0+x][idy+1+y]>=L1_BI[idx+2-x][idy+3-y])
            L0_SAD_comparator_1<=1'b1;
        else 
            L0_SAD_comparator_1<=1'b0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L0_SAD_temp1<=0;
    end
    else begin
        if(L0_SAD_comparator_1)
            L0_SAD_temp1<=L0_BI[idx+0+x][idy+1+y]-L1_BI[idx+2-x][idy+3-y];
        else 
            L0_SAD_temp1<=L1_BI[idx+2-x][idy+3-y]-L0_BI[idx+0+x][idy+1+y];
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L0_SAD_comparator_2<=0;
    end
    //else if(MV_counter>=132)begin
    else begin
        if(L0_BI[idx+0+x][idy+2+y]>=L1_BI[idx+2-x][idy+4-y])
            L0_SAD_comparator_2<=1'b1;
        else 
            L0_SAD_comparator_2<=1'b0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L0_SAD_temp2<=0;
    end
    else begin
        if(L0_SAD_comparator_2)
            L0_SAD_temp2<=L0_BI[idx+0+x][idy+2+y]-L1_BI[idx+2-x][idy+4-y];
        else 
            L0_SAD_temp2<=L1_BI[idx+2-x][idy+4-y]-L0_BI[idx+0+x][idy+2+y];
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L0_SAD_comparator_3<=0;
    end
    //else if(MV_counter>=132)begin
    else begin
        if(L0_BI[idx+0+x][idy+3+y]>=L1_BI[idx+2-x][idy+5-y])
            L0_SAD_comparator_3<=1'b1;
        else 
            L0_SAD_comparator_3<=1'b0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L0_SAD_temp3<=0;
    end
    else begin
        if(L0_SAD_comparator_3)
            L0_SAD_temp3<=L0_BI[idx+0+x][idy+3+y]-L1_BI[idx+2-x][idy+5-y];
        else 
            L0_SAD_temp3<=L1_BI[idx+2-x][idy+5-y]-L0_BI[idx+0+x][idy+3+y];
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L0_SAD_comparator_4<=0;
    end
    //else if(MV_counter>=132)begin
    else begin
        if(L0_BI[idx+0+x][idy+4+y]>=L1_BI[idx+2-x][idy+6-y])
            L0_SAD_comparator_4<=1'b1;
        else 
            L0_SAD_comparator_4<=1'b0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L0_SAD_temp4<=0;
    end
    else begin
        if(L0_SAD_comparator_4)
            L0_SAD_temp4<=L0_BI[idx+0+x][idy+4+y]-L1_BI[idx+2-x][idy+6-y];
        else 
            L0_SAD_temp4<=L1_BI[idx+2-x][idy+6-y]-L0_BI[idx+0+x][idy+4+y];
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L0_SAD_comparator_5<=0;
    end
    //else if(MV_counter>=132)begin
    else begin
       if(L0_BI[idx+0+x][idy+5+y]>=L1_BI[idx+2-x][idy+7-y])
            L0_SAD_comparator_5<=1'b1;
       else 
            L0_SAD_comparator_5<=1'b0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L0_SAD_temp5<=0;
    end
    else begin
        if(L0_SAD_comparator_5)
            L0_SAD_temp5<=L0_BI[idx+0+x][idy+5+y]-L1_BI[idx+2-x][idy+7-y];
        else 
            L0_SAD_temp5<=L1_BI[idx+2-x][idy+7-y]-L0_BI[idx+0+x][idy+5+y];
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L0_SAD_comparator_6<=0;
    end
    //else if(MV_counter>=132)begin
    else begin
        if(L0_BI[idx+0+x][idy+6+y]>=L1_BI[idx+2-x][idy+8-y])
            L0_SAD_comparator_6<=1'b1;
        else 
            L0_SAD_comparator_6<=1'b0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L0_SAD_temp6<=0;
    end
    else begin
        if(L0_SAD_comparator_6)
            L0_SAD_temp6<=L0_BI[idx+0+x][idy+6+y]-L1_BI[idx+2-x][idy+8-y];
        else 
            L0_SAD_temp6<=L1_BI[idx+2-x][idy+8-y]-L0_BI[idx+0+x][idy+6+y];
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L0_SAD_comparator_7<=0;
    end
    //else if(MV_counter>=132)begin
    else begin
        if(L0_BI[idx+0+x][idy+7+y]>=L1_BI[idx+2-x][idy+9-y])
            L0_SAD_comparator_7<=1'b1;
        else 
            L0_SAD_comparator_7<=1'b0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        L0_SAD_temp7<=0;
    end
    else begin
        if(L0_SAD_comparator_7)
            L0_SAD_temp7<=L0_BI[idx+0+x][idy+7+y]-L1_BI[idx+2-x][idy+9-y];
        else 
            L0_SAD_temp7<=L1_BI[idx+2-x][idy+9-y]-L0_BI[idx+0+x][idy+7+y];
    end
end


always@(posedge clk or negedge rst_n)begin //level 1 
    if(!rst_n)begin
        L0_SAD_temp0_one<=24'b0;
    end
    /*else if (MV_counter == 134 || MV_counter == 136 || MV_counter == 138 || MV_counter == 140 ||
         MV_counter == 142 || MV_counter == 144 || MV_counter == 146 || MV_counter == 148 ||
         MV_counter == 150 || MV_counter == 152) begin
        L0_SAD_temp0_one<=L0_SAD_temp0+L0_SAD_temp1;
    end*/
    //else if(MV_counter %2==0)begin
    else if(MV_counter_divide_two_equal_zero)begin
        L0_SAD_temp0_one<=L0_SAD_temp0+L0_SAD_temp1;
    end
    else 
        L0_SAD_temp0_one<=0;
end       
always@(posedge clk or negedge rst_n)begin //level 1
    if(!rst_n)begin
        L0_SAD_temp1_one<=24'b0;
    end
    /*else if (MV_counter == 134 || MV_counter == 136 || MV_counter == 138 || MV_counter == 140 ||
         MV_counter == 142 || MV_counter == 144 || MV_counter == 146 || MV_counter == 148 ||
         MV_counter == 150 || MV_counter == 152) begin
        L0_SAD_temp1_one<=L0_SAD_temp2+L0_SAD_temp3;
    end*/
    //else if(MV_counter %2==0)begin
    else if(MV_counter_divide_two_equal_zero)begin
        L0_SAD_temp1_one<=L0_SAD_temp2+L0_SAD_temp3;
    end
    else
        L0_SAD_temp1_one<=0;
end      

always@(posedge clk or negedge rst_n)begin //level 1
    if(!rst_n)begin
        L0_SAD_temp2_one<=24'b0;
    end
    /*else if (MV_counter == 134 || MV_counter == 136 || MV_counter == 138 || MV_counter == 140 ||
         MV_counter == 142 || MV_counter == 144 || MV_counter == 146 || MV_counter == 148 ||
         MV_counter == 150 || MV_counter == 152) begin
        L0_SAD_temp2_one<=L0_SAD_temp4+L0_SAD_temp5;
    end*/
    //else if(MV_counter %2==0)begin
    else if(MV_counter_divide_two_equal_zero)begin
        L0_SAD_temp2_one<=L0_SAD_temp4+L0_SAD_temp5;
    end
    else
        L0_SAD_temp2_one<=0;
end    
always@(posedge clk or negedge rst_n)begin //level 1
    if(!rst_n)begin
        L0_SAD_temp3_one<=24'b0;
    end
    /*else if (MV_counter == 134 || MV_counter == 136 || MV_counter == 138 || MV_counter == 140 ||
         MV_counter == 142 || MV_counter == 144 || MV_counter == 146 || MV_counter == 148 ||
         MV_counter == 150 || MV_counter == 152) begin
        L0_SAD_temp3_one<=L0_SAD_temp6+L0_SAD_temp7;
    end*/
    //else if(MV_counter %2==0)begin
    else if(MV_counter_divide_two_equal_zero)begin
        L0_SAD_temp3_one<=L0_SAD_temp6+L0_SAD_temp7;
    end
    else 
        L0_SAD_temp3_one<=0;
end    
always@(posedge clk or negedge rst_n)begin //level 2
    if(!rst_n)begin
        L0_SAD_temp0_two<=24'b0;
    end
    /*else if (MV_counter == 135 || MV_counter == 137 || MV_counter == 139 || MV_counter == 141 ||
         MV_counter == 143 || MV_counter == 145 || MV_counter == 147 || MV_counter == 149 ||
         MV_counter == 151 || MV_counter == 153) begin
        L0_SAD_temp0_two<=L0_SAD_temp0_one+L0_SAD_temp1_one;
    end*/
    //else if(MV_counter%2==1)
    else if(MV_counter_divide_two_equal_one)
        L0_SAD_temp0_two<=L0_SAD_temp0_one+L0_SAD_temp1_one;
    else 
        L0_SAD_temp0_two<=0;
end   
always@(posedge clk or negedge rst_n)begin //level 2
    if(!rst_n)begin
        L0_SAD_temp1_two<=24'b0;
    end
    /*else if (MV_counter == 135 || MV_counter == 137 || MV_counter == 139 || MV_counter == 141 ||
         MV_counter == 143 || MV_counter == 145 || MV_counter == 147 || MV_counter == 149 ||
         MV_counter == 151 || MV_counter == 153) begin
        L0_SAD_temp1_two<=L0_SAD_temp2_one+L0_SAD_temp3_one;
    end*/
    //else if(MV_counter%2==1)
    else if(MV_counter_divide_two_equal_one)
        L0_SAD_temp1_two<=L0_SAD_temp2_one+L0_SAD_temp3_one;
    else 
        L0_SAD_temp1_two<=0;
end   
always@(posedge clk or negedge rst_n)begin //level 3
    if(!rst_n)begin
        L0_SAD_temp0_three<=24'b0;
    end
    //else if(MV_counter%2==0)
    else if(MV_counter_divide_two_equal_zero)
        L0_SAD_temp0_three<=L0_SAD_temp0_two+L0_SAD_temp1_two;
    else
        L0_SAD_temp0_three<=0;
end 


//reg [27:0]SAD_reg[0:8];
always@(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin
        for(int i=0;i<9;i=i+1)begin
            SAD_reg[i]<=0;
        end
    end
    else if(next_state==0)begin
        for(int i=0;i<9;i=i+1)begin
            SAD_reg[i]<=0;
        end
    end
    else if(current_state==5 && MV_counter==1)begin
        for(int i=0;i<9;i=i+1)begin
            SAD_reg[i]<=0;
        end
    end
    else begin
        if(MV_counter >= 137 && MV_counter <= 151)
            SAD_reg[0] <= SAD_reg[0] + L0_SAD_temp0_three;
        else if(MV_counter >= 157 && MV_counter <= 171)
            SAD_reg[1] <= SAD_reg[1] + L0_SAD_temp0_three;
        else if(MV_counter >= 177 && MV_counter <= 191)
            SAD_reg[2] <= SAD_reg[2] + L0_SAD_temp0_three;
        else if(MV_counter >= 197 && MV_counter <= 211)
            SAD_reg[3] <= SAD_reg[3] + L0_SAD_temp0_three;
        else if(MV_counter >= 217 && MV_counter <= 231)
            SAD_reg[4] <= SAD_reg[4] + L0_SAD_temp0_three;
        else if(MV_counter >= 237 && MV_counter <= 251)
            SAD_reg[5] <= SAD_reg[5] + L0_SAD_temp0_three;
        else if(MV_counter >= 257 && MV_counter <= 271)
            SAD_reg[6] <= SAD_reg[6] + L0_SAD_temp0_three;
        else if(MV_counter >= 277 && MV_counter <= 291)
            SAD_reg[7] <= SAD_reg[7] + L0_SAD_temp0_three;
        else if(MV_counter >= 297 && MV_counter <= 311)
            SAD_reg[8] <= SAD_reg[8] + L0_SAD_temp0_three;


    end
end

reg [3:0]search_point;
always@(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin
        search_point<=0;
    end
    else if (next_state==0)
        search_point<=0;
    else begin
        case(MV_counter)
        172:begin 
            if(SAD_reg[0]>SAD_reg[1])
                search_point<=1; 
            else 
                search_point<=0; 
        end
        192:begin 
            if(SAD_reg[search_point]>SAD_reg[2])  
                search_point<=2;
            else     
                search_point<=search_point;
        end
        212:begin
            if(SAD_reg[search_point]>SAD_reg[3])  
                search_point<=3;
            else     
                search_point<=search_point;
        end
        232:begin
            if(SAD_reg[search_point]>SAD_reg[4])  
                search_point<=4;
            else     
                search_point<=search_point;
        end
        252:begin
            if(SAD_reg[search_point]>SAD_reg[5])  
                search_point<=5;
            else     
                search_point<=search_point;
        end
        272:begin
            if(SAD_reg[search_point]>SAD_reg[6])  
                search_point<=6;
            else     
                search_point<=search_point;
        end
        292:begin
            if(SAD_reg[search_point]>SAD_reg[7])  
                search_point<=7;
            else     
                search_point<=search_point;
        end
        312:begin
            if(SAD_reg[search_point]>SAD_reg[8])  
                search_point<=8;
            else     
                search_point<=search_point;
        end
        endcase
    end
end







///////////////////////////////////////////////////////////////
always@(posedge clk or negedge rst_n)begin //SRAM_16384X8_L0_in_reg
    if(!rst_n)begin
        SRAM_16384X8_L0_in_reg<=0;
    end    
    else if(next_state==0)begin
        SRAM_16384X8_L0_in_reg<=0;
    end
    else if(in_valid)begin
        SRAM_16384X8_L0_in_reg<=in_data[11:4];
    end
    else 
        SRAM_16384X8_L0_in_reg<=SRAM_16384X8_L0_in_reg;
end

always@(posedge clk or negedge rst_n)begin //SRAM_16384X8_L1_in_reg
    if(!rst_n)begin
        SRAM_16384X8_L1_in_reg<=0;

    end    
    else if(next_state==0)begin
        SRAM_16384X8_L1_in_reg<=0;
    end
    else if(in_valid)begin
        SRAM_16384X8_L1_in_reg<=in_data[11:4];
    end
    else 
        SRAM_16384X8_L1_in_reg<=SRAM_16384X8_L1_in_reg;
end

always@(posedge clk or negedge rst_n)begin//MV_counter
    if(!rst_n)begin
        MV_counter<=4'b0;
    end
    else if(in_valid2)begin
        MV_counter<=MV_counter+1'b1;
    end
    else if(next_state==0)
        MV_counter<=0;
    else if(next_state==6&&current_state==5)
        MV_counter<=28;
    else if(current_state==6)
        MV_counter<=MV_counter+1'b1;
    else if(current_state==4 &&next_state==5)
        MV_counter<=1;
    else if(next_state==5)
        MV_counter<=MV_counter+1'b1;
    else if(next_state==4)
        MV_counter<=MV_counter+1'b1;
    else 
        MV_counter<=0;
end
always@(posedge clk or negedge rst_n)begin //MV_reg
    if(!rst_n)begin
        for(int i=0;i<8;i=i+1)begin
            MV_reg[i]<=12'b0;
        end

    end
    else if (next_state==0)begin
        for(int i=0;i<8;i=i+1)begin
            MV_reg[i]<=12'b0;
        end
    end 
    else if(in_valid2)begin
        MV_reg[MV_counter]<=in_data;
    end
    else begin
        for(int i=0;i<8;i=i+1)begin
            MV_reg[i]<=MV_reg[i];
        end
    end
end
always@(posedge clk or negedge rst_n)begin //A
    if(!rst_n)begin
        out_counter<=0;
    end
    else if(next_state==0)begin
        out_counter<=0;
    end
    else if(current_state==5 &&MV_counter>=286)begin
        out_counter<=out_counter+1'b1;
    end
    else begin
        out_counter<=out_counter;
    end
end

always@(posedge clk or negedge rst_n)begin //A
    if(!rst_n)begin
        out_reg<=0;
    end
    else if(next_state==0)
        out_reg<=0;
    else if(current_state==4&&MV_counter==313) begin
        out_reg<={28'b0,search_point,SAD_reg[search_point]};
    end
    else if(current_state==5&&MV_counter==313) begin
        out_reg<={search_point,SAD_reg[search_point],out_reg[27:0]};
    end
    else begin
        out_reg<=out_reg;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        out_valid<=1'b0;
    end
    else if(current_state==5 && MV_counter>=286)
        out_valid<=1'b1;
    else if(current_state==6)begin
        out_valid<=1'b1;
    end
    else 
        out_valid<=1'b0;
    
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        out_sad<=1'b0;
    end
    else if(current_state==5 && MV_counter>=286)
        out_sad<=out_reg[out_counter];
    else if(current_state==6)begin
        out_sad<=out_reg[MV_counter];
    end
    else 
        out_sad<=0;
end

//---------------------SAD----------------//






endmodule

module SRAM_16384X8_one(
    input CLK, CS, OE, WEB,
    input [13:0] A, //address
    input [7:0] DI,
    output [7:0] DO
);
SRAM_16384X8 SRAM_16384X8_inst(
    .A0(A[0]),   .A1(A[1]),   .A2(A[2]),   .A3(A[3]),   .A4(A[4]),   .A5(A[5]),   .A6(A[6]),   .A7(A[7]),
    .A8(A[8]),   .A9(A[9]),   .A10(A[10]), .A11(A[11]), .A12(A[12]), .A13(A[13]),
    .DO0(DO[0]), .DO1(DO[1]), .DO2(DO[2]), .DO3(DO[3]), .DO4(DO[4]), .DO5(DO[5]), .DO6(DO[6]), .DO7(DO[7]),
    .DI0(DI[0]), .DI1(DI[1]), .DI2(DI[2]), .DI3(DI[3]), .DI4(DI[4]), .DI5(DI[5]), .DI6(DI[6]), .DI7(DI[7]),
    .CK(CLK), .WEB(WEB), .OE(OE), .CS(CS)
);

endmodule