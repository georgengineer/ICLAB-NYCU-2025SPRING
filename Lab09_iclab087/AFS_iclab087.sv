//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2025/4
//		Version		: v1.0
//   	File Name   : AFS.sv
//   	Module Name : AFS
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module AFS(input clk, INF.AFS_inf inf);
import usertype::*;
    //==============================================//
    //              logic declaration               //
    // ============================================ //


Action action_reg;
Warn_Msg warn_msg_reg;
Strategy_Type strategy_type_reg;
Mode mode_reg;
Date date_reg;

Order_Info order_info_reg;
Data_No data_no_reg;
Data data_reg;
Stock Rose_reg,Lily_reg,Carnation_reg,Baby_Breath_reg;



Data_Dir dram_data_reg;
Month month_reg;
Day   day_reg;


logic [63:0]data_temp;
logic [2:0]purchase_counter;
logic [2:0]restock_counter;

logic restock_done_flag;
//logic [2:0]current_state,next_state;

logic sel_action_valid_reg;
logic data_no_valid_reg;
logic [16:0]dram_addr;
assign dram_addr={1'b1,4'b0000,1'b0,data_no_reg,3'b000};
typedef enum logic[2:0]{
    IDLE=3'b000,
    PURCHASE =3'b001,
    RESTOCK =3'b010,
    CHECK=3'b011,
    OUTPUT =3'b100,
    FIVE=3'b101,
    WRITE_IN_DRAM=3'b110,
    DONE=3'b111

}FSM;
FSM current_state,next_state;
logic R_handshake;
logic [2:0]write_in_counter;
logic dram_;
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        dram_ <=0;
    end
    else if(current_state==OUTPUT)begin
        dram_<=1;
    end
    else if(inf.B_VALID)begin
        dram_<=0;
    end
end
assign R_handshake= (inf.R_VALID && inf.R_READY);
//FSM 
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end
logic B_VALID_reg;
always_ff @(posedge clk)begin
    if(current_state==IDLE)
        if(inf.B_VALID)
            B_VALID_reg<=1;
    else
        B_VALID_reg<=0;

end
always_comb begin
    case(current_state)
    IDLE:begin
        if(action_reg==Purchase && data_no_valid_reg)
            next_state=PURCHASE;
        else if(action_reg==Restock && restock_counter==4)
            next_state=RESTOCK;
        else if(action_reg==Check_Valid_Date && data_no_valid_reg)
            next_state=CHECK;
        else 
            next_state=IDLE;
        //next_state=(action_reg==Purchase)?PURCHASE:(action_reg==Restock)?RESTOCK:(action_reg==Check_Valid_Date)?CHECK:IDLE;
    end
    PURCHASE:next_state=(inf.R_VALID && inf.R_READY)?WRITE_IN_DRAM:PURCHASE;
    RESTOCK :next_state=WRITE_IN_DRAM;
    CHECK   :next_state=(inf.R_VALID && inf.R_READY)?WRITE_IN_DRAM:CHECK;
    OUTPUT :begin
        /*if(action_reg==Purchase &&warn_msg_reg==No_Warn)
            next_state=IDLE;
        else if(action_reg==Restock)
            next_state=IDLE;
        else if(action_reg==Check_Valid_Date)
            next_state=IDLE;
        else 
            next_state=OUTPUT;*/
        
            next_state=IDLE;
    end
    WRITE_IN_DRAM:begin
        if(action_reg==Purchase)
            next_state=DONE;
        /*else if (action_reg==Purchase)
            next_state=OUTPUT;*/
        else if(action_reg==Restock &&inf.B_VALID)
            next_state=OUTPUT;
        else if(action_reg==Check_Valid_Date)
            next_state=OUTPUT;
        else 
            next_state=WRITE_IN_DRAM;
        /*if(inf.B_VALID)
            next_state=OUTPUT;
        else
            next_state=WRITE_IN_DRAM;*/
    end
    DONE:begin
        if(action_reg==Purchase && warn_msg_reg==No_Warn)begin
            if(inf.B_VALID)
                next_state=OUTPUT;
            else 
                next_state=DONE;
        end
        else if(action_reg==Purchase)
                next_state=OUTPUT;
        else 
            next_state=OUTPUT;
    end
    default:next_state=IDLE;
    endcase
end

always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        data_no_valid_reg<=0;
    end
    else begin
        data_no_valid_reg <= inf.data_no_valid;
    end
end

always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        sel_action_valid_reg <=0;
    end
    else if(inf.sel_action_valid)
        sel_action_valid_reg <=inf.sel_action_valid;
    else 
        sel_action_valid_reg<=0;
end
// Reg receive data when in_valid
//action
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        action_reg <= Purchase; //2'b00;
    end
    else if(inf.sel_action_valid)begin
        action_reg <= inf.D.d_act[0];
    end
end
//strategy 
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        strategy_type_reg <= Strategy_A; //3'b00;
    end
    else if(inf.strategy_valid)begin
        strategy_type_reg <= inf.D.d_strategy[0];
    end
end

//mode
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        mode_reg <= Single; //2'b00;
    end
    else if(inf.mode_valid)begin
        mode_reg <= inf.D.d_mode[0];
    end
end

//Month and Day
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        date_reg.M <= 4'b0;
        date_reg.D <= 5'b0;
    end
    else if(inf.date_valid)begin
        date_reg.M <= inf.D.d_date[0].M; //Wrong example date_reg.M <= inf.D.d_mode[0][1] date_reg.M <= inf.D.d_mode[0][8:5]
        date_reg.D <= inf.D.d_date[0].D;
    end
end
//data_no
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        data_no_reg <= 8'b0;
    end
    else if(inf.data_no_valid)begin
        data_no_reg <= inf.D.d_data_no[0];
    end
end
//restock
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        Rose_reg        <= 12'b0;
        Lily_reg        <= 12'b0;
        Carnation_reg   <= 12'b0;
        Baby_Breath_reg <= 12'b0;
    end
    else if(inf.restock_valid)begin
        Rose_reg        <= Lily_reg;
        Lily_reg        <= Carnation_reg;
        Carnation_reg   <= Baby_Breath_reg;
        Baby_Breath_reg <= inf.D.d_stock[0];
    end
end 
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        data_temp <=64'b0;
    end
    else if(R_handshake)begin //inf.R_READY && inf.R_VALID
        data_temp <= inf.R_DATA;
    end
end
always_comb begin
    dram_data_reg.Rose       =data_temp[63:52]; //12bit Rose
    dram_data_reg.Lily       =data_temp[51:40]; //12bit Lily
    dram_data_reg.M          =data_temp[39:32]; //8bit  Month
    dram_data_reg.Carnation  =data_temp[31:20]; //12bit Carnation
    dram_data_reg.Baby_Breath=data_temp[19: 8]; //12bit Baby_Breath
    dram_data_reg.D          =data_temp[ 7: 0]; //8bit  Day
end

always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        write_in_counter <=0;
    end
    else if(current_state==OUTPUT && action_reg==Purchase &&warn_msg_reg==No_Warn)begin
        write_in_counter <=1;
    end
    else 
        write_in_counter <=0;
    /*else if(current_state==WRITE_IN_DRAM)begin
        write_in_counter<=write_in_counter+1'b1;
    end*/
end
logic r_valid_reg;
logic r_valid_reg_2;
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        r_valid_reg<=0;
    end
    else if(current_state==OUTPUT)
        r_valid_reg<=0;

    else if(inf.R_VALID)
        r_valid_reg<=1'b1;



end
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        r_valid_reg_2<=0;
    end
    else if(r_valid_reg)begin
        r_valid_reg_2<=1'b1;
    end
    else  begin
        r_valid_reg_2<=0;
    end
end
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        purchase_counter<=0;
    end
    else begin
        purchase_counter<=0;
    end
end
/*
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        restock_counter <=0;
    end
    else if(current_state==OUTPUT)
        restock_counter <= 0;
    else if(inf.restock_valid)begin
        restock_counter <= restock_counter+1'b1;
    end
    else if(restock_counter==4 && inf.R_VALID)
        restock_counter <= restock_counter;
    else if(restock_counter==4 || restock_counter==5)begin
        restock_counter <= restock_counter+1'b1;
    end
    else begin
        restock_counter <= restock_counter;
    end    
end
*/
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n)
        restock_counter <= 0;
    else if (current_state == OUTPUT)
        restock_counter <= 0;
    else if (inf.restock_valid)
        restock_counter <= restock_counter + 1;
    else if (restock_counter == 4 && r_valid_reg)
        restock_counter <= restock_counter + 1;
    else if (restock_counter == 5)
        restock_counter <= restock_counter + 1;
end

always_comb begin
    if(restock_counter==4)
        restock_done_flag=1;
    else 
        restock_done_flag=0;
end

logic date_warning;
logic stock_warning;
logic restock_warning;
logic dram_ready;

logic compare_Rose       ;
logic compare_Lily       ;
logic compare_Carnation  ;
logic compare_Baby_Breath;
logic write_dram;
assign dram_ready=(inf.R_VALID && inf.R_READY)?1'b1:1'b0;
logic [12:0]a,b,c,d;
logic [12:0] Rose_require, Lily_require, Carnation_require, Baby_Breath_require; //1023
logic [63:0]dram_new_data;



always_comb begin
    if(action_reg==Purchase)
        dram_new_data={Rose_require[11:0],Lily_require[11:0],4'b0,dram_data_reg.M,Carnation_require[11:0],Baby_Breath_require[11:0],3'b0,dram_data_reg.D};
    else if(action_reg==Restock)
        dram_new_data={Rose_require[11:0],Lily_require[11:0],4'b0,date_reg.M,Carnation_require[11:0],Baby_Breath_require[11:0],3'b0,date_reg.D};
    else 
        dram_new_data={Rose_require[11:0],Lily_require[11:0],dram_data_reg.M,Carnation_require[11:0],Baby_Breath_require[11:0],dram_data_reg.D};
end
// =================  Dram AXI  ================= //
// Read Valid
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        inf.AR_VALID <=0;
    end
    else if(inf.AR_READY)
        inf.AR_VALID <= 0;

    else if(data_no_valid_reg)begin
         inf.AR_VALID <=1;
    end
end
// Read Address
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        inf.AR_ADDR <=0;
    end
    else if(inf.AR_READY)
        inf.AR_ADDR  <= 0;
    else if(data_no_valid_reg)begin
         inf.AR_ADDR <= dram_addr;
         
    end
end

// Read 
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)      
        inf.R_READY <= 0;
    else if(inf.AR_READY)
        inf.R_READY <= 1;
    else if(R_handshake)
        inf.R_READY <= 0;
end


//W_VALID
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n) begin
        inf.W_VALID <= 1'b0;
    end
    else if (inf.W_READY) begin
        inf.W_VALID <= 1'b0;
    end
    else if (inf.AW_READY) begin 
        inf.W_VALID <= 1'b1;
    end
end

//W_DATA
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n) begin 
        inf.W_DATA <= 'b0;
    end
    else if (inf.W_READY) begin
        inf.W_DATA <= 'b0;
    end
    else if (inf.AW_READY) begin
        inf.W_DATA <= dram_new_data;
    end
end
//AW_VALID
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n) begin 
        inf.AW_VALID <= 1'b0;
    end
    else if(inf.AW_READY || inf.W_VALID)begin
        inf.AW_VALID <= 1'b0;
    end
    else if(write_dram)begin
        inf.AW_VALID <= 1'b1;
    end
end
//AW_ADDR
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n) begin 
        inf.AW_ADDR <= 1'b0;
    end
    else if(inf.AW_READY || inf.W_VALID)begin
        inf.AW_ADDR <= 1'b0;
    end
    else if(write_dram)begin
        inf.AW_ADDR <= dram_addr;
    end
end
//B_READY
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n) begin
        inf.B_READY <= 1'b0;
    end
    else if (inf.B_VALID) begin
        inf.B_READY <= 1'b0;
    end
    else if (inf.AW_READY) begin 
        inf.B_READY <= 1'b1;
    end
end
logic r_ready_reg;
logic write_dram_once;
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n) begin 
        r_ready_reg<=0;
    end
    else if(current_state==OUTPUT)begin
        r_ready_reg<=0;
    end
    else if(inf.R_VALID)begin
        r_ready_reg <=1;
    end
end
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n) begin 
        write_dram <= 0;
    end
    else if(inf.AW_READY)begin
        write_dram <= 0;
    end
    else if(current_state==WRITE_IN_DRAM && r_ready_reg)begin
        if(action_reg==Restock )begin
            if(write_dram_once!=1)
                write_dram <=1;
            else
                write_dram <=0;
        end
    end
    else if(current_state==DONE && action_reg==Purchase && r_ready_reg)begin
        if(warn_msg_reg==No_Warn)begin
            if(write_dram_once!=1)
                write_dram <=1;
            else
                write_dram <=0;
        end
        /*else begin
            if(write_dram_once!=1)
                write_dram <=0;
            else 
                write_dram <=0;
        end*/
    end 
    /*else if(current_state==OUTPUT && action_reg==Purchase)begin
        if(warn_msg_reg==No_Warn)
            if(write_dram_once!=1) 
                    write_dram <=1;
            else
                write_dram <=0;
    end*/
end

always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n) begin 
        write_dram_once<=0;
    end
    else if (current_state==IDLE)
        write_dram_once<=0;
    else if(current_state==WRITE_IN_DRAM && inf.AW_READY && inf.AW_VALID)begin
        write_dram_once<=1;
    end
    else if(current_state==DONE && inf.AW_READY && inf.AW_VALID)begin
        write_dram_once<=1;
    end
end

// =================  Purchase  ================= //
logic[5:0]t1,t2,t3,t4,t5,t6;


assign t1 =date_reg.M;
assign t2 =dram_data_reg.M;
assign t3 =date_reg.D ;
assign t4 =dram_data_reg.D;


always_ff @(posedge clk)begin
    if ((date_reg.M < dram_data_reg.M )||((date_reg.M == dram_data_reg.M) &&(date_reg.D < dram_data_reg.D)))
        date_warning<=1;
    else 
        date_warning<=0;
end
always_ff @(posedge clk)begin
    if(compare_Rose & compare_Lily & compare_Carnation & compare_Baby_Breath)
        stock_warning<=0;
    else 
        stock_warning<=1;
end

always_ff @(posedge clk)begin
    if(restock_counter==5)begin
        if(Rose_require[12] || Lily_require[12] || Carnation_require[12] || Baby_Breath_require[12])
            restock_warning<=1;
        else 
            restock_warning<=0;
    end
    else begin
        restock_warning<=restock_warning;
    end
end 
/*
logic [11:0] Rose_reg_latch, Lily_reg_latch, Carnation_reg_latch, Baby_Breath_reg_latch;

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        Rose_reg_latch        <= 0;
        Lily_reg_latch        <= 0;
        Carnation_reg_latch   <= 0;
        Baby_Breath_reg_latch <= 0;
    end else if (action_reg == Restock && restock_counter == 4) begin
        Rose_reg_latch        <= Rose_reg;
        Lily_reg_latch        <= Lily_reg;
        Carnation_reg_latch   <= Carnation_reg;
        Baby_Breath_reg_latch <= Baby_Breath_reg;
    end
end*/
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        Rose_require         <= 'd0;
        Lily_require         <= 'd0;
        Carnation_require    <= 'd0;
        Baby_Breath_require  <= 'd0;
    end 
    else if(action_reg==Purchase &&current_state==WRITE_IN_DRAM)begin // dram_ready=(inf.R_VALID && inf.R_READY)
        if (compare_Rose) begin
            Rose_require <=dram_data_reg.Rose - Rose_require; 
        end 
        else begin
            Rose_require <=Rose_require; 
        end
        
        if (compare_Lily) begin
            Lily_require <= dram_data_reg.Lily - Lily_require;
        end 
        else begin
            Lily_require <= Lily_require;
        end
         
        if (compare_Carnation) begin
            Carnation_require <= dram_data_reg.Carnation - Carnation_require;
        end else begin
            Carnation_require <= Carnation_require;
        end
         
        if (compare_Baby_Breath) begin
            Baby_Breath_require <= dram_data_reg.Baby_Breath - Baby_Breath_require;
        end 
        else begin
            Baby_Breath_require <= Baby_Breath_require;
        end
    end
    else if(action_reg==Purchase && inf.date_valid)begin
        case (strategy_type_reg)
            Strategy_A: begin // 100% assigned to Rose only
                if (mode_reg == Single) begin
                    Rose_require         <= 'd120;
                    Lily_require         <= 'd0;
                    Carnation_require    <= 'd0;
                    Baby_Breath_require  <= 'd0;
                end 
                else if (mode_reg == Group_Order) begin
                    Rose_require         <= 'd480;
                    Lily_require         <= 'd0;
                    Carnation_require    <= 'd0;
                    Baby_Breath_require  <= 'd0;
                end
                else if (mode_reg == Event) begin
                    Rose_require         <= 'd960;
                    Lily_require         <= 'd0;
                    Carnation_require    <= 'd0;
                    Baby_Breath_require  <= 'd0;
                end
            end

            Strategy_B: begin // 100% assigned to Lily only
                if (mode_reg == Single) begin
                    Rose_require         <= 'd0;
                    Lily_require         <= 'd120;
                    Carnation_require    <= 'd0;
                    Baby_Breath_require  <= 'd0;
                end 
                else if (mode_reg == Group_Order) begin
                    Rose_require         <= 'd0;
                    Lily_require         <= 'd480;
                    Carnation_require    <= 'd0;
                    Baby_Breath_require  <= 'd0;
                end 
                else if (mode_reg == Event) begin
                    Rose_require         <= 'd0;
                    Lily_require         <= 'd960;
                    Carnation_require    <= 'd0;
                    Baby_Breath_require  <= 'd0;
                end
            end

            Strategy_C: begin // 100% assigned to Carnation only
                if (mode_reg == Single) begin
                    Rose_require         <= 'd0;
                    Lily_require         <= 'd0;
                    Carnation_require    <= 'd120;
                    Baby_Breath_require  <= 'd0;
                end 
                else if (mode_reg == Group_Order) begin
                    Rose_require         <= 'd0;
                    Lily_require         <= 'd0;
                    Carnation_require    <= 'd480;
                    Baby_Breath_require  <= 'd0;
                end 
                else if (mode_reg == Event) begin
                    Rose_require         <= 'd0;
                    Lily_require         <= 'd0;
                    Carnation_require    <= 'd960;
                    Baby_Breath_require  <= 'd0;
                end
            end

            Strategy_D: begin // 100% assigned to Baby’s Breath only
                if (mode_reg == Single) begin
                    Rose_require         <= 'd0;
                    Lily_require         <= 'd0;
                    Carnation_require    <= 'd0;
                    Baby_Breath_require  <= 'd120;
                end 
                else if (mode_reg == Group_Order) begin
                    Rose_require         <= 'd0;
                    Lily_require         <= 'd0;
                    Carnation_require    <= 'd0;
                    Baby_Breath_require  <= 'd480;
                end 
                else if (mode_reg == Event) begin
                    Rose_require         <= 'd0;
                    Lily_require         <= 'd0;
                    Carnation_require    <= 'd0;
                    Baby_Breath_require  <= 'd960;
                end
            end

            Strategy_E: begin // 50% to Rose, 50% to Lily
                if (mode_reg == Single) begin
                    Rose_require         <= 'd60;
                    Lily_require         <= 'd60;
                    Carnation_require    <= 'd0;
                    Baby_Breath_require  <= 'd0;
                end 
                else if (mode_reg == Group_Order) begin
                    Rose_require         <= 'd240;
                    Lily_require         <= 'd240;
                    Carnation_require    <= 'd0;
                    Baby_Breath_require  <= 'd0;
                end 
                else if (mode_reg == Event) begin
                    Rose_require         <= 'd480;
                    Lily_require         <= 'd480;
                    Carnation_require    <= 'd0;
                    Baby_Breath_require  <= 'd0;
                end
            end

            Strategy_F: begin // 50% to Carnation, 50% to Baby Breath
                if (mode_reg == Single) begin
                    Rose_require         <= 'd0;
                    Lily_require         <= 'd0;
                    Carnation_require    <= 'd60;
                    Baby_Breath_require  <= 'd60;
                end 
                else if (mode_reg == Group_Order) begin
                    Rose_require         <= 'd0;
                    Lily_require         <= 'd0;
                    Carnation_require    <= 'd240;
                    Baby_Breath_require  <= 'd240;
                end 
                else if (mode_reg == Event) begin
                    Rose_require         <= 'd0;
                    Lily_require         <= 'd0;
                    Carnation_require    <= 'd480;
                    Baby_Breath_require  <= 'd480;
                end
            end

            Strategy_G: begin // 50% to Rose, 50% to Carnation
                if (mode_reg == Single) begin
                    Rose_require         <= 'd60;
                    Lily_require         <= 'd0;
                    Carnation_require    <= 'd60;
                    Baby_Breath_require  <= 'd0;
                end 
                else if (mode_reg == Group_Order) begin
                    Rose_require         <= 'd240;
                    Lily_require         <= 'd0;
                    Carnation_require    <= 'd240;
                    Baby_Breath_require  <= 'd0;
                end 
                else if (mode_reg == Event) begin
                    Rose_require         <= 'd480;
                    Lily_require         <= 'd0;
                    Carnation_require    <= 'd480;
                    Baby_Breath_require  <= 'd0;
                end
            end

            Strategy_H: begin // 25% equally to all four types
                if (mode_reg == Single) begin
                    Rose_require         <= 'd30;
                    Lily_require         <= 'd30;
                    Carnation_require    <= 'd30;
                    Baby_Breath_require  <= 'd30;
                end 
                else if (mode_reg == Group_Order) begin
                    Rose_require         <= 'd120;
                    Lily_require         <= 'd120;
                    Carnation_require    <= 'd120;
                    Baby_Breath_require  <= 'd120;
                end 
                else if (mode_reg == Event) begin
                    Rose_require         <= 'd240;
                    Lily_require         <= 'd240;
                    Carnation_require    <= 'd240;
                    Baby_Breath_require  <= 'd240;
                end
            end
            default: begin
                Rose_require         <= 'd0;
                Lily_require         <= 'd0;
                Carnation_require    <= 'd0;
                Baby_Breath_require  <= 'd0;
            end
        endcase
    end
    /*else if(action_reg==Restock && restock_counter==4)begin


    end*/
    //else if(action_reg==Restock && restock_counter==4 )begin //r_valid_reg)begin
    else if(action_reg==Restock && restock_counter==4)begin
        Rose_require        <=(dram_data_reg.Rose       +Rose_reg       ); 
        Lily_require        <=(dram_data_reg.Lily       +Lily_reg       );
        Carnation_require   <=(dram_data_reg.Carnation  +Carnation_reg  );
        Baby_Breath_require <=(dram_data_reg.Baby_Breath+Baby_Breath_reg);
    end
    //else if(action_reg==Restock && restock_counter==5 )
    else if(action_reg==Restock && restock_counter==5)begin
        Rose_require        <=(Rose_require        [12]==1'b1)? 'd4095:Rose_require        ;
        Lily_require        <=(Lily_require        [12]==1'b1)? 'd4095:Lily_require        ;
        Carnation_require   <=(Carnation_require   [12]==1'b1)? 'd4095:Carnation_require   ;
        Baby_Breath_require <=(Baby_Breath_require [12]==1'b1)? 'd4095:Baby_Breath_require ;
    end
end

// Combinational comparison for all four flowers
always_comb begin
    compare_Rose        = (Rose_require        <= dram_data_reg.Rose       )?1'b1:1'b0;
    compare_Lily        = (Lily_require        <= dram_data_reg.Lily       )?1'b1:1'b0;
    compare_Carnation   = (Carnation_require   <= dram_data_reg.Carnation  )?1'b1:1'b0;
    compare_Baby_Breath = (Baby_Breath_require <= dram_data_reg.Baby_Breath)?1'b1:1'b0;
end





/*
logic strategy_a_flag,strategy_b_flag,strategy_c_flag,strategy_d_flag,strategy_e_flag,strategy_f_flag,strategy_g_flag,strategy_h_flag;

always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        strategy_a_flag <= 0;
        strategy_b_flag <= 0;
        strategy_c_flag <= 0;
        strategy_d_flag <= 0;
        strategy_e_flag <= 0;
        strategy_f_flag <= 0;
        strategy_g_flag <= 0;
        strategy_h_flag <= 0;
    end
    else begin
        case(strategy_type_reg)
        Strategy_A :begin
            if(mode_reg==Single)

            else if(mode_reg==Group_Order)

            else 

        end
        Strategy_B :
        Strategy_C :
        Strategy_D :
        Strategy_E :
        Strategy_F :
        Strategy_G :
        Strategy_H :
        default    :begin
        strategy_a_flag <= 0;
        strategy_b_flag <= 0;
        strategy_c_flag <= 0;
        strategy_d_flag <= 0;
        strategy_e_flag <= 0;
        strategy_f_flag <= 0;
        strategy_g_flag <= 0;
        strategy_h_flag <= 0;
        end
        endcase
    end
end
*/
/*
always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin

    end
    else begin

    end
end
*/








//Warn message
always_comb begin
    if(action_reg == Purchase)begin
        if(date_warning)begin
            warn_msg_reg = Date_Warn;
        end
        else if(stock_warning)begin
            warn_msg_reg = Stock_Warn;
        end
        else begin
            warn_msg_reg = No_Warn;
        end
    end
    else if(action_reg == Restock)begin
        if(restock_warning)
            warn_msg_reg = Restock_Warn;
        else 
            warn_msg_reg = No_Warn;
    end
    else begin//action_reg == Check_Valid_Date
        if(date_warning)
            warn_msg_reg = Date_Warn;
        else 
            warn_msg_reg = No_Warn;
    end
end







//Output 
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.warn_msg <= No_Warn;
    end
    else if(current_state==OUTPUT)
        inf.warn_msg <= warn_msg_reg;
    else 
        inf.warn_msg <= No_Warn;
end


always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.complete <= 0;
    end
    else if(current_state==OUTPUT)begin  
        inf.complete <= (warn_msg_reg==No_Warn);
    end
    else begin
        inf.complete <= 0;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.out_valid <= 0;
    end
    else if(current_state==OUTPUT)
        inf.out_valid <= 1;
    else 
        inf.out_valid <= 0;
end

endmodule



