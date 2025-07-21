/**************************************************************************/
// Copyright (c) 2025, OASIS Lab
// MODULE: STA
// FILE NAME: STA.v
// VERSRION: 1.0
// DATE: 2025/02/26
// AUTHOR: Yu-Hao Cheng, NYCU IEE
// DESCRIPTION: ICLAB 2025 Spring / LAB3 / STA
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/
module STA(
    //INPUT
    rst_n,
    clk,
    in_valid,
    delay,
    source,
    destination,
    //OUTPUT
    out_valid,
    worst_delay,
    path
);

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
input               rst_n, clk, in_valid;
input       [3:0]   delay;
input       [3:0]   source;
input       [3:0]   destination;

output reg          out_valid;
output reg  [7:0]   worst_delay;
output reg  [3:0]   path;

//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
parameter IDLE=2'b00;
parameter DATA=2'b01;
parameter SORT=2'b10;
integer i,j;

//---------------------------------------------------------------------
//   REG & WIRE DECLARATION
//---------------------------------------------------------------------
//reg [3:0]reg_source[0:31]; 
//reg [3:0]reg_destination[0:31];
reg [3:0]reg_delay[0:15];
reg [2:0]next_state,current_state;
reg [4:0]counter;
reg [3:0]in_degree[0:15];//4bit 15's


wire zero;
assign zero=1'b0;
reg [3:0]topo_temp;
reg [15:0]in_degree_enable;
reg [3:0]topo_counter;
//reg [3:0]in_degree_comb[0:15];//4bit 15's
reg [3:0]topo_order[0:15];
reg [3:0]topo_temp_counter;
reg [3:0]topo_index;
reg [7:0]distance[0:15];
//reg [3:0]final_counter;
//reg [3:0]final_path[0:15];
reg [3:0]current_node;
reg [3:0]current_label;
reg [3:0]find_father[0:15];
reg [3:0]shift_register[0:15];
reg wire_source[0:15][0:15];
//reg wire_destination[0:15][0:15];

/*
reg [3:0]source_buffer;
reg [3:0]destination_buffer;
always@(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin
		source_buffer<=0;
	end
	else if(in_valid==1'b1)begin
		source_buffer<=source;
	end
	else 
		source_buffer<=source_buffer;
end

always@(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin
		destination_buffer<=0;
	end
	else if(in_valid==1'b1)begin
		destination_buffer<=destination;
	end
	else
		destination_buffer<=destination_buffer;
end*/
always@(posedge clk or negedge rst_n)begin 
	if(!rst_n)
        for(int i=0;i<16;i=i+1)begin
            for(int j=0;j<16;j=j+1)begin
                wire_source[i][j]=1'b0;
            end
        end
    else if (next_state==1'b0)begin
        for(int i=0;i<16;i=i+1)begin
            for(int j=0;j<16;j=j+1)begin
                wire_source[i][j]=1'b0;
            end
        end
    end
    else if(in_valid==1'b1)
            wire_source[source][destination]=1'b1;


end
//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------
always@(posedge clk or negedge rst_n)begin //current_state<=next_state;
    if(!rst_n)begin
        current_state<=0;
    end
    else begin 
        current_state<=next_state;
    end
end
always@(*)begin
    case(current_state)
        3'd0:next_state=(in_valid)?        3'd1:3'd0;
        3'd1:next_state=(counter==31)?     3'd2:3'd1; // 2:1
        3'd2:begin
			if(counter==16)
				next_state=3'd4;
			else
				next_state=3'd3;
		end
        3'd3:begin
			if(counter==16)
				next_state=3'd4;
			else 
				next_state=3'd2;
		end
        3'd4:next_state=(current_label==0)?3'd5:3'd4;
		3'd5:next_state=(shift_register[counter]==1)?3'd0:3'd5;
        default:next_state=0;
    endcase
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        counter<=0;
	else if (current_state==0 && next_state==0)
        counter<=0;
    else if(counter==31)
        counter<=0;
    else if(next_state==1)
        counter<=counter+1'b1;
    else if(next_state==3) begin
        for(int i=1;i<16;i=i+1)begin
            if( in_degree[i]==0 && in_degree_enable[i]==0)begin
                    counter<=counter+1'b1;
            end
        end
    end
	else if (next_state==2 && counter==15)
		counter<=16;
	else if(current_state==5)
	 	counter<=counter+1'b1;	
	else if(next_state==5)
	 	counter<=0;
    else 
        counter<=counter;
end 
/*
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(int i=0;i<32;i=i+1)
            reg_source[i]<=4'b0;
    end
    else
        if(in_valid==1'b1)
            reg_source[counter]<=source;
        else
            reg_source[counter]<=reg_source[counter];
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(int i=0;i<32;i=i+1)
            reg_destination[i]<=4'b0;
    end
    else
        if(in_valid==1'b1)
            reg_destination[counter]<=destination;
        else
            reg_destination[counter]<=reg_destination[counter];
end
*/
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(int i=0;i<16;i=i+1)
            reg_delay[i]<=4'b0;
    end
    else
        if(in_valid==1'b1 && counter<16)
            reg_delay[counter]<=delay;
        else
            reg_delay[counter]<=reg_delay[counter];
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(int i=0;i<16;i=i+1)
            in_degree[i]<=4'b0;
    end
    else begin
    if(current_state==0 && next_state==0)begin
        for(int i=0;i<16;i=i+1)
            in_degree[i]<=4'b0;
    end
    else if(in_valid==1'b1)//DATA==2'b01;
            in_degree[destination]<=in_degree[destination]+1'b1;
    else if (next_state==2)begin
        for(int i=0;i<16;i=i+1)begin
            /*if(reg_source[i]==topo_temp && in_degree[reg_destination[i]]!=0)
                in_degree[reg_destination[i]]<=in_degree[reg_destination[i]]-1'b1;
            */
            if(wire_source[topo_temp][i]==1'b1 && in_degree[i]!=0)
                in_degree[i]<=in_degree[i]-1'b1;
        end
        
    end
    end
end
/*
always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        topo_temp_counter<=4'b0;
    end
    else begin
        if (current_state==4)
            topo_temp_counter<=topo_temp_counter+1'b1;
        else if(next_state==4)
            topo_temp_counter<=1;
        else if (topo_counter==14)
            topo_temp_counter<=topo_temp_counter+1'b1;
        else
            topo_temp_counter<=topo_temp_counter;
    end
end
*/
/*
always@(*)begin
    if(next_state==0)
        topo_temp=4'd0;
    else if (next_state==3)
        topo_temp=topo_order[topo_temp_counter];
    else if(current_state==4)
        topo_temp=topo_order[topo_temp_counter];
    else if(next_state==4)
        topo_temp=4'b0;
    
    else 
        topo_temp=4'b0;


end*/

always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        topo_temp<=0;
        in_degree_enable[0]<=1'b1;
        in_degree_enable[1]<=1'b0; in_degree_enable[2]<=1'b0; in_degree_enable[3]<=1'b0; in_degree_enable[4]<=1'b0; in_degree_enable[5]<=1'b0; in_degree_enable[6]<=1'b0; in_degree_enable[7]<=1'b0; in_degree_enable[8]<=1'b0; in_degree_enable[9]<=1'b0; in_degree_enable[10]<=1'b0; in_degree_enable[11]<=1'b0; in_degree_enable[12]<=1'b0; in_degree_enable[13]<=1'b0; in_degree_enable[14]<=1'b0; in_degree_enable[15]<=1'b0; 
    end
    else 
	if (next_state==1)begin
        topo_temp<=0;
        in_degree_enable[0]<=1'b1;
        in_degree_enable[1]<=1'b0; in_degree_enable[2]<=1'b0; in_degree_enable[3]<=1'b0; in_degree_enable[4]<=1'b0; in_degree_enable[5]<=1'b0; in_degree_enable[6]<=1'b0; in_degree_enable[7]<=1'b0; in_degree_enable[8]<=1'b0; in_degree_enable[9]<=1'b0; in_degree_enable[10]<=1'b0; in_degree_enable[11]<=1'b0; in_degree_enable[12]<=1'b0; in_degree_enable[13]<=1'b0; in_degree_enable[14]<=1'b0; in_degree_enable[15]<=1'b0; 
    end
    else if(next_state==3) begin
        if(in_degree[1]==0 && in_degree_enable[1]==0) begin
                topo_temp <= 4'd1;
                in_degree_enable[1] <= 1;
            end 
        else if(in_degree[2]==0 && in_degree_enable[2]==0) begin
                topo_temp <= 4'd2;
                in_degree_enable[2] <= 1;
        end 
        else if(in_degree[3]==0 && in_degree_enable[3]==0) begin
                topo_temp <= 4'd3;
                in_degree_enable[3] <= 1;
        end 
        else if(in_degree[4]==0 && in_degree_enable[4]==0) begin
                topo_temp <= 4'd4;
                in_degree_enable[4] <= 1;
        end 
        else if(in_degree[5]==0 && in_degree_enable[5]==0) begin
                topo_temp <= 4'd5;
                in_degree_enable[5] <= 1;
        end 
        else if(in_degree[6]==0 && in_degree_enable[6]==0) begin
                topo_temp <= 4'd6;
                in_degree_enable[6] <= 1;
        end 
        else if(in_degree[7]==0 && in_degree_enable[7]==0) begin
                topo_temp <= 4'd7;
                in_degree_enable[7] <= 1;
        end 
        else if(in_degree[8]==0 && in_degree_enable[8]==0) begin
                topo_temp <= 4'd8;
                in_degree_enable[8] <= 1;
        end 
        else if(in_degree[9]==0 && in_degree_enable[9]==0) begin
                topo_temp <= 4'd9;
                in_degree_enable[9] <= 1;
        end 
        else if(in_degree[10]==0 && in_degree_enable[10]==0) begin
                topo_temp <= 4'd10;
                in_degree_enable[10] <= 1;
        end 
        else if(in_degree[11]==0 && in_degree_enable[11]==0) begin
                topo_temp <= 4'd11;
                in_degree_enable[11] <= 1;
        end 
        else if(in_degree[12]==0 && in_degree_enable[12]==0) begin
                topo_temp <= 4'd12;
                in_degree_enable[12] <= 1;
        end 
        else if(in_degree[13]==0 && in_degree_enable[13]==0) begin
                topo_temp <= 4'd13;
                in_degree_enable[13] <= 1;
        end 
        else if(in_degree[14]==0 && in_degree_enable[14]==0) begin
                topo_temp <= 4'd14;
                in_degree_enable[14] <= 1;
        end else if(in_degree[15]==0 && in_degree_enable[15]==0) begin
                topo_temp <= 4'd15;
                in_degree_enable[15] <= 1;
        end
    end

end
/*
always@(posedge clk or negedge rst_n)begin
    if(!rst_n) begin
        in_degree_enable[0]<=1'b1;
        in_degree_enable[1]<=1'b0; in_degree_enable[2]<=1'b0; in_degree_enable[3]<=1'b0; in_degree_enable[4]<=1'b0; in_degree_enable[5]<=1'b0; in_degree_enable[6]<=1'b0; in_degree_enable[7]<=1'b0; in_degree_enable[8]<=1'b0; in_degree_enable[9]<=1'b0; in_degree_enable[10]<=1'b0; in_degree_enable[11]<=1'b0; in_degree_enable[12]<=1'b0; in_degree_enable[13]<=1'b0; in_degree_enable[14]<=1'b0; in_degree_enable[15]<=1'b0; 
    end 
    else if(next_state==2)begin
        for(int i=1;i<16;i=i+1)
            if(in_degree[topo_temp]==1)
                in_degree_enable[i]<=1'b1;
            else 
                in_degree_enable[i]<=in_degree_enable[i];
    end
end*/

/*
always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        topo_counter<=4'b0;
    end
    else if(topo_counter==15 &&current_state==2)begin
        topo_counter<=4'b1;
    end
    else if(next_state==3)begin
        topo_counter<=topo_counter+1'b1;
    end
    else if (current_state==4)begin
        topo_counter<=topo_counter+1'b1;
    end
    else if(next_state==4)begin
        topo_counter<=4'b1;
    end

end
*/
/*
always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        topo_index<=4'b1;
    end
    else if(next_state==0)begin
        topo_index<=1;
    end
    else begin
        for(int i=0;i<16;i=i+1) begin 
        if(current_state==3 && in_degree[i]==0 &&(in_degree_enable[i]==0 ))
            topo_index<=topo_index+1;
        end
    end
end*/
reg [3:0]topo_order_4bit;
/*
always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
            topo_order[0]<=4'b0; topo_order[1]<=4'b0; topo_order[2]<=4'b0; topo_order[3]<=4'b0; topo_order[4]<=4'b0; topo_order[5]<=4'b0; topo_order[6]<=4'b0; topo_order[7]<=4'b0; topo_order[8]<=4'b0; topo_order[9]<=4'b0; topo_order[10]<=4'b0; topo_order[11]<=4'b0; topo_order[12]<=4'b0; topo_order[13]<=4'b0; topo_order[14]<=4'b0; 
            topo_order[15]<=4'b1; 
    end
    else if(next_state==2 && counter>=1)begin
            topo_order[0]<=topo_temp;
    end
    
end
*/
always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
		topo_order_4bit<=0;
    end
    else if(next_state==2 && counter>=1)begin
            topo_order_4bit<=topo_temp;
    end
    
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        distance[0]<=reg_delay[0];
        distance[1]<=8'b0; distance[2]<=8'b0; distance[3]<=8'b0; distance[4]<=8'b0; distance[5]<=8'b0; distance[6]<=8'b0; distance[7]<=8'b0; distance[8]<=8'b0; distance[9]<=8'b0; distance[10]<=8'b0; distance[11]<=8'b0; distance[12]<=8'b0; distance[13]<=8'b0; distance[14]<=8'b0; distance[15]<=8'b0; 
		for(int i=0;i<16;i=i+1)
			find_father[i]<=0;
	end
    else
	if(next_state==1)begin
        distance[0]<=reg_delay[0];
        distance[1]<=8'b0; distance[2]<=8'b0; distance[3]<=8'b0; distance[4]<=8'b0; distance[5]<=8'b0; distance[6]<=8'b0; distance[7]<=8'b0; distance[8]<=8'b0; distance[9]<=8'b0; distance[10]<=8'b0; distance[11]<=8'b0; distance[12]<=8'b0; distance[13]<=8'b0; distance[14]<=8'b0; distance[15]<=8'b0; 
		for(int i=0;i<16;i=i+1)
			find_father[i]<=0;
	end
    else if(next_state==2 && counter>=0 && counter<=15)begin
		for(int i=0;i<16;i=i+1)begin
			 if(wire_source[topo_temp][i]==1'b1)begin
					if(distance[i]<=(distance[topo_temp]+reg_delay[i]))begin
						distance[i]<=distance[topo_temp]+reg_delay[i];
						find_father[i]<=topo_temp;
					end
					/*else begin 
                        distance[reg_destination[i]]<=distance[reg_destination[i]];
						find_father[reg_destination[i]]<=find_father[reg_destination[i]];
                    end*/
			end
		end
    end
	/*else begin
		for(int i=0;i<16;i=i+1)begin
			distance[i]<=distance[i];
			find_father[reg_destination[i]]<=find_father[reg_destination[i]];
		end
	end*/
end

always@(*)begin
	if(next_state==1)begin
		current_label=1;
	end
	else if(current_state==4)begin
		current_label=current_node; //10
	end
	else 
		current_label=1;
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		current_node<=0;
	end
	else if(next_state==4)begin
		current_node<=find_father[current_label];// 10 = [1]
	end

end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		for(int i=0;i<16;i=i+1)
			shift_register[i]<=4'b0;
	end
	else if(next_state==4||current_state==4) begin
		for(int i=1;i<16;i=i+1)begin
			shift_register[i]<=shift_register[i-1];
		end
		shift_register[0]<=current_label;
	end
		
	/*else begin
		shift_register[i]<=shift_register[i];
	end*/
end

/*
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
		  for(int i=0;i<16;i=i+1)
			find_father[i]<=4'b0;
	end
    else if(next_state==1)begin
		  for(int i=0;i<16;i=i+1)
			find_father[i]<=4'b0;  
	end
    else if(next_state==2 && counter>=0 && counter<=15)begin
		for(int i=0;i<32;i=i+1)begin
			 if(reg_source[i]==topo_temp)begin
					if(distance[reg_destination[i]]<=(distance[topo_temp]+reg_delay[reg_destination[i]]))begin
						
					end
					else begin 
                        distance[reg_destination[i]]<=distance[reg_destination[i]];
                    end
			end
		end
	end
end
*/
/*
always@(*)begin
    if(next_state==1)begin
        current_label=1;
    end
    else if(current_state==5)begin
        current_label=current_node;
    end
    else if(current_state==6)
        current_label=0;
    else
        current_label=1;
end*/
/*
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        current_node<=0;
    end
    else if(next_state==5)begin
        current_node<=node[current_label];
    end

end
*/
/*
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(int i=0;i<16;i=i+1)begin
            final_path[i]<=0;
        end
    end
    else if(next_state==5||next_state==6)begin
            final_path[final_counter]<=current_label;
    end
    else begin
        final_path[final_counter]<=final_path[final_counter];
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        final_counter<=0;
    end
    else if(next_state==1)begin
        final_counter<=0;
    end
    else if(next_state==5)begin
        final_counter<=final_counter+1'b1;
    end
    else if(next_state==7)
        final_counter<=final_counter-1'b1;
    else 
        final_counter<=final_counter;
end

*/





always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        out_valid<=1'b0;
    else if(current_state==5)
        out_valid<=1'b1;
    else
        out_valid<=1'b0;
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        path<=4'b0;
    else if(current_state==5)
        path<=shift_register[counter];
    else 
        path<=4'b0;
    
    
    
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        worst_delay<=8'b0;
    else if(current_state==5 && counter==0)
        worst_delay<=distance[1];
    else
        worst_delay<=8'b0;
end
endmodule

