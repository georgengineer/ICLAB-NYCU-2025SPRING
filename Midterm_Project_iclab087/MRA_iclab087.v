
module MRA(
    // CHIP IO
    clk             ,   
    rst_n           ,   
    in_valid        ,   
    frame_id        ,   
    net_id          ,     
    loc_x           ,     
    loc_y           ,
    cost            ,       
    busy            ,

    // AXI4 IO
         arid_m_inf,
       araddr_m_inf,
        arlen_m_inf,
       arsize_m_inf,
      arburst_m_inf,
      arvalid_m_inf,
      arready_m_inf,
    
          rid_m_inf,
        rdata_m_inf,
        rresp_m_inf,
        rlast_m_inf,
       rvalid_m_inf,
       rready_m_inf,
    
         awid_m_inf,
       awaddr_m_inf,
       awsize_m_inf,
      awburst_m_inf,
        awlen_m_inf,
      awvalid_m_inf,
      awready_m_inf,
    
        wdata_m_inf,
        wlast_m_inf,
       wvalid_m_inf,
       wready_m_inf,
    
          bid_m_inf,
        bresp_m_inf,
       bvalid_m_inf,
       bready_m_inf 
);
// ===============================================================
//                      Parameter Declaration 
// ===============================================================
parameter ID_WIDTH=4, DATA_WIDTH=128, ADDR_WIDTH=32;    // DO NOT modify AXI4 Parameter
parameter SRAM_ADDR_BIT=6;
// ===============================================================
//                      Input / Output 
// ===============================================================

// << CHIP io port with system >>
input               clk, rst_n;
input               in_valid;
input  [4:0]        frame_id;
input  [3:0]        net_id;     
input  [5:0]        loc_x; 
input  [5:0]        loc_y; 
output reg [13:0]   cost;
output reg          busy;       
  
// ------------------------
// <<<<< AXI READ >>>>>
// ------------------------
// (1)  axi read address channel 
output wire [ID_WIDTH-1:0]      arid_m_inf;
output wire [1:0]            arburst_m_inf;
output wire [2:0]             arsize_m_inf;
output wire [7:0]              arlen_m_inf;
output wire                  arvalid_m_inf;
input  wire                  arready_m_inf;
output wire [ADDR_WIDTH-1:0]  araddr_m_inf;
// ------------------------
// (2)  axi read data channel 
input  wire [ID_WIDTH-1:0]       rid_m_inf;//unuse
input  wire                   rvalid_m_inf;//use the judge if statement
output wire                   rready_m_inf;//Decide by me , 
input  wire [DATA_WIDTH-1:0]   rdata_m_inf;//128bit data
input  wire                    rlast_m_inf;//unuse
input  wire [1:0]              rresp_m_inf;//unuse
// ------------------------
// <<<<< AXI WRITE >>>>>
// ------------------------
// (1)  axi write address channel 
output wire [ID_WIDTH-1:0]      awid_m_inf;
output wire [1:0]            awburst_m_inf;
output wire [2:0]             awsize_m_inf;
output wire [7:0]              awlen_m_inf;
output wire                  awvalid_m_inf;
input  wire                  awready_m_inf;
output wire [ADDR_WIDTH-1:0]  awaddr_m_inf;
// -------------------------
// (2)  axi write data channel 
output wire                   wvalid_m_inf;
input  wire                   wready_m_inf;
output wire [DATA_WIDTH-1:0]   wdata_m_inf;
output wire                    wlast_m_inf;
// -------------------------
// (3)  axi write response channel 
input  wire  [ID_WIDTH-1:0]      bid_m_inf;
input  wire                   bvalid_m_inf;
output wire                   bready_m_inf;
input  wire  [1:0]             bresp_m_inf;
// -----------------------------
assign awburst_m_inf = 2'd1;
assign awsize_m_inf = 3'b100;
assign arlen_m_inf = 8'd127;
assign awlen_m_inf = 8'd127;
// << Burst & ID >>
assign arid_m_inf = 4'd0;           
assign arburst_m_inf = 2'd1; 
assign awid_m_inf = 4'd0;      
assign arsize_m_inf = 3'b100;      

reg [3:0] net_id_buf[0:14];
reg [5:0] source_x_temp[0:14];
reg [5:0] source_y_temp[0:14];
reg [5:0] sink_x_temp[0:14];
reg [5:0] sink_y_temp[0:14];
reg [4:0] frame_id_temp;

reg [1:0] map[0:63][0:63];
reg [6:0] cur_addr;
reg [5:0] current_x, current_y, next_x, next_y;
reg [3:0] weight, weight_tmp;
reg [3:0] cur_net_index;

// ===============================================================
//                      Variable Declare
// ===============================================================
wire [5:0] cur_source_x   = source_x_temp[cur_net_index];
wire [5:0] cur_source_y   = source_y_temp[cur_net_index];
wire [5:0] current_sink_x = sink_x_temp[cur_net_index];
wire [5:0] current_sink_y = sink_y_temp[cur_net_index];
wire [5:0] cur_net_id = net_id_buf[cur_net_index];
wire [5:0] cur_x_add1 = current_x + 6'd1;wire [5:0] cur_y_add1 = current_y + 6'd1;
wire [5:0] cur_x_sub1 = current_x - 6'd1;wire [5:0] cur_y_sub1 = current_y - 6'd1;
wire signal_ready;

reg [3:0] current_state, next_state;
reg [4:0] in_counter;
wire [3:0] index = in_counter[4:1];
wire index2=(in_counter[0]==0)?1'b1:1'b0;

reg location_ok;
reg [1:0] propagation_ripple_counter;
wire[1:0]propagation_ripple;

wire LSB_one = (cur_x_add1[5]) ? 1 : 0;
wire LSB_minus_one = (cur_x_sub1[5]) ? 1 : 0;
wire LSB_zero = (current_x[5]) ? 1 : 0;
wire [3:0] weight_or_data = (!location_ok) ? {2'b00,2'b10} : {2'b00,2'b01} ;
reg [7:0] sram_addr;
wire [DATA_WIDTH-1:0]weight_output_replacement;

always @(*) begin
    if (frame_id_temp > 5'd15) begin
        sram_addr = {frame_id_temp[4:1], frame_id_temp[0], 3'b000}; 
    end else begin
        sram_addr = {frame_id_temp[4:1], frame_id_temp[0], 3'b000};  
    end
end


reg [5:0] find_position;
reg [6:0] concat_point;
assign concat_point = {find_position[4:0], 1'b0,1'b0};
reg [DATA_WIDTH-1:0] location_input,weight_input;
reg [SRAM_ADDR_BIT:0]location_address, weight_address;
reg location_web, weight_web;
wire [DATA_WIDTH-1:0] location_output, weight_output;

//assign weight_output_replacement={weight_output[concat_point + 7'd3],
//              weight_output[concat_point + 7'd2],
//              weight_output[concat_point + 7'd1],
//              weight_output[concat_point]};

SRAM_128X128_instantiation SRAM_Location(.CLK(clk),.CS(1'b1),.OE(1'b1), .WEB(location_web), .A(location_address), .DI(location_input), .DO(location_output));
SRAM_128X128_instantiation SRAM_Weight  (.CLK(clk),.CS(1'b1),.OE(1'b1), .WEB(weight_web)  , .A(weight_address)  , .DI(weight_input)  , .DO(weight_output  ));

integer i,j;
// ===============================================================
//                      Finite current_state Machine
// ===============================================================
wire not_top_edge    = (current_y != 6'd0);
wire not_bottom_edge = (current_y != 6'd63);
wire not_right_edge  = (current_x != 6'd63);
wire propagation_check_bottom_edge=(not_bottom_edge && map[cur_y_add1][current_x] == propagation_ripple)?1'b1:1'b0;
wire propagation_check_top_edge   =(not_top_edge    && map[cur_y_sub1][current_x] == propagation_ripple)?1'b1:1'b0;
wire propagation_check_right_edge =(not_right_edge  && map[current_y][cur_x_add1] == propagation_ripple)?1'b1:1'b0;
wire [5:0] y = cur_addr[6:1];	wire [5:0] x = (cur_addr[0]==1) ? 32 : 0;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        frame_id_temp <= 0;
        for(int i=0;i<15;i=i+1)begin  
            net_id_buf[i] <= 0;
        end
    end
    else if(in_valid)begin
        case(index2)
        0:begin
            frame_id_temp <= frame_id;
            sink_x_temp[index] <= loc_x;
            sink_y_temp[index] <= loc_y;
        end
        1:begin 
            frame_id_temp <= frame_id;
            net_id_buf[index] <= net_id;
            source_x_temp[index] <= loc_x;
            source_y_temp[index] <= loc_y;
        end
        endcase
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        in_counter<=0;
    end
    else if(in_valid)begin
        in_counter <= in_counter + 5'd1;
    end
    else if(current_state==11)begin
        in_counter <= 5'd0; 
    end
    else begin
        in_counter<=in_counter;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        busy <= 0;
    end
    else if(in_valid || (!location_ok && current_state == 0  &&signal_ready))begin
         busy <= 0;
    end
    else begin
        busy <= 1;
    end
end

assign propagation_ripple=(propagation_ripple_counter==0 || propagation_ripple_counter==1)?2:3;





/*
always@(*) begin
    location_web = 1;
    case(current_state)
        3: if(rvalid_m_inf) location_web = 0; 
        7: location_web = 0;
    endcase 
end
*/
always@(*) begin
    if(current_state==3 && rvalid_m_inf)
        location_web = 0; 
    else if (current_state==7 && rvalid_m_inf==0 && signal_ready)
        location_web = 0; 
    else 
        location_web = 1; 
end
wire [127:0] location_temp;

assign location_temp = (current_state == 7) ? 
    (location_output & ~(128'hF << concat_point)) | ({{124{1'b0}}, cur_net_id} << concat_point) :
    rdata_m_inf;

//assign location_input = location_temp;

always@(*) begin
    if(current_state==7)
        location_input=location_temp;
    else
        location_input=rdata_m_inf;
end
/*
always@(*) begin
    case(current_state)
        7: begin
            location_input = location_output;
            location_input[concat_point+7'd3] = cur_net_id[3];
            location_input[concat_point+7'd2] = cur_net_id[2];
            location_input[concat_point+7'd1] = cur_net_id[1];
            location_input[concat_point] = cur_net_id[0];
        end
        default: location_input = rdata_m_inf;
    endcase 
end
*/
always@(*) begin
    location_address = cur_addr;
    case(current_state) 
        6, 7: begin
            if(propagation_check_bottom_edge)
                location_address = {cur_y_add1, LSB_zero};
            else if(propagation_check_top_edge)
                location_address = {cur_y_sub1, LSB_zero};
            else if(propagation_check_right_edge)
                location_address = {current_y, LSB_one};
            else
                location_address = {current_y, LSB_minus_one};
        end
        10: begin if(wready_m_inf)
                location_address = cur_addr + 7'd1;
		end
		default:location_address = cur_addr;
    endcase
end
always@(*) begin
	if(!rst_n)
		weight_input=0;
	else 
    	weight_input=rdata_m_inf;
end

reg [1:0] direction;
localparam DOWN = 2'd0, UP = 2'd1, RIGHT = 2'd2, LEFT = 2'd3;

always @(*) begin
    direction = LEFT;  
    if (current_state == 6) begin
        if (propagation_check_bottom_edge)
            direction = DOWN;
        else if (propagation_check_top_edge)
            direction = UP;
        else if (propagation_check_right_edge)
            direction = RIGHT;
        else
            direction = LEFT;
    end
end 
always @(*) begin
    case (current_state)
        6: begin
            case (direction)
                DOWN:  weight_address = {cur_y_add1, LSB_zero};
                UP:    weight_address = {cur_y_sub1, LSB_zero};
                RIGHT: weight_address = {current_y, LSB_one};
                LEFT:  weight_address = {current_y, LSB_minus_one};
            endcase
        end
        default: weight_address = cur_addr;
    endcase
end
reg [1:0] dir_flag; 

always @(*) begin
    dir_flag = 2'b11;       // 2'b00: bottom, 2'b01: top, 2'b10: right, 2'b11: left
    if (current_state == 7) begin
        if (propagation_check_bottom_edge)
            dir_flag = 2'b00;// 2'b00: bottom, 2'b01: top, 2'b10: right, 2'b11: left
        else if (propagation_check_top_edge)
            dir_flag = 2'b01;// 2'b00: bottom, 2'b01: top, 2'b10: right, 2'b11: left
        else if (propagation_check_right_edge)
            dir_flag = 2'b10;// 2'b00: bottom, 2'b01: top, 2'b10: right, 2'b11: left
    end
	else 
		dir_flag = 2'b11; 
end

always @(*) begin
    case (dir_flag)
        2'b00, 2'b01: find_position = current_x;
        2'b10:       find_position = current_x + 6'd1;
        default:     find_position = current_x - 6'd1;
    endcase

end

always@(*) begin
    if(current_state==2 && rvalid_m_inf) 
        weight_web=0;
    else 
        weight_web=1;
end

assign weight_output_replacement={weight_output[concat_point + 7'd3],
              weight_output[concat_point + 7'd2],
              weight_output[concat_point + 7'd1],
              weight_output[concat_point]};
always@(*) begin
        weight=weight_output_replacement;
end
/*
always@(*) begin
    weight[3]=weight_output[concat_point + 7'd3];
	weight[2]=weight_output[concat_point + 7'd2];
	weight[1]=weight_output[concat_point + 7'd1];
	weight[0]=weight_output[concat_point];

end
*/


/* next retrace step */
always@(*) begin
    next_x = current_x;
    next_y = current_y;
    if(propagation_check_bottom_edge) next_y = current_y + 6'd1;
    else if(propagation_check_top_edge) next_y = current_y - 6'd1;
    else if(propagation_check_right_edge) next_x = current_x + 6'd1;
    else next_x = current_x - 6'd1;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
       current_state <= 0;
    end
    else begin
        current_state <= next_state;
    end
end



always@(*) begin
    next_state = current_state;
    case(current_state)
        0: begin
            if(location_ok || in_valid) 
                next_state = 1;
            else 
                next_state = 0;
        end

        1: begin
            if(arready_m_inf) begin
                if(location_ok)
                    next_state = 3;
                else 
                    next_state = 2;
            end
        end

        2: begin
            if(rvalid_m_inf && cur_addr == 7'd127) 
                next_state = 0;
        end

        3: begin
            if(rvalid_m_inf && cur_addr == 7'd127)
                next_state = 4;
        end

        4: begin
            next_state = 5;
        end

        5: begin
            if(map[current_sink_y][current_sink_x] != 0) 
                next_state = 6;
        end

        6: begin 
            next_state = 7;
        end

        7: begin
            if(next_x == cur_source_x && next_y == cur_source_y) 
                next_state = 8;
            else 
                next_state = 6;
        end

        8: begin
            if((cur_net_index + 4'd1) != index) 
                next_state = 12;
            else 
                next_state = 9;
        end

        9: begin
            if(awready_m_inf) 
                next_state = 10;
        end

        10: begin
            if(wready_m_inf && cur_addr == 7'd127) 
                next_state = 11;
        end

        11: begin
            if(bvalid_m_inf) 
                next_state = 13;
        end

        12: begin
            next_state = 4;
        end

        13: begin
            next_state = 0;
        end
    endcase
end
/*
reg check_rdata[0:31];
always@(*)begin
    for(int i=0;i<32;i=i+1)begin
        if(rdata_m_inf[i*4 +:4]==4'd0) //rdata_m_inf[i*4+3:i*4]
            check_rdata[i]=0;
        else 
            check_rdata[i]=1;
    end 
end
*/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cost <= 14'd0;
    end else if (current_state == 2) begin
        cost <= 14'd0;
    end else if (current_state == 6) begin
        cost <= cost + weight_tmp;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cur_addr <= 7'd0;
    end else if (signal_ready && current_state == 2 && rvalid_m_inf) begin
        cur_addr <= cur_addr + 7'd1;
    end else if (signal_ready && current_state == 3 && rvalid_m_inf) begin
        cur_addr <= cur_addr + 7'd1;
    end else if (signal_ready && current_state == 10 && wready_m_inf) begin
        cur_addr <= cur_addr + 7'd1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        propagation_ripple_counter <= 2'd0;
    end 
    else if (current_state == 4) begin
        propagation_ripple_counter <= 2'd0;
    end 
    else if (current_state == 5) begin
        if (map[current_sink_y][current_sink_x][1]) begin
            propagation_ripple_counter <= propagation_ripple_counter - 2'd2;
        end 
        else begin
            propagation_ripple_counter <= propagation_ripple_counter + 2'd1;
        end
    end 
    else if (current_state == 7) begin
        propagation_ripple_counter <= propagation_ripple_counter - 2'd1;
    end
    else 
        propagation_ripple_counter <= propagation_ripple_counter;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cur_net_index <= 4'd0;
    end 
    else if (current_state == 8) begin
        cur_net_index <= cur_net_index + 4'd1;
    end 
    else if (current_state == 11) begin
        cur_net_index <= 4'd0;
    end
    else 
        cur_net_index <=cur_net_index;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        location_ok <= 1'b0;
    end 
    else if (current_state == 2 && rvalid_m_inf && cur_addr == 7'd127) begin
        location_ok <= 1'b1;
    end 
    else if (current_state == 11) begin
        location_ok <= 1'b0;
    end
    else 
        location_ok <= location_ok;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_x <= 6'd0;
    end 
    else if (current_state == 4) begin
        current_x <= current_sink_x;
    end 
    else if (current_state == 7) begin
        current_x <= next_x;
    end
    else   
        current_x <= current_x;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_y <= 6'd0;
    end 
    else if (current_state == 4) begin
        current_y <= current_sink_y;
    end 
    else if (current_state == 7) begin
        current_y <= next_y;
    end
    else 
        current_y <=current_y;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        weight_tmp <= 4'd0;
    end 
    else if (current_state == 4) begin
        weight_tmp <= 4'd0;
    end 
    else if (current_state == 7) begin
        weight_tmp <= weight;
    end
    else 
        weight_tmp <=weight_tmp;
end

reg check_rdata[0:31];
always@(*)begin
    for(int i=0;i<32;i=i+1)begin
        if(rdata_m_inf[i*4+:4]==4'd0) //rdata_m_inf[i*4+3:i*4] [3:0].. [7:4]
            check_rdata[i]=0;
        else 
            check_rdata[i]=1;
    end 
end

always@(posedge clk) begin
    case(current_state)
        3:begin
            if(rvalid_m_inf==1) begin
            if (check_rdata[0])       map[y][x+0 ] <= 2'b01; else map[y][x+0 ] <= 2'b00;
            if (check_rdata[1])       map[y][x+1 ] <= 2'b01; else map[y][x+1 ] <= 2'b00;
            if (check_rdata[2])       map[y][x+2 ] <= 2'b01; else map[y][x+2 ] <= 2'b00;
            if (check_rdata[3])       map[y][x+3 ] <= 2'b01; else map[y][x+3 ] <= 2'b00;
            if (check_rdata[4])       map[y][x+4 ] <= 2'b01; else map[y][x+4 ] <= 2'b00;
            if (check_rdata[5])       map[y][x+5 ] <= 2'b01; else map[y][x+5 ] <= 2'b00;
            if (check_rdata[6])       map[y][x+6 ] <= 2'b01; else map[y][x+6 ] <= 2'b00;
            if (check_rdata[7])       map[y][x+7 ] <= 2'b01; else map[y][x+7 ] <= 2'b00;
            if (check_rdata[8])       map[y][x+8 ] <= 2'b01; else map[y][x+8 ] <= 2'b00;
            if (check_rdata[9])       map[y][x+9 ] <= 2'b01; else map[y][x+9 ] <= 2'b00;
            if (check_rdata[10])      map[y][x+10] <= 2'b01; else map[y][x+10] <= 2'b00;
            if (check_rdata[11])      map[y][x+11] <= 2'b01; else map[y][x+11] <= 2'b00;
            if (check_rdata[12])      map[y][x+12] <= 2'b01; else map[y][x+12] <= 2'b00;
            if (check_rdata[13])      map[y][x+13] <= 2'b01; else map[y][x+13] <= 2'b00;
            if (check_rdata[14])      map[y][x+14] <= 2'b01; else map[y][x+14] <= 2'b00;
            if (check_rdata[15])      map[y][x+15] <= 2'b01; else map[y][x+15] <= 2'b00;
            if (check_rdata[16])      map[y][x+16] <= 2'b01; else map[y][x+16] <= 2'b00;
            if (check_rdata[17])      map[y][x+17] <= 2'b01; else map[y][x+17] <= 2'b00;
            if (check_rdata[18])      map[y][x+18] <= 2'b01; else map[y][x+18] <= 2'b00;
            if (check_rdata[19])      map[y][x+19] <= 2'b01; else map[y][x+19] <= 2'b00;
            if (check_rdata[20])      map[y][x+20] <= 2'b01; else map[y][x+20] <= 2'b00;
            if (check_rdata[21])      map[y][x+21] <= 2'b01; else map[y][x+21] <= 2'b00;
            if (check_rdata[22])      map[y][x+22] <= 2'b01; else map[y][x+22] <= 2'b00;
            if (check_rdata[23])      map[y][x+23] <= 2'b01; else map[y][x+23] <= 2'b00;
            if (check_rdata[24])      map[y][x+24] <= 2'b01; else map[y][x+24] <= 2'b00;
            if (check_rdata[25])      map[y][x+25] <= 2'b01; else map[y][x+25] <= 2'b00;
            if (check_rdata[26])      map[y][x+26] <= 2'b01; else map[y][x+26] <= 2'b00;
            if (check_rdata[27])      map[y][x+27] <= 2'b01; else map[y][x+27] <= 2'b00;
            if (check_rdata[28])      map[y][x+28] <= 2'b01; else map[y][x+28] <= 2'b00;
            if (check_rdata[29])      map[y][x+29] <= 2'b01; else map[y][x+29] <= 2'b00;
            if (check_rdata[30])      map[y][x+30] <= 2'b01; else map[y][x+30] <= 2'b00;
            if (check_rdata[31])      map[y][x+31] <= 2'b01; else map[y][x+31] <= 2'b00;
            end
        end
        4: begin
            map[cur_source_y][cur_source_x] <= 2'd3;
            map[current_sink_y][current_sink_x] <= 2'd0;
        end
        5:begin
        for(i=0;i<64;i=i+1) begin
            for(j=0;j<64;j=j+1) begin
                    if(i==0&&j==0) begin //upper-left corner
                        if(map[0][0][1]) begin
                            if(map[0][1] == 2'd0) map[0][1] <= propagation_ripple; 
                            if(map[1][0] == 2'd0) map[1][0] <= propagation_ripple; 
                        end
                    end
                    else if(i==0&&j==63) begin //upper-right corner
                        if(map[0][63][1]) begin
                            if(map[0][62] == 2'd0) map[0][62] <= propagation_ripple; 
                            if(map[1][63] == 2'd0) map[1][63] <= propagation_ripple; 
                        end
                    end
                    else if(j==0&&i==63) begin //bottom-left corner
                        if(map[63][0][1]) begin
                            if(map[62][0] == 2'd0) map[62][0] <= propagation_ripple; 
                            if(map[63][1] == 2'd0) map[63][1] <= propagation_ripple; 

                        end
                    end
                    else if(i==63&&j==63) begin //bottom-right corner
                        if(map[63][63][1]) begin
                            if(map[62][63] == 2'd0) map[62][63] <= propagation_ripple; 
                            if(map[63][62] == 2'd0) map[63][62] <= propagation_ripple; 
                        end
                    end
                    else if(i==0) begin //upper bar
                        if(map[0][j][1]) begin
                            if(map[0][j+1] == 2'd0) map[0][j+1] <= propagation_ripple; 
                            if(map[0][j-1] == 2'd0) map[0][j-1] <= propagation_ripple; 
                            if(map[1][j] == 2'd0) map[1][j] <= propagation_ripple; 
                        end
                    end
                    else if(i==63) begin //bottom bar
                        if(map[63][j][1]) begin
                            if(map[63][j+1] == 2'd0) map[63][j+1] <= propagation_ripple; 
                            if(map[63][j-1] == 2'd0) map[63][j-1] <= propagation_ripple; 
                            if(map[62][j] == 2'd0) map[62][j] <= propagation_ripple; 
                        end
                    end
                    else if(j==0) begin //left bar
                        if(map[i][0][1]) begin
                            if(map[i+1][0] == 2'd0) map[i+1][0] <= propagation_ripple;
                            if(map[i-1][0] == 2'd0) map[i-1][0] <= propagation_ripple;
                            if(map[i][1] == 2'd0) map[i][1] <= propagation_ripple;  
                        end
                    end
                    else if(j==63) begin //right bar
                        if(map[i][63][1]) begin
                            if(map[i+1][63] == 2'd0) map[i+1][63] <= propagation_ripple;
                            if(map[i-1][63] == 2'd0) map[i-1][63] <= propagation_ripple;
                            if(map[i][62] == 2'd0) map[i][62] <= propagation_ripple;
                        end
                    end
                    else begin  //center
                        if(map[i][j][1]) begin
                            if(map[i+1][j] == 2'd0) map[i+1][j] <= propagation_ripple;
                            if(map[i-1][j] == 2'd0) map[i-1][j] <= propagation_ripple;
                            if(map[i][j+1] == 2'd0) map[i][j+1] <= propagation_ripple;
                            if(map[i][j-1] == 2'd0) map[i][j-1] <= propagation_ripple;
                        end
                    end
                end
            end
        end
        7:begin
            map[current_y][current_x] <= 2'd1;
        end
        8:begin
            map[current_y][current_x] <= 2'd1;
        end
     12:begin
        for(i=0;i<64;i=i+1) begin
                for(j=0;j<64;j=j+1) begin
                    if(i==0&&j==0) begin //upper-left corner
                        if(map[0][0][1]) begin
                             map[0][0] <= 2'd0;
                        end
                    end
                    else if(i==0&&j==63) begin //upper-right corner
                        if(map[0][63][1]) begin
                            map[i][j] <= 2'd0;
                        end
                    end
                    else if(j==0&&i==63) begin //bottom-left corner
                        if(map[63][0][1]) begin
                            map[i][j] <= 2'd0;
                        end
                    end
                    else if(i==63&&j==63) begin //bottom-right corner
                        if(map[63][63][1]) begin
                            map[i][j] <= 2'd0;
                        end
                    end
                    else if(i==0) begin //upper bar
                        if(map[0][j][1]) begin
                            map[i][j] <= 2'd0;
                        end
                    end
                    else if(i==63) begin //bottom bar
                        if(map[63][j][1]) begin
                            map[i][j] <= 2'd0;
                        end
                    end
                    else if(j==0) begin //left bar
                        if(map[i][0][1]) begin
                            map[i][j] <= 2'd0;
                        end
                    end
                    else if(j==63) begin //right bar
                        if(map[i][63][1]) begin
                            map[i][j] <= 2'd0;
                        end
                    end
                    else begin  //center
                        if(map[i][j][1]) begin
                            map[i][j] <= 2'd0; //clear map
                        end
                    end
                end
            end
        end
    endcase
end
//axi protocol
assign araddr_m_inf = (!location_ok) ? {12'd0, 4'b0010, sram_addr, 8'd0}:{12'd0, 4'b0001, sram_addr, 8'd0};
assign awaddr_m_inf = {12'd0, 4'b0001, sram_addr, 8'd0};

assign arvalid_m_inf = (current_state == 1) ? 1'b1 : 1'b0;
assign rready_m_inf  = (current_state == 1 || current_state == 2 || current_state == 3) ? 1'b1 : 1'b0;
assign awvalid_m_inf = (current_state == 9)  ? 1'b1 :
                       (current_state == 10) ? 1'b0 :
                       (current_state == 11) ? 1'b0 : 1'b0;
assign wvalid_m_inf  = (current_state == 10) ? 1'b1 :
                       (current_state == 11) ? 1'b0 :
                       (current_state == 9)  ? 1'b0 : 1'b0;

assign bready_m_inf  = (current_state == 10 || current_state == 11) ? 1'b1 : 1'b0;

assign wdata_m_inf   = (current_state == 10) ? location_output : 128'd0;

assign wlast_m_inf   = (current_state == 10 && cur_addr == 7'd127) ? 1'b1 : 1'b0;
assign signal_ready=1'b1;
endmodule

module SRAM_128X128_instantiation(
    input CLK,CS,OE,WEB,  //clk, chip_select ,output_enable,write_enable
    input [6:0]   A,
    input [127:0]DI,
    output[127:0]DO
);
SRAM_128X128 SRAM_128X128_inst(
.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .A5(A[5]), .A6(A[6]),
.DO0(DO[0]), .DO1(DO[1]), .DO2(DO[2]), .DO3(DO[3]), .DO4(DO[4]), .DO5(DO[5]), .DO6(DO[6]), .DO7(DO[7]), .DO8(DO[8]), .DO9(DO[9]), .DO10(DO[10]), .DO11(DO[11]), .DO12(DO[12]), .DO13(DO[13]), .DO14(DO[14]), .DO15(DO[15]), .DO16(DO[16]), .DO17(DO[17]), .DO18(DO[18]), .DO19(DO[19]), .DO20(DO[20]), .DO21(DO[21]), .DO22(DO[22]), .DO23(DO[23]), .DO24(DO[24]), .DO25(DO[25]), .DO26(DO[26]), .DO27(DO[27]), .DO28(DO[28]), .DO29(DO[29]), .DO30(DO[30]), .DO31(DO[31]), .DO32(DO[32]), .DO33(DO[33]), .DO34(DO[34]), .DO35(DO[35]), .DO36(DO[36]), .DO37(DO[37]), .DO38(DO[38]), .DO39(DO[39]), .DO40(DO[40]), .DO41(DO[41]), .DO42(DO[42]), .DO43(DO[43]), .DO44(DO[44]), .DO45(DO[45]), .DO46(DO[46]), .DO47(DO[47]), .DO48(DO[48]), .DO49(DO[49]), .DO50(DO[50]), .DO51(DO[51]), .DO52(DO[52]), .DO53(DO[53]), .DO54(DO[54]), .DO55(DO[55]), .DO56(DO[56]), .DO57(DO[57]), .DO58(DO[58]), .DO59(DO[59]), .DO60(DO[60]), .DO61(DO[61]), .DO62(DO[62]), .DO63(DO[63]), .DO64(DO[64]), .DO65(DO[65]), .DO66(DO[66]), .DO67(DO[67]), .DO68(DO[68]), .DO69(DO[69]), .DO70(DO[70]), .DO71(DO[71]), .DO72(DO[72]), .DO73(DO[73]), .DO74(DO[74]), .DO75(DO[75]), .DO76(DO[76]), .DO77(DO[77]), .DO78(DO[78]), .DO79(DO[79]), .DO80(DO[80]), .DO81(DO[81]), .DO82(DO[82]), .DO83(DO[83]), .DO84(DO[84]), .DO85(DO[85]), .DO86(DO[86]), .DO87(DO[87]), .DO88(DO[88]), .DO89(DO[89]), .DO90(DO[90]), .DO91(DO[91]), .DO92(DO[92]), .DO93(DO[93]), .DO94(DO[94]), .DO95(DO[95]), .DO96(DO[96]), .DO97(DO[97]), .DO98(DO[98]), .DO99(DO[99]), .DO100(DO[100]), .DO101(DO[101]), .DO102(DO[102]), .DO103(DO[103]), .DO104(DO[104]), .DO105(DO[105]), .DO106(DO[106]), .DO107(DO[107]), .DO108(DO[108]), .DO109(DO[109]), .DO110(DO[110]), .DO111(DO[111]), .DO112(DO[112]), .DO113(DO[113]), .DO114(DO[114]), .DO115(DO[115]), .DO116(DO[116]), .DO117(DO[117]), .DO118(DO[118]), .DO119(DO[119]), .DO120(DO[120]), .DO121(DO[121]), .DO122(DO[122]), .DO123(DO[123]), .DO124(DO[124]), .DO125(DO[125]), .DO126(DO[126]), .DO127(DO[127]),
.DI0(DI[0]), .DI1(DI[1]), .DI2(DI[2]), .DI3(DI[3]), .DI4(DI[4]), .DI5(DI[5]), .DI6(DI[6]), .DI7(DI[7]), .DI8(DI[8]), .DI9(DI[9]), .DI10(DI[10]), .DI11(DI[11]), .DI12(DI[12]), .DI13(DI[13]), .DI14(DI[14]), .DI15(DI[15]), .DI16(DI[16]), .DI17(DI[17]), .DI18(DI[18]), .DI19(DI[19]), .DI20(DI[20]), .DI21(DI[21]), .DI22(DI[22]), .DI23(DI[23]), .DI24(DI[24]), .DI25(DI[25]), .DI26(DI[26]), .DI27(DI[27]), .DI28(DI[28]), .DI29(DI[29]), .DI30(DI[30]), .DI31(DI[31]), .DI32(DI[32]), .DI33(DI[33]), .DI34(DI[34]), .DI35(DI[35]), .DI36(DI[36]), .DI37(DI[37]), .DI38(DI[38]), .DI39(DI[39]), .DI40(DI[40]), .DI41(DI[41]), .DI42(DI[42]), .DI43(DI[43]), .DI44(DI[44]), .DI45(DI[45]), .DI46(DI[46]), .DI47(DI[47]), .DI48(DI[48]), .DI49(DI[49]), .DI50(DI[50]), .DI51(DI[51]), .DI52(DI[52]), .DI53(DI[53]), .DI54(DI[54]), .DI55(DI[55]), .DI56(DI[56]), .DI57(DI[57]), .DI58(DI[58]), .DI59(DI[59]), .DI60(DI[60]), .DI61(DI[61]), .DI62(DI[62]), .DI63(DI[63]), .DI64(DI[64]), .DI65(DI[65]), .DI66(DI[66]), .DI67(DI[67]), .DI68(DI[68]), .DI69(DI[69]), .DI70(DI[70]), .DI71(DI[71]), .DI72(DI[72]), .DI73(DI[73]), .DI74(DI[74]), .DI75(DI[75]), .DI76(DI[76]), .DI77(DI[77]), .DI78(DI[78]), .DI79(DI[79]), .DI80(DI[80]), .DI81(DI[81]), .DI82(DI[82]), .DI83(DI[83]), .DI84(DI[84]), .DI85(DI[85]), .DI86(DI[86]), .DI87(DI[87]), .DI88(DI[88]), .DI89(DI[89]), .DI90(DI[90]), .DI91(DI[91]), .DI92(DI[92]), .DI93(DI[93]), .DI94(DI[94]), .DI95(DI[95]), .DI96(DI[96]), .DI97(DI[97]), .DI98(DI[98]), .DI99(DI[99]), .DI100(DI[100]), .DI101(DI[101]), .DI102(DI[102]), .DI103(DI[103]), .DI104(DI[104]), .DI105(DI[105]), .DI106(DI[106]), .DI107(DI[107]), .DI108(DI[108]), .DI109(DI[109]), .DI110(DI[110]), .DI111(DI[111]), .DI112(DI[112]), .DI113(DI[113]), .DI114(DI[114]), .DI115(DI[115]), .DI116(DI[116]), .DI117(DI[117]), .DI118(DI[118]), .DI119(DI[119]), .DI120(DI[120]), .DI121(DI[121]), .DI122(DI[122]), .DI123(DI[123]), .DI124(DI[124]), .DI125(DI[125]), .DI126(DI[126]), .DI127(DI[127]),
.CK(CLK), .WEB(WEB), .OE(OE), .CS(CS)
);
endmodule



