/* vim:set shiftwidth=3 softtabstop=3 expandtab: */
/* (c) Lucas Brasilino <lucas.brasilino@gmail.com>
   Based on Round Robin Input Arbiter from NetFPGA Gateware */
`timescale 1ns/1ps

  module input_arbiter
    #(parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH=DATA_WIDTH/8,
      parameter UDP_REG_SRC_WIDTH = 2,
      parameter STAGE_NUMBER = 2,
      parameter NUM_QUEUES = 8,
      parameter MAX_WEIGHT = 127,
      parameter GCD = 1
      )

   (// --- data path interface
    output reg [DATA_WIDTH-1:0]        out_data,
    output reg [CTRL_WIDTH-1:0]        out_ctrl,
    output reg                         out_wr,
    input                              out_rdy,

    // interface to rx queues
    input  [DATA_WIDTH-1:0]            in_data_0,
    input  [CTRL_WIDTH-1:0]            in_ctrl_0,
    input                              in_wr_0,
    output                             in_rdy_0,

    input  [DATA_WIDTH-1:0]            in_data_1,
    input  [CTRL_WIDTH-1:0]            in_ctrl_1,
    input                              in_wr_1,
    output                             in_rdy_1,

    input  [DATA_WIDTH-1:0]            in_data_2,
    input  [CTRL_WIDTH-1:0]            in_ctrl_2,
    input                              in_wr_2,
    output                             in_rdy_2,

    input  [DATA_WIDTH-1:0]            in_data_3,
    input  [CTRL_WIDTH-1:0]            in_ctrl_3,
    input                              in_wr_3,
    output                             in_rdy_3,

    input  [DATA_WIDTH-1:0]            in_data_4,
    input  [CTRL_WIDTH-1:0]            in_ctrl_4,
    input                              in_wr_4,
    output                             in_rdy_4,

    input  [DATA_WIDTH-1:0]            in_data_5,
    input  [CTRL_WIDTH-1:0]            in_ctrl_5,
    input                              in_wr_5,
    output                             in_rdy_5,

    input  [DATA_WIDTH-1:0]            in_data_6,
    input  [CTRL_WIDTH-1:0]            in_ctrl_6,
    input                              in_wr_6,
    output                             in_rdy_6,

    input  [DATA_WIDTH-1:0]            in_data_7,
    input  [CTRL_WIDTH-1:0]            in_ctrl_7,
    input                              in_wr_7,
    output                             in_rdy_7,

    // --- Register interface
    input                              reg_req_in,
    input                              reg_ack_in,
    input                              reg_rd_wr_L_in,
    input  [`UDP_REG_ADDR_WIDTH-1:0]   reg_addr_in,
    input  [`CPCI_NF2_DATA_WIDTH-1:0]  reg_data_in,
    input  [UDP_REG_SRC_WIDTH-1:0]     reg_src_in,

    output                             reg_req_out,
    output                             reg_ack_out,
    output                             reg_rd_wr_L_out,
    output  [`UDP_REG_ADDR_WIDTH-1:0]  reg_addr_out,
    output  [`CPCI_NF2_DATA_WIDTH-1:0] reg_data_out,
    output  [UDP_REG_SRC_WIDTH-1:0]    reg_src_out,

    // --- Misc

    input                              reset,
    input                              clk
   );


   function integer log2;
      input integer number;
      begin
         log2=0;
         while(2**log2<number) begin
            log2=log2+1;
         end
      end
   endfunction // log2

   // ------------ Internal Params --------
   parameter NUM_QUEUES_WIDTH = log2(NUM_QUEUES);
   parameter MAX_WEIGHT_WIDTH = log2(MAX_WEIGHT);

   parameter NUM_STATES = 3;
   parameter SELECT_QUEUE_0 = 0;
   parameter SELECT_QUEUE_1 = 1;
   parameter SELECT_QUEUE_2 = 2;
   parameter SELECT_QUEUE_3 = 3;
   parameter Q_EMPT_TEST = 4;
   parameter WR_PKT = 5;

   // ------------- Regs/ wires -----------
   wire [NUM_QUEUES-1:0]               nearly_full;
   wire [NUM_QUEUES-1:0]               empty;
   wire [DATA_WIDTH-1:0]               in_data      [NUM_QUEUES-1:0];
   wire [CTRL_WIDTH-1:0]               in_ctrl      [NUM_QUEUES-1:0];
   wire [NUM_QUEUES-1:0]               in_wr;
   wire [CTRL_WIDTH-1:0]               fifo_out_ctrl[NUM_QUEUES-1:0];
   wire [DATA_WIDTH-1:0]               fifo_out_data[NUM_QUEUES-1:0];
   reg [NUM_QUEUES-1:0]                rd_en;

   wire [NUM_QUEUES_WIDTH:0]           cur_queue_plus1;
   reg [NUM_QUEUES_WIDTH:0]            cur_queue;
   reg [NUM_QUEUES_WIDTH:0]            cur_queue_next;

   reg [NUM_STATES-1:0]                state;
   reg [NUM_STATES-1:0]                state_next;

   reg [CTRL_WIDTH-1:0]                fifo_out_ctrl_prev;
   reg [CTRL_WIDTH-1:0]                fifo_out_ctrl_prev_next;

   wire [CTRL_WIDTH-1:0]               fifo_out_ctrl_sel;
   wire [DATA_WIDTH-1:0]               fifo_out_data_sel;

   reg [DATA_WIDTH-1:0]                out_data_next;
   reg [CTRL_WIDTH-1:0]                out_ctrl_next;
   reg                                 out_wr_next;

   reg                                 eop;

   wire [`CPCI_NF2_DATA_WIDTH-1:0]     mac1_queue_weight;

   reg [MAX_WEIGHT_WIDTH:0]            cur_weight; 
   reg [MAX_WEIGHT_WIDTH:0]            cur_weight_next; 
   wire [MAX_WEIGHT_WIDTH:0]           queue_weight[NUM_QUEUES-1:0];
   wire [MAX_WEIGHT_WIDTH:0]           queue_weight_sel;

   // ------------ Modules -------------

   generate
   genvar i;
   for(i=0; i<NUM_QUEUES; i=i+1) begin: in_arb_queues
      small_fifo
        #( .WIDTH(DATA_WIDTH+CTRL_WIDTH),
           .MAX_DEPTH_BITS(2))
      in_arb_fifo
        (// Outputs
         .dout                           ({fifo_out_ctrl[i], fifo_out_data[i]}),
         .full                           (),
         .nearly_full                    (nearly_full[i]),
	 .prog_full                      (),
         .empty                          (empty[i]),
         // Inputs
         .din                            ({in_ctrl[i], in_data[i]}),
         .wr_en                          (in_wr[i]),
         .rd_en                          (rd_en[i]),
         .reset                          (reset),
         .clk                            (clk));
   end // block: in_arb_queues
   endgenerate

   in_arb_regs
   #(
      .DATA_WIDTH(DATA_WIDTH),
      .UDP_REG_SRC_WIDTH (UDP_REG_SRC_WIDTH)
   ) in_arb_regs (
      .reg_req_in       (reg_req_in),
      .reg_ack_in       (reg_ack_in),
      .reg_rd_wr_L_in   (reg_rd_wr_L_in),
      .reg_addr_in      (reg_addr_in),
      .reg_data_in      (reg_data_in),
      .reg_src_in       (reg_src_in),

      .reg_req_out      (reg_req_out),
      .reg_ack_out      (reg_ack_out),
      .reg_rd_wr_L_out  (reg_rd_wr_L_out),
      .reg_addr_out     (reg_addr_out),
      .reg_data_out     (reg_data_out),
      .reg_src_out      (reg_src_out),

      .state            (state),
      .out_wr           (out_wr),
      .out_ctrl         (out_ctrl),
      .out_data         (out_data),
      .out_rdy          (out_rdy),
      .eop              (eop),
      .clk              (clk),
      .reset            (reset)
   );
/*
   generic_regs
   #(
      .UDP_REG_SRC_WIDTH   (UDP_REG_SRC_WIDTH),
      .TAG                 (`IN_ARB_BLOCK_ADDR),
      .REG_ADDR_WIDTH      (`IN_ARB_REG_ADDR_WIDTH),                       // Width of block addresses
      .NUM_COUNTERS        (0),                       // How many counters
      .NUM_SOFTWARE_REGS   (1),                       // How many sw regs
      .NUM_HARDWARE_REGS   (0)                        // How many hw regs
   ) mac1_queue_weight_regs (
      .reg_req_in       (reg_req_in),
      .reg_ack_in       (reg_ack_in),
      .reg_rd_wr_L_in   (reg_rd_wr_L_in),
      .reg_addr_in      (reg_addr_in),
      .reg_data_in      (reg_data_in),
      .reg_src_in       (reg_src_in),
   
      .reg_req_out      (reg_req_out),
      .reg_ack_out      (reg_ack_out),
      .reg_rd_wr_L_out  (reg_rd_wr_L_out),
      .reg_addr_out     (reg_addr_out),
      .reg_data_out     (reg_data_out),
      .reg_src_out      (reg_src_out),

      // --- counters interface
      .counter_updates  (),
      .counter_decrement(),

      // --- SW regs interface 
      .software_regs    (mac1_queue_weight),

      // --- HW regs interface
      .hardware_regs    (),

      .clk              (clk),
      .reset            (reset)
    );
*/
   // ------------- Logic ------------

   assign in_data[0]         = in_data_0;
   assign in_ctrl[0]         = in_ctrl_0;
   assign in_wr[0]           = in_wr_0;
   assign in_rdy_0           = !nearly_full[0];

   assign in_data[1]         = in_data_1;
   assign in_ctrl[1]         = in_ctrl_1;
   assign in_wr[1]           = in_wr_1;
   assign in_rdy_1           = !nearly_full[1];

   assign in_data[2]         = in_data_2;
   assign in_ctrl[2]         = in_ctrl_2;
   assign in_wr[2]           = in_wr_2;
   assign in_rdy_2           = !nearly_full[2];

   assign in_data[3]         = in_data_3;
   assign in_ctrl[3]         = in_ctrl_3;
   assign in_wr[3]           = in_wr_3;
   assign in_rdy_3           = !nearly_full[3];

   assign in_data[4]         = in_data_4;
   assign in_ctrl[4]         = in_ctrl_4;
   assign in_wr[4]           = in_wr_4;
   assign in_rdy_4           = !nearly_full[4];

   assign in_data[5]         = in_data_5;
   assign in_ctrl[5]         = in_ctrl_5;
   assign in_wr[5]           = in_wr_5;
   assign in_rdy_5           = !nearly_full[5];

   assign in_data[6]         = in_data_6;
   assign in_ctrl[6]         = in_ctrl_6;
   assign in_wr[6]           = in_wr_6;
   assign in_rdy_6           = !nearly_full[6];

   assign in_data[7]         = in_data_7;
   assign in_ctrl[7]         = in_ctrl_7;
   assign in_wr[7]           = in_wr_7;
   assign in_rdy_7           = !nearly_full[7];

   assign cur_queue_plus1    = (cur_queue == NUM_QUEUES-1) ? 0 : cur_queue + 1;

   assign fifo_out_ctrl_sel  = fifo_out_ctrl[cur_queue];
   assign fifo_out_data_sel  = fifo_out_data[cur_queue];

   assign queue_weight[3'b000] = 1;
   assign queue_weight[3'b001] = 1;
   assign queue_weight[3'b010] = MAX_WEIGHT;
   assign queue_weight[3'b011] = 1;
   assign queue_weight[3'b100] = 1;
   assign queue_weight[3'b101] = 1;
   assign queue_weight[3'b110] = 1;
   assign queue_weight[3'b111] = 1;
   assign queue_weight_sel = queue_weight[cur_queue];

   always @(*) begin
      state_next     = state;
      cur_queue_next = cur_queue;
      cur_weight_next = cur_weight;
      fifo_out_ctrl_prev_next = fifo_out_ctrl_prev;
      out_wr_next    = 0;
      out_ctrl_next  = fifo_out_ctrl_sel;
      out_data_next  = fifo_out_data_sel;
      rd_en          = 0;
      eop            = 0;

      case(state)

        SELECT_QUEUE_0: begin
            cur_queue_next = {cur_queue_plus1[2:0]};
            state_next = SELECT_QUEUE_1;
        end
        SELECT_QUEUE_1: begin
            if (cur_queue == 0) begin
               cur_weight_next = cur_weight - GCD;
               state_next = SELECT_QUEUE_2;
            end
            else
               state_next = SELECT_QUEUE_3;
         end
         SELECT_QUEUE_2: begin
               if ((cur_weight[3] == 1'b1) || (cur_weight == 0)) begin
                  cur_weight_next = MAX_WEIGHT;
               end
               state_next = SELECT_QUEUE_3;
         end
         SELECT_QUEUE_3: begin
            if (queue_weight_sel >= cur_weight) begin
               cur_queue_next = cur_queue;
               state_next = Q_EMPT_TEST;
            end
         else begin
               state_next = SELECT_QUEUE_0;
         end
        end
        Q_EMPT_TEST: begin
           if(!empty[cur_queue] && out_rdy) begin
              state_next = WR_PKT;
              rd_en[cur_queue] = 1;
              fifo_out_ctrl_prev_next = STAGE_NUMBER;
           end
           if(empty[cur_queue] && out_rdy) begin
              //cur_queue_next = cur_queue_plus1;
              state_next = SELECT_QUEUE_0;
           end
        end

        /* wait until eop */
        WR_PKT: begin
           /* if this is the last word then write it and get out */
           if(out_rdy & |fifo_out_ctrl_sel & (fifo_out_ctrl_prev==0) ) begin
              out_wr_next = 1;
              state_next = SELECT_QUEUE_0;
              //cur_queue_next = cur_queue_plus1;
              //cur_queue_next = cur_queue;
              eop = 1;
           end
           /* otherwise read and write as usual */
           else if (out_rdy & !empty[cur_queue]) begin
              fifo_out_ctrl_prev_next = fifo_out_ctrl_sel;
              out_wr_next = 1;
              rd_en[cur_queue] = 1;
           end
        end // case: WR_PKT

      endcase // case(state)
   end // always @ (*)

   always @(posedge clk) begin
      if(reset) begin
         state <= SELECT_QUEUE_0;
         //cur_queue <= 0;
         cur_queue <= 3'b1111;
         cur_weight <= 0;
         fifo_out_ctrl_prev <= 1;
         out_wr <= 0;
         out_ctrl <= 1;
         out_data <= 0;
      end
      else begin
         state <= state_next;
         cur_queue <= cur_queue_next;
         cur_weight <= cur_weight_next;
         fifo_out_ctrl_prev <= fifo_out_ctrl_prev_next;
         out_wr <= out_wr_next;
         out_ctrl <= out_ctrl_next;
         out_data <= out_data_next;
      end
   end

endmodule // input_arbiter
