module IFU #(
	parameter int XLEN = 32,
	parameter logic [XLEN-1:0] RESET_PC = '0
) (
	input  logic             clk,
	input  logic             rst,

	// Instruction access interface.
	output logic [XLEN-1:0]  pc_next,
	output logic             pc_valid,
	input  logic [31:0]      pkt,
	input  logic             pkt_valid,

	// Pipeline control.
    output logic             mem_stall,
    output logic             mem_flush,
    output logic             branch_taken,
	output logic             bubble,
    input  logic             stall,
    input  logic             cpu_stall,
    input  logic             flush,
    input  logic             branch_pc,

	// Decode unit stage.
	output logic [XLEN-1:0]  instruction_pkt,
	output logic [XLEN-1:0]  instruction_pc,
	output logic             instruction_valid
);

	logic [XLEN-1:0] pc;
    logic [XLEN-1:0] buf_1;
    logic [XLEN-1:0] buf_2;
	logic            buf_1_valid;
	logic            buf_2_valid;

	if (!flush) begin
		if (!branch_taken) begin
			if (!cpu_stall) begin
				assign pc_next = pc + 4;
			end else begin
				assign pc_next = pc;
			end
		end else begin
			assign pc_next = branch_pc;
		end
	end else begin
		assign pc_next = branch_pc;
	end

	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			buf_1       <= '0;
			buf_2       <= '0;
			buf_1_valid <= 1'b0;
			buf_2_valid <= 1'b0;
		end else if (flush || branch_taken) begin
			buf_1_valid <= 1'b0;
			buf_2_valid <= 1'b0;
		end else if (!stall && !cpu_stall) begin
			buf_1       <= pkt;
			buf_2       <= buf_1;
			buf_1_valid <= pkt_valid;
			buf_2_valid <= buf_1_valid;
		end
	end

	if (pkt[6:0] == 7'b1100111) begin
		assign branch_taken = 1'b1;
	end else begin
		if (pkt[6:0] == 7'b1100011) begin
			if (pkt[31:20] < pc) begin
				assign branch_taken = 1'b1;
			end else begin
				assign branch_taken = 1'b0;
			end
			assign branch_taken = 1'b1;
		end else begin
			assign branch_taken = 1'b0;
		end
	end

	if (branch_flush) begin
		assign bubble = 1'b1;
	end else begin
		if (branch_taken && !stall) begin
			assign bubble = 1'b1;
		end else begin
			if (stall) begin
				// hold current data for buf 1 and 2, do not bubble
			end else begin
				if (pkt_valid) begin
					assign buf1 = pkt;
				end else begin
					assign bubble = 1'b1;
				end

				assign buf_2 = buf_1;
			end
			assign bubble = 1'b0;
		end

		assign bubble = 1'b0;
	end
	if (bubble) begin
		assign buf_1_valid = 1'b0;
		assign buf_2_valid = 1'b0;
	end

	assign instruction_pkt = buf_1;
	assign instruction_pc = buf_2;
	assign instruction_valid = pkt_valid;

	assign mem_stall = stall | cpu_stall;
	assign mem_flush = flush | branch_taken;

endmodule
