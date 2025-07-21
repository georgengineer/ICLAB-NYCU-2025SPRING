module MAZE(
    // input
    input clk,
    input rst_n,
    input in_valid,
    input [1:0] in,

    // output
    output reg out_valid,
    output reg [1:0] out
);
parameter IDLE=2'b00;
parameter IN  =2'b01;
parameter SWORD=2'b10;
parameter ROAD=2'b11;

integer i,j;
// --------------------------------------------------------------
// Reg & Wire
// --------------------------------------------------------------
wire  map_ending;
reg [4:0]x_counter;
reg [4:0]y_counter;
reg [1:0]current_point;
reg [1:0]next_point;
reg  [1:0]next_state,current_state;
//wire [1:0]matrix_bound[0:16][0:16];
reg  [1:0]matrix[0:16][0:16];
reg  [1:0]matrix_input[0:16][0:16];
reg  [1:0]matrix_forbid_to_walk[0:16][0:16];
reg find_sword;
wire a1;
wire a2;
wire a3;
wire a4;

// 0:path 1:wall 2:sword 3:monster
/*
assign matrix_bound[1 ][1 ]=1'b1;assign matrix_bound[9 ][1 ]=1'b1;
assign matrix_bound[1 ][3 ]=1'b1;assign matrix_bound[9 ][3 ]=1'b1;
assign matrix_bound[1 ][5 ]=1'b1;assign matrix_bound[9 ][5 ]=1'b1;
assign matrix_bound[1 ][7 ]=1'b1;assign matrix_bound[9 ][7 ]=1'b1;
assign matrix_bound[1 ][9 ]=1'b1;assign matrix_bound[9 ][9 ]=1'b1;
assign matrix_bound[1 ][11]=1'b1;assign matrix_bound[9 ][11]=1'b1;
assign matrix_bound[1 ][13]=1'b1;assign matrix_bound[9 ][13]=1'b1;
assign matrix_bound[1 ][15]=1'b1;assign matrix_bound[9 ][15]=1'b1;
assign matrix_bound[3 ][1 ]=1'b1;assign matrix_bound[11][1 ]=1'b1;
assign matrix_bound[3 ][3 ]=1'b1;assign matrix_bound[11][3 ]=1'b1;
assign matrix_bound[3 ][5 ]=1'b1;assign matrix_bound[11][5 ]=1'b1;
assign matrix_bound[3 ][7 ]=1'b1;assign matrix_bound[11][7 ]=1'b1;
assign matrix_bound[3 ][9 ]=1'b1;assign matrix_bound[11][9 ]=1'b1;
assign matrix_bound[3 ][11]=1'b1;assign matrix_bound[11][11]=1'b1;
assign matrix_bound[3 ][13]=1'b1;assign matrix_bound[11][13]=1'b1;
assign matrix_bound[3 ][15]=1'b1;assign matrix_bound[11][15]=1'b1;
assign matrix_bound[5 ][1 ]=1'b1;assign matrix_bound[13][1 ]=1'b1;
assign matrix_bound[5 ][3 ]=1'b1;assign matrix_bound[13][3 ]=1'b1;
assign matrix_bound[5 ][5 ]=1'b1;assign matrix_bound[13][5 ]=1'b1;
assign matrix_bound[5 ][7 ]=1'b1;assign matrix_bound[13][7 ]=1'b1;
assign matrix_bound[5 ][9 ]=1'b1;assign matrix_bound[13][9 ]=1'b1;
assign matrix_bound[5 ][11]=1'b1;assign matrix_bound[13][11]=1'b1;
assign matrix_bound[5 ][13]=1'b1;assign matrix_bound[13][13]=1'b1;
assign matrix_bound[5 ][15]=1'b1;assign matrix_bound[13][15]=1'b1;
assign matrix_bound[7 ][1 ]=1'b1;assign matrix_bound[15][1 ]=1'b1;
assign matrix_bound[7 ][3 ]=1'b1;assign matrix_bound[15][3 ]=1'b1;
assign matrix_bound[7 ][5 ]=1'b1;assign matrix_bound[15][5 ]=1'b1;
assign matrix_bound[7 ][7 ]=1'b1;assign matrix_bound[15][7 ]=1'b1;
assign matrix_bound[7 ][9 ]=1'b1;assign matrix_bound[15][9 ]=1'b1;
assign matrix_bound[7 ][11]=1'b1;assign matrix_bound[15][11]=1'b1;
assign matrix_bound[7 ][13]=1'b1;assign matrix_bound[15][13]=1'b1;
assign matrix_bound[7 ][15]=1'b1;assign matrix_bound[15][15]=1'b1;
*/

// --------------------------------------------------------------
// Design
// --------------------------------------------------------------
assign map_ending=(x_counter==5'd16 && y_counter==5'd16)?1'b1:1'b0;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        current_state<=2'b0;
    else 
        current_state<=next_state;
end

always@(*)begin
    case(current_state)
        IDLE:begin//0
            next_state=(in_valid)? IN: IDLE;
            //$display("next_state=%d",next_state);
        end
        IN:begin  //1
            next_state=(x_counter==5'd16 && y_counter==5'd16)?SWORD:IN;
            //$display("next_state=%d",next_state);
        end
        SWORD:begin //2
            if(find_sword)
                next_state=ROAD;
            else if(x_counter==5'd16 && y_counter==5'd16)
                next_state=IDLE;
            else
                next_state=SWORD;
            //next_state=(find_sword)?ROAD:SWORD;       
            //$display("next_state=%d",next_state);
        end
        ROAD:begin
            next_state=(x_counter==5'd16 && y_counter==5'd16)?IDLE:ROAD;
            //$display("next_state=%d",next_state);
        end
    default:next_state=IDLE;
    endcase

end
/*
always@(*)begin
    for (int i=1;i<17;i=i+2)begin
        for(int j=1;j<17;j=j+2)begin
            matrix[i][j]=matrix_bound[i][j];


        end
    end
end
*/
/*
genvar s, t;
generate
    for (s = 0; s < 17; s = s + 1) begin : row // [row] means genvar for loop name
        for (t = 0; t < 17; t = t + 1) begin : col //[col] means genvar for loop name
            always @(posedge clk) begin
                    case (next_state)
                        IDLE: begin
                            matrix_input[s][t] <= 1'b0;
                        end
                        IN: begin
                            if (x_counter == s && y_counter == t)
                                matrix_input[s][t] <= in;
                            else if (matrix_forbid_to_walk[s][t] != 2'b00)
                                matrix_input[s][t] <= matrix_forbid_to_walk[s][t];
                            else
                                matrix_input[s][t] <= matrix_input[s][t];
                        end
                        SWORD, ROAD: begin
                            matrix_input[s][t] <= matrix_forbid_to_walk[s][t];
                        end
                        default: begin
                            matrix_input[x_counter][y_counter] <= matrix_input[x_counter][y_counter];
                        end
                    endcase
            end
        end//for t loop
    end//for s loop
endgenerate
*/

always @(posedge clk) begin
        if (in_valid) matrix_input[x_counter][y_counter] <= in;
        else begin
        case (next_state)
            IDLE: begin
                for (i = 0; i < 17; i = i + 1)begin  // [row] means genvar for loop name
                    for (j = 0; j < 17; j = j + 1)begin
                        matrix_input[i][j] <= 1'b0;
                    end
                end
            end
            /*
            IN: begin
                    matrix_input[x_counter][y_counter] <= in;
            end
            */
            SWORD, ROAD: begin
                for (i = 0; i < 17; i = i + 1)begin  // [row] means genvar for loop name
                    for (j = 0; j < 17; j = j + 1)begin
                        matrix_input[i][j] <= matrix_forbid_to_walk[i][j];
                    end
                end
            end
            default: begin
                matrix_input[x_counter][y_counter] <= matrix_input[x_counter][y_counter];
            end
        endcase
        end
end

always@(*)begin
    for (int i=0;i<17;i=i+1)begin
        for(int j=0;j<17;j=j+1)begin
            matrix[i][j]=matrix_input[i][j];
        end
    end
end
/*
always@(*)begin
    if (next_state==SWORD)begin
        for (int i=0;i<17;i=i+1)begin
            for(int j=0;j<17;j=j+1)begin
                matrix[i][j]=matrix_forbid_to_walk[i][j];
            end
        end
    end
    else begin
        for (int i=0;i<17;i=i+1)begin
            for(int j=0;j<17;j=j+1)begin
                matrix[i][j]=matrix_input[i][j];
            end
        end
    end
end
*/

always@(*)begin
    //matrix_forbid_to_walk[0:16][0:16]
    //$display("\n\n$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$start$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n\n");
    //$display("x_counter=[%0d],y_counter=[%0d]",x_counter,y_counter);
    /*
    if(next_state==IDLE)begin
        for (i=0;i<17;i=i+1)begin
            for(j=0;j<17;j=j+1)begin
                 matrix_forbid_to_walk[i][j]=2'b00;

            end
        end
    end
    */
    /*else if(next_state==IN)begin
        for (i=0;i<17;i=i+1)begin
            for(j=0;j<17;j=j+1)begin
                matrix_forbid_to_walk[i][j]=2'b00;
                if (matrix[i][j]==2'b01)begin//wall
                    matrix_forbid_to_walk[i][j]=2'b01;//wall to wall
                end
                else if (matrix[i][j]==2'b10)begin//sword
                    matrix_forbid_to_walk[i][j]=2'b10;//sword to sword
                end
                else if(matrix[i][j]==2'b11) begin//monster matrix[i][j]==2'b11
                    matrix_forbid_to_walk[i][j]=2'b11;
                end
                else begin
                    if((i>=1 && i<=15)&&(j>=1 && j<=15))begin
                        if(( matrix[i][j-1][0] && matrix[i-1][j][0] && matrix[i][j+1][0])| //left top right
                            (matrix[i-1][j][0] && matrix[i][j+1][0] && matrix[i+1][j][0])|  //top right down
                            (matrix[i][j+1][0] && matrix[i+1][j][0] && matrix[i][j-1][0])|  //left down right
                            (matrix[i+1][j][0] && matrix[i][j-1][0] && matrix[i-1][j][0])   //left top down
                        )begin
                            if(matrix[i+1][j]==2'b11|| matrix[i-1][j]==2'b11 || matrix[i][j-1]==2'b11||matrix[i][j+1]==2'b11)begin
                                matrix_forbid_to_walk[i][j]=2'b11;
                            end
                            else begin //no monster ,three wall
                                matrix_forbid_to_walk[i][j]=2'b01; //dead road 1'b1:wall
                            end
                        end
                        else begin
                            //$display("matrix_forbid_to_walk[%d][%d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                            matrix_forbid_to_walk[i][j]=2'b00;

                        end
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                    end
                    else if((i==0)&&(j>=1 && j<=15))begin  //  [top] line 

                        if((matrix[i][j-1][0]&&matrix[i+1][j][0])||(matrix[i][j+1][0]&&matrix[i+1][j][0])||(matrix[i][j-1][0]&&matrix[i][j+1][0]))begin
                            if(matrix[i][j-1]==2'b11||matrix[i+1][j]==2'b11|| matrix[i][j+1]==2'b11)begin
                                matrix_forbid_to_walk[i][j]=2'b11;     
                            end
                            else begin
                                matrix_forbid_to_walk[i][j]=2'b01; //dead road
                            end

                        end
                        else begin

                            matrix_forbid_to_walk[i][j]=2'b00;
                        end
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                    end
                    else if((i==16)&&(j>=1 && j<=15))begin  //[bottom] line
                        if((matrix[i][j-1][0]&&matrix[i-1][j][0])||(matrix[i][j+1][0]&&matrix[i-1][j][0])||(matrix[i][j-1][0]&&matrix[i][j+1][0]))begin
                            if(matrix[i][j-1]==2'b11 || matrix[i-1][j]==2'b11 || matrix[i][j+1]==2'b11)begin
                                matrix_forbid_to_walk[i][j]=2'b11;  //monster 
                            end
                            else begin
                                matrix_forbid_to_walk[i][j]=2'b01;  //wall
                            end
                        end
                        else begin

                            matrix_forbid_to_walk[i][j]=2'b00;      //path
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                        end
                    end
                    else if((i>=1 && i<=15)&&(j==0))begin  //[left]  line
                        if((matrix[i-1][j][0]&&matrix[i][j+1][0])||(matrix[i+1][j][0]&&matrix[i][j+1][0])||(matrix[i-1][j][0]&&matrix[i+1][j][0]))begin
                           if(matrix[i-1][j]==2'b11 || matrix[i][j+1]==2'b11|| matrix[i+1][j]==2'b11)begin 
                                matrix_forbid_to_walk[i][j]=2'b11;  //monster 
                            end
                            else begin
                                matrix_forbid_to_walk[i][j]=2'b01;  //wall
                            end
                        end
                        else begin

                            matrix_forbid_to_walk[i][j]=2'b00;      //path 
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                        end
                    end
                    else if((i>=1 && i<=15)&&(j==16))begin  //[right] line
                        if((matrix[i][j-1][0]&&matrix[i+1][j][0])||(matrix[i][j-1][0]&&matrix[i-1][j][0])||(matrix[i-1][j][0]&&matrix[i+1][j][0]))begin
                            if(matrix[i][j-1]==2'b11||matrix[i+1][j]==2'b11||matrix[i-1][j]==2'b11) begin
                                matrix_forbid_to_walk[i][j]=2'b11;  //monster 
                            end
                            else begin
                                matrix_forbid_to_walk[i][j]=2'b01;  //wall
                            end
                        end
                        else begin
                            matrix_forbid_to_walk[i][j]=2'b00;      //path 
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                        end
                    end
                    else if(i==0 && j==16)begin                  //right top corner
                        if(matrix[i][j-1][0]||matrix[i+1][j][0]) begin
                            if(matrix[i][j-1]==2'b11||matrix[i+1][j]==2'b11) begin
                                matrix_forbid_to_walk[i][j]=2'b11;  //monster 
                            end
                            else begin
                                matrix_forbid_to_walk[i][j]=2'b01;  //wall
                            end
                        end
                        else begin 
                            matrix_forbid_to_walk[i][j]=2'b00;      //path 
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                        end
                    end
                    else if(i==16 && j==0)begin               //left down corner
                        if(matrix[i-1][j][0]||matrix[i][j+1][0])begin
                            if(matrix[i-1][j]==2'b11||matrix[i][j+1]==2'b11)begin
                                matrix_forbid_to_walk[i][j]=2'b11;  //monster 
                            end
                            else begin
                                matrix_forbid_to_walk[i][j]=2'b01;  //wall
                            end
                        end
                        else begin
                            matrix_forbid_to_walk[i][j]=2'b00;      //path 
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                        end
                    end
                    else begin
                        matrix_forbid_to_walk[i][j]=2'b0;
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                    end

                end//else end
            end//for loop2()
        end//for loop1()
    end*/
    if(next_state==SWORD)begin
        for (i=0;i<17;i=i+1)begin
            for(j=0;j<17;j=j+1)begin
                //matrix_forbid_to_walk[i][j]=2'b00;
                case(matrix[i][j])
                2'b01:begin//wall
                    matrix_forbid_to_walk[i][j]=2'b01;//wall to wall
                end
                2'b10:begin//sword
                    matrix_forbid_to_walk[i][j]=2'b10;//sword to sword
                end
                2'b11:begin//monster matrix[i][j]==2'b11
                    matrix_forbid_to_walk[i][j]=2'b11;
                end
                default:begin
                    if((i>=1 && i<=15)&&(j>=1 && j<=15))begin
                        if(( matrix[i][j-1][0] && matrix[i-1][j][0] && matrix[i][j+1][0])| //left top right
                            (matrix[i-1][j][0] && matrix[i][j+1][0] && matrix[i+1][j][0])|  //top right down
                            (matrix[i][j+1][0] && matrix[i+1][j][0] && matrix[i][j-1][0])|  //left down right
                            (matrix[i+1][j][0] && matrix[i][j-1][0] && matrix[i-1][j][0])   //left top down
                        )begin
                            if(matrix[i+1][j]==2'b11|| matrix[i-1][j]==2'b11 || matrix[i][j-1]==2'b11||matrix[i][j+1]==2'b11)begin
                                matrix_forbid_to_walk[i][j]=2'b11;
                            end
                            else begin //no monster ,three wall
                                matrix_forbid_to_walk[i][j]=2'b01; //dead road 1'b1:wall
                            end
                        end
                        else begin
                            //$display("matrix_forbid_to_walk[%d][%d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                            matrix_forbid_to_walk[i][j]=2'b00;

                        end
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                    end
                    else if((i==0)&&(j>=1 && j<=15))begin  //  [top] line 

                        if((matrix[i][j-1][0]&&matrix[i+1][j][0])||(matrix[i][j+1][0]&&matrix[i+1][j][0])||(matrix[i][j-1][0]&&matrix[i][j+1][0]))begin
                            if(matrix[i][j-1]==2'b11||matrix[i+1][j]==2'b11|| matrix[i][j+1]==2'b11)begin
                                matrix_forbid_to_walk[i][j]=2'b11;     
                            end
                            else begin
                                matrix_forbid_to_walk[i][j]=2'b01; //dead road
                            end

                        end
                        else begin

                            matrix_forbid_to_walk[i][j]=2'b00;
                        end
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                    end
                    else if((i==16)&&(j>=1 && j<=15))begin  //[bottom] line
                        if((matrix[i][j-1][0]&&matrix[i-1][j][0])||(matrix[i][j+1][0]&&matrix[i-1][j][0])||(matrix[i][j-1][0]&&matrix[i][j+1][0]))begin
                            if(matrix[i][j-1]==2'b11 || matrix[i-1][j]==2'b11 || matrix[i][j+1]==2'b11)begin
                                matrix_forbid_to_walk[i][j]=2'b11;  //monster 
                            end
                            else begin
                                matrix_forbid_to_walk[i][j]=2'b01;  //wall
                            end
                        end
                        else begin

                            matrix_forbid_to_walk[i][j]=2'b00;      //path
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                        end
                    end
                    else if((i>=1 && i<=15)&&(j==0))begin  //[left]  line
                        if((matrix[i-1][j][0]&&matrix[i][j+1][0])||(matrix[i+1][j][0]&&matrix[i][j+1][0])||(matrix[i-1][j][0]&&matrix[i+1][j][0]))begin
                           if(matrix[i-1][j]==2'b11 || matrix[i][j+1]==2'b11|| matrix[i+1][j]==2'b11)begin 
                                matrix_forbid_to_walk[i][j]=2'b11;  //monster 
                            end
                            else begin
                                matrix_forbid_to_walk[i][j]=2'b01;  //wall
                            end
                        end
                        else begin

                            matrix_forbid_to_walk[i][j]=2'b00;      //path 
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                        end
                    end
                    else if((i>=1 && i<=15)&&(j==16))begin  //[right] line
                        if((matrix[i][j-1][0]&&matrix[i+1][j][0])||(matrix[i][j-1][0]&&matrix[i-1][j][0])||(matrix[i-1][j][0]&&matrix[i+1][j][0]))begin
                            if(matrix[i][j-1]==2'b11||matrix[i+1][j]==2'b11||matrix[i-1][j]==2'b11) begin
                                matrix_forbid_to_walk[i][j]=2'b11;  //monster 
                            end
                            else begin
                                matrix_forbid_to_walk[i][j]=2'b01;  //wall
                            end
                        end
                        else begin
                            matrix_forbid_to_walk[i][j]=2'b00;      //path 
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                        end
                    end
                    else if(i==0 && j==16)begin                  //right top corner
                        if(matrix[i][j-1][0]||matrix[i+1][j][0]) begin
                            if(matrix[i][j-1]==2'b11||matrix[i+1][j]==2'b11) begin
                                matrix_forbid_to_walk[i][j]=2'b11;  //monster 
                            end
                            else begin
                                matrix_forbid_to_walk[i][j]=2'b01;  //wall
                            end
                        end
                        else begin 
                            matrix_forbid_to_walk[i][j]=2'b00;      //path 
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                        end
                    end
                    else if(i==16 && j==0)begin               //left down corner
                        if(matrix[i-1][j][0]||matrix[i][j+1][0])begin
                            if(matrix[i-1][j]==2'b11||matrix[i][j+1]==2'b11)begin
                                matrix_forbid_to_walk[i][j]=2'b11;  //monster 
                            end
                            else begin
                                matrix_forbid_to_walk[i][j]=2'b01;  //wall
                            end
                        end
                        else begin
                            matrix_forbid_to_walk[i][j]=2'b00;      //path 
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                        end
                    end
                    else if(i==0 && j==0)begin
                        if(matrix[i+1][j]==2'b01||matrix[i][j+1]==2'b01)
                            matrix_forbid_to_walk[i][j]=2'b01;
   
                        else
                            matrix_forbid_to_walk[i][j]=2'b00;

                    end
                    else begin
                        matrix_forbid_to_walk[i][j]=2'b00;
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                    end
                

                end//end for default 
                endcase
            end//for loop2()
        end//for loop1()
    end //end for if(next_state==SWORD)
    /*
    else if(next_state==SWORD) begin
            for (i=0;i<17;i=i+1)begin
                for(j=0;j<17;j=j+1)begin
                    matrix_forbid_to_walk[i][j]=2'b00;
                end
            end
    end*/
    
    else if(current_state==SWORD&&next_state==ROAD)begin
        for (i=0;i<17;i=i+1)begin
            for(j=0;j<17;j=j+1)begin
                if (matrix[i][j]==2'b01)begin//wall
                    matrix_forbid_to_walk[i][j]=2'b01;//wall to wall
                end
                else begin
                    matrix_forbid_to_walk[i][j]=2'b00;
                end
            end
        end
    end
    else if(next_state==ROAD)begin
    for (i=0;i<17;i=i+1)begin
            for(j=0;j<17;j=j+1)begin
                if (matrix[i][j]==2'b01)begin//wall
                    matrix_forbid_to_walk[i][j]=2'b01;//wall to wall
                end
                else if (matrix[i][j]==2'b10)begin//sword
                    matrix_forbid_to_walk[i][j]=2'b00;//sword to sword
                end
                else if(matrix[i][j]==2'b11) begin//monster matrix[i][j]==2'b11
                    matrix_forbid_to_walk[i][j]=2'b00;
                end
                else begin
                    if((i>=1 && i<=15)&&(j>=1 && j<=15))begin
                        if(( matrix[i][j-1][0] && matrix[i-1][j][0] && matrix[i][j+1][0])|| //left top right
                            (matrix[i-1][j][0] && matrix[i][j+1][0] && matrix[i+1][j][0])||  //top right down
                            (matrix[i][j+1][0] && matrix[i+1][j][0] && matrix[i][j-1][0])||  //left down right
                            (matrix[i+1][j][0] && matrix[i][j-1][0] && matrix[i-1][j][0])   //left top down
                        )begin
                                matrix_forbid_to_walk[i][j]=2'b01; //dead road 1'b1:wall
                        end
                        else begin
                            //$display("matrix_forbid_to_walk[%d][%d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                            matrix_forbid_to_walk[i][j]=2'b00;

                        end
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                    end
                    else if((i==0)&&(j>=1 && j<=15))begin  //  [top] line 

                        if((matrix[i][j-1][0]&&matrix[i+1][j][0])||(matrix[i][j+1][0]&&matrix[i+1][j][0])||(matrix[i][j-1][0]&&matrix[i][j+1][0]))begin
                                matrix_forbid_to_walk[i][j]=2'b01; //dead road
                        end
                        else begin

                            matrix_forbid_to_walk[i][j]=2'b00;
                        end
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                    end
                    else if((i==16)&&(j>=1 && j<=15))begin  //[bottom] line
                        if((matrix[i][j-1][0]&&matrix[i-1][j][0])||(matrix[i][j+1][0]&&matrix[i-1][j][0])||(matrix[i][j-1][0]&&matrix[i][j+1][0]))begin
                                matrix_forbid_to_walk[i][j]=2'b01;  //wall
                        end
                        else begin
                            matrix_forbid_to_walk[i][j]=2'b00;      //path
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                        end
                    end
                    else if((i>=1 && i<=15)&&(j==0))begin  //[left]  line
                        if((matrix[i-1][j][0]&&matrix[i][j+1][0])||(matrix[i+1][j][0]&&matrix[i][j+1][0])||(matrix[i-1][j][0]&&matrix[i+1][j][0]))begin
                                matrix_forbid_to_walk[i][j]=2'b01;  //wall
                        end
                        else begin

                            matrix_forbid_to_walk[i][j]=2'b00;      //path 
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                        end
                    end
                    else if((i>=1 && i<=15)&&(j==16))begin  //[right] line
                        if((matrix[i][j-1][0]&&matrix[i+1][j][0])||(matrix[i][j-1][0]&&matrix[i-1][j][0])||(matrix[i-1][j][0]&&matrix[i+1][j][0]))begin
                                matrix_forbid_to_walk[i][j]=2'b01;  //wall
                        end
                        else begin
                            matrix_forbid_to_walk[i][j]=2'b00;      //path 
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                        end
                    end
                    else if(i==0 && j==16)begin                  //right top corner
                        if(matrix[i][j-1][0]||matrix[i+1][j][0]) begin
                                matrix_forbid_to_walk[i][j]=2'b01;  //wall
                        end
                        else begin 
                            matrix_forbid_to_walk[i][j]=2'b00;      //path 
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                        end
                    end
                    else if(i==16 && j==0)begin               //left down corner
                        if(matrix[i-1][j][0]||matrix[i][j+1][0])begin
                            matrix_forbid_to_walk[i][j]=2'b01;  //wall
                        end
                        else begin
                            matrix_forbid_to_walk[i][j]=2'b00;      //path 
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                        end
                    end
                    else if(i==0 && j==0)begin
                        if(matrix[i+1][j]==2'b01||matrix[i][j+1]==2'b01)
                            matrix_forbid_to_walk[i][j]=2'b01;
   
                        else
                            matrix_forbid_to_walk[i][j]=2'b00;

                    end
                    else begin
                        matrix_forbid_to_walk[i][j]=2'b00;
                        //$display("matrix_forbid_to_walk[%0d][%0d]=%d",i,j,matrix_forbid_to_walk[i][j]);
                        //$fdisplay(file, "matrix_forbid_to_walk[%0d][%0d] = %d", i, j, matrix_forbid_to_walk[i][j]);
                    end

                end //else end
            
            end//for loop2()
        end//for loop1() 
    end
    else begin //next_state ==IDLE next_state==IN
        for (i=0;i<17;i=i+1)begin
            for(j=0;j<17;j=j+1)begin
                 matrix_forbid_to_walk[i][j]=2'b00;

            end
        end
    end
end//always@(*)

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        y_counter<=0;
    end
    else begin
        if(next_state==IN)
            if(y_counter==16)
                y_counter<=5'b0;
            else
                y_counter<=y_counter+1'b1;
        else if (current_state==IN && next_state==SWORD )
            y_counter<=5'd0;
        else if(next_state==SWORD||next_state==ROAD)begin
        case(next_point)
            2'b00:  y_counter<=y_counter+1'b1;
            2'b10:  y_counter<=y_counter-1'b1;
            default:y_counter<=y_counter;
        endcase
        end
        else if(x_counter==16 & y_counter==16)
            y_counter<=5'b0;
        else
            y_counter<=y_counter;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        x_counter<=0;
    end
    else begin
        if(x_counter==16 & y_counter==16)
            x_counter<=5'b0;
        else if(next_state==IN)begin
            if(y_counter==16)
                x_counter<=x_counter+1'b1;
        end
        else if(next_state==SWORD||next_state==ROAD)begin
        case(next_point)
            2'b01:  x_counter<=x_counter+1'b1;
            2'b11:  x_counter<=x_counter-1'b1;
            default:x_counter<=x_counter;
        endcase
        end
        else
            x_counter<=x_counter;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        current_point<=2'b00;
    end
    else if(next_state==SWORD||next_state==ROAD) begin
        current_point<=next_point;        
    end
    else begin
        current_point<=current_point;
    end
end
/*
always@(*)begin
    find_sword=1'b0; 
    if(next_state==SWORD) begin
        if(matrix[x_counter+1'b1][y_counter]==2'b00 &&current_point!=2'b11)begin//go down 
            next_point=2'b01;
        end
        else if (matrix[x_counter+1'b1][y_counter]==2'b10 &&current_point!=2'b11)begin
            next_point=2'b01;
            find_sword=1'b1;
        end
        else if ((matrix[x_counter][y_counter+1'b1]==2'b00 &&current_point!=2'b10))
            next_point=2'b00;
        else if (matrix[x_counter][y_counter+1'b1]==2'b10 &&current_point!=2'b10)begin//go right
            next_point=2'b00;
            find_sword=1'b1;
        end
        else if((matrix[x_counter-1'b1][y_counter]==2'b00 &&current_point!=2'b01)||(matrix[x_counter-1'b1][y_counter]==2'b10 &&current_point!=2'b01)) //go up
            next_point=2'b11;
        else if ((matrix[x_counter][y_counter-1'b1]==2'b00 &&current_point!=2'b00)||matrix[x_counter][y_counter-1'b1]==2'b10 &&current_point!=2'b00)//go left
            next_point=2'b10;
        else
            next_point={~current_point[1],current_point[0]};
    end
    else begin
        next_point=2'b00;
        
    end
end
*/

always@(*)begin
        if(matrix[x_counter][y_counter]==2'b10)
            find_sword=1'b1;
        else 
            find_sword=1'b0;
    

end
/*
always @(posedge clk) begin
    if (current_state == 2'b01) begin
        $display("find_sword=%d ,x_counter=%d,y_counter=%d ",find_sword,x_counter,y_counter);
        $display("global_counter=%d",global_counter);
    end
end
always@(posedge clk)begin
    if(find_sword==1'b1)
    $display("enter=");
end
reg [30:0] global_counter;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        global_counter <= 'd0;
    end 
    else begin
        global_counter <= global_counter + 1;
    end
end
*/
wire [4:0]x_counter_add  ;
wire [4:0]x_counter_minus;
wire [4:0]y_counter_add  ;
wire [4:0]y_counter_minus;
wire left_bar;
assign x_counter_add  = x_counter+1'b1;
assign x_counter_minus= x_counter-1'b1;
assign y_counter_add  = y_counter+1'b1;
assign y_counter_minus= y_counter-1'b1;
assign left_bar=(x_counter==0)&&(y_counter>=1 && y_counter<=15)?1'b1:1'b0;
always@(*)begin
    if(next_state==IDLE)begin
        next_point=2'b0;
    end
    else if(current_state==SWORD && next_state==ROAD)begin  
        if(x_counter==0 && y_counter==0)begin//start point
            if((matrix[x_counter+1'b1][y_counter][0]==1'b0||matrix[x_counter+1'b1][y_counter]==2'b11) &&current_point!=2'd3)//go down 
                next_point=2'd1;//go down 
            else if((matrix[x_counter][y_counter+1'b1][0]==1'b0 || matrix[x_counter][y_counter+1'b1]==2'b11) &&current_point!=2'd2)//go right
                next_point=2'd0;//go right
            else 
                next_point={!current_point[1],current_point[0]};//go right
        end

        else if ((x_counter==0)&&(y_counter>=1 && y_counter<=15))begin    //[top] line 
            if((matrix[x_counter][y_counter+1'b1][0]==1'b0 ||matrix[x_counter][y_counter+1'b1]==2'b11)&&current_point!=2'd2)//go right
                next_point=2'd0;//go right
            else if((matrix[x_counter+1'b1][y_counter][0]==1'b0||matrix[x_counter+1'b1][y_counter]==2'b11) &&current_point!=2'd3)//go down 
                next_point=2'd1;//go down 
            else if((matrix[x_counter][y_counter-1'b1][0]==1'b0||matrix[x_counter][y_counter-1'b1]==2'b11) &&current_point!=2'd0) //[]go left
                next_point=2'd2;
            else
                next_point={!current_point[1],current_point[0]};//go right

        end
        else if ((x_counter==16)&&(y_counter>=1 && y_counter<=15))begin    //[bottom] line
            if((matrix[x_counter][y_counter+1'b1][0]==1'b0 ||matrix[x_counter][y_counter+1'b1]==2'b11)&&current_point!=2'd2)//go right
                next_point=2'd0;//go right
            else if ((matrix[x_counter-1'b1][y_counter][0]==1'b0 ||matrix[x_counter-1'b1][y_counter]==2'b11)&& current_point!=2'd1)// go up
                next_point=2'd3;//go up
            else if((matrix[x_counter][y_counter-1'b1][0]==1'b0||matrix[x_counter][y_counter-1'b1]==2'b11) &&current_point!=2'd0) //[]go left
                next_point=2'd2;
            else
               next_point={!current_point[1],current_point[0]};//go right
/////////////////////////////////////////////////***
        end
        else if ((x_counter>=1 && x_counter<=15)&&(y_counter==0))begin     //[left]  line
            if((matrix[x_counter+1'b1][y_counter][0]==1'b0 ||matrix[x_counter+1'b1][y_counter]==2'b11)&&current_point!=2'd3)//go down 
                next_point=2'd1;//go down 
            else if((matrix[x_counter][y_counter+1'b1][0]==1'b0 ||matrix[x_counter][y_counter+1'b1]==2'b11)&&current_point!=2'd2)//go right
                next_point=2'd0;//go right
            else if ((matrix[x_counter-1'b1][y_counter][0]==1'b0 ||matrix[x_counter-1'b1][y_counter]==2'b11)&& current_point!=2'd1)// go up
                next_point=2'd3;//go up
            else
                next_point={!current_point[1],current_point[0]};
        end

        else if ((x_counter>=1 && x_counter<=15)&&(y_counter==16))begin    //[right] line    
            if((matrix[x_counter+1'b1][y_counter][0]==1'b0||matrix[x_counter+1'b1][y_counter]==2'b11) &&current_point!=2'd3)//go down 
                next_point=2'd1;//go down 
            else if((matrix[x_counter][y_counter-1'b1][0]==1'b0 ||matrix[x_counter][y_counter-1'b1]==2'b11)&&current_point!=2'd0) //[]go left
                next_point=2'd2;
            else if ((matrix[x_counter-1'b1][y_counter][0]==1'b0 ||matrix[x_counter-1'b1][y_counter]==2'b11)&& current_point!=2'd1)// go up
                next_point=2'd3;//go up
            else
                next_point={!current_point[1],current_point[0]};
        end
        else if (x_counter==0 && y_counter==16)begin                       //[right] [top] corner
            if((matrix[x_counter+1'b1][y_counter][0]==1'b0||matrix[x_counter+1'b1][y_counter]==2'b11) &&current_point!=2'd3)//go down 
                next_point=2'd1;//go down 
            else if((matrix[x_counter][y_counter-1'b1][0]==1'b0||matrix[x_counter][y_counter-1'b1]==2'b11) &&current_point!=2'd0) //[]go left
                next_point=2'd2;
            else
                next_point={!current_point[1],current_point[0]};
        end
        else if(x_counter==16 && y_counter==0)begin                       //[left] [down] corner
            if((matrix[x_counter][y_counter+1'b1][0]==1'b0||matrix[x_counter][y_counter+1'b1]==2'b11) &&current_point!=2'd2)//go right
                next_point=2'd0;//go right
            else if((matrix[x_counter-1'b1][y_counter][0]==1'b0||matrix[x_counter-1'b1][y_counter]==2'b11 )&& current_point!=2'd1)// go up
                next_point=2'd3;//go up
            else
                next_point={!current_point[1],current_point[0]};
        end
        else if(x_counter==16 && y_counter==16) 
            next_point=2'd0;
        else begin
            if((matrix[x_counter][y_counter+1'b1][0]==1'b0 ||matrix[x_counter][y_counter+1'b1]==2'b11)&&current_point!=2'd2)//go right
                next_point=2'd0;//go right
            else if((matrix[x_counter+1'b1][y_counter][0]==1'b0 ||matrix[x_counter+1'b1][y_counter]==2'b11)&&current_point!=2'd3)//go down 
                next_point=2'd1;//go down 
            else if((matrix[x_counter][y_counter-1'b1][0]==1'b0 ||matrix[x_counter][y_counter-1'b1]==2'b11)&&current_point!=2'd0) //[]go left
                next_point=2'd2;
            else 
                next_point={!current_point[1],current_point[0]};
        end
    end

    else if(current_state==SWORD||current_state==ROAD)begin        
        if(x_counter==0 && y_counter==0)begin//start point
            if(matrix[x_counter][y_counter+1'b1][0]==1'b0 &&current_point!=2'd2)//go right
                next_point=2'd0;//go right
            else if(matrix[x_counter+1'b1][y_counter][0]==1'b0 &&current_point!=2'd3)//go down 
                next_point=2'd1;//go down 
            else 
                next_point={!current_point[1],current_point[0]};//go right
        end

        else if ((x_counter==0)&&(y_counter>=1 && y_counter<=15))begin    //[top] line 
            if(matrix[x_counter][y_counter+1'b1][0]==1'b0 &&current_point!=2'd2)//go right
                next_point=2'd0;//go right
            else if(matrix[x_counter+1'b1][y_counter][0]==1'b0 &&current_point!=2'd3)//go down 
                next_point=2'd1;//go down 
            else if(matrix[x_counter][y_counter-1'b1][0]==1'b0 &&current_point!=2'd0) //[]go left
                next_point=2'd2;
            else
                next_point={!current_point[1],current_point[0]};

        end
        else if ((x_counter==16)&&(y_counter>=1 && y_counter<=15))begin    //[bottom] line
            if(matrix[x_counter][y_counter+1'b1][0]==1'b0 &&current_point!=2'd2)//go right
                next_point=2'd0;//go right
            else if (matrix[x_counter-1'b1][y_counter][0]==1'b0 && current_point!=2'd1)// go up
                next_point=2'd3;//go up
            else if(matrix[x_counter][y_counter-1'b1][0]==1'b0 &&current_point!=2'd0) //[]go left
                next_point=2'd2;
            else
               next_point={!current_point[1],current_point[0]};

        end
        else if ((x_counter>=1 && x_counter<=15)&&(y_counter==0))begin     //[left]  line
            if(matrix[x_counter][y_counter+1'b1][0]==1'b0 &&current_point!=2'd2)//go right
                next_point=2'd0;//go right
            else if(matrix[x_counter+1'b1][y_counter][0]==1'b0 &&current_point!=2'd3)//go down 
                next_point=2'd1;//go down 
            else if (matrix[x_counter-1'b1][y_counter][0]==1'b0 && current_point!=2'd1)// go up
                next_point=2'd3;//go up
            else
                next_point={!current_point[1],current_point[0]};
        end

        else if ((x_counter>=1 && x_counter<=15)&&(y_counter==16))begin    //[right] line    
            if(matrix[x_counter+1'b1][y_counter][0]==1'b0 &&current_point!=2'd3)//go down 
                next_point=2'd1;//go down 
            else if(matrix[x_counter][y_counter-1'b1][0]==1'b0 &&current_point!=2'd0) //[]go left
                next_point=2'd2;
            else if (matrix[x_counter-1'b1][y_counter][0]==1'b0 && current_point!=2'd1)// go up
                next_point=2'd3;//go up
            else
               next_point={!current_point[1],current_point[0]};
        end
        else if (x_counter==0 && y_counter==16)begin                       //[right] [top] corner
            if(matrix[x_counter+1'b1][y_counter][0]==1'b0 &&current_point!=2'd3)//go down 
                next_point=2'd1;//go down 
            else if(matrix[x_counter][y_counter-1'b1][0]==1'b0 &&current_point!=2'd0) //[]go left
                next_point=2'd2;
            else
                next_point={!current_point[1],current_point[0]};
        end
        else if(x_counter==16 && y_counter==0)begin                       //[left] [down] corner
            if(matrix[x_counter][y_counter+1'b1][0]==1'b0 &&current_point!=2'd2)//go right
                next_point=2'd0;//go right
            else if(matrix[x_counter-1'b1][y_counter][0]==1'b0 && current_point!=2'd1)// go up
                next_point=2'd3;//go up
            else
                next_point={!current_point[1],current_point[0]};
        end
        else if(x_counter==16 && y_counter==16) 
            next_point=2'd0;
        else begin
            if((matrix[x_counter][y_counter+1'b1][0]==1'b0) &&current_point!=2'd2)//go right
                next_point=2'd0;//go right
            else if((matrix[x_counter+1'b1][y_counter][0]==1'b0 )&&(current_point!=2'd3))begin//go down 
                next_point=2'd1;//go down
            end
            else if(matrix[x_counter][y_counter-1'b1][0]==1'b0 &&current_point!=2'd0) //[]go left
                next_point=2'd2;
            else if(matrix[x_counter-1'b1][y_counter][0]==1'b0 && current_point!=2'd1)// go up
                next_point=2'd3;//go up
            else 
                next_point={!current_point[1],current_point[0]};
        end
    end

    
    else begin
        next_point=2'd0;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        out_valid<=1'b0;
    end
    else begin
        if (x_counter==5'd16 && y_counter==5'd16)
            out_valid<=1'b0;
        else if(current_state==SWORD ||current_state==ROAD)
            out_valid<=1'b1;
        else 
            out_valid<=1'b0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        out<=2'b0;
    end
    else begin
        if(next_state==SWORD ||next_state==ROAD)
            out<=next_point;
        else 
            out<=2'b00;
    end
end
endmodule

