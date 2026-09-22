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
	input  logic [XLEN-1:0]  branch_pc,

	// Decode interface.
	output logic [XLEN-1:0]  instruction_pkt,
	output logic [XLEN-1:0]  instruction_pc,
	output logic             instruction_valid
);

	logic [XLEN-1:0] pc;
    logic [XLEN-1:0] buf_1;
    logic [XLEN-1:0] buf_2;
	logic [XLEN-1:0] pc_buf_1;
	logic [XLEN-1:0] pc_buf_2;
	logic            buf_1_valid;
	logic            buf_2_valid;
	logic            branch_flush;

	always @(*) begin
		branch_taken = 1'b0;
		if (pkt_valid) begin
			case (pkt[6:0])
				7'b1100011, 7'b1100111, 7'b1101111: branch_taken = 1'b1;
				default: branch_taken = 1'b0;
			endcase
		end

		branch_flush = flush || branch_taken;
		pc_valid = !rst && !cpu_stall && !stall && !branch_flush;
		if (flush) begin
			pc_next = RESET_PC;
		end else if (branch_taken) begin
			pc_next = branch_pc;
		end else if (stall || cpu_stall) begin
			pc_next = pc;
		end else begin
			pc_next = pc + XLEN'(4);
		end

		mem_stall = stall || cpu_stall;
		mem_flush = branch_flush;
		bubble = branch_flush || !pkt_valid;
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			pc          <= RESET_PC;
			buf_1       <= '0;
			buf_2       <= '0;
			pc_buf_1    <= '0;
			pc_buf_2    <= '0;
			buf_1_valid <= 1'b0;
			buf_2_valid <= 1'b0;
		end else if (branch_flush) begin
			pc          <= flush ? RESET_PC : branch_pc;
			buf_1_valid <= 1'b0;
			buf_2_valid <= 1'b0;
		end else if (!stall && !cpu_stall) begin
			pc          <= pc_next;
			buf_1       <= pkt;
			buf_2       <= buf_1;
			pc_buf_1    <= pc;
			pc_buf_2    <= pc_buf_1;
			buf_1_valid <= pkt_valid;
			buf_2_valid <= buf_1_valid;
		end
	end

	assign instruction_pkt = buf_2;
	assign instruction_pc = pc_buf_2;
	assign instruction_valid = buf_2_valid;

endmodule
