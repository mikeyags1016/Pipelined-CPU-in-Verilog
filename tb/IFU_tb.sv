`timescale 1ns/1ps

module IFU_tb;
    logic        clk = 1'b0;
    logic        rst = 1'b1;
    logic [31:0] pkt = 32'b0;
    logic        pkt_valid = 1'b0;
    logic        stall = 1'b0;
    logic        cpu_stall = 1'b0;
    logic        flush = 1'b0;
    logic [31:0] branch_pc = 32'b0;

    logic [31:0] pc_next;
    logic        pc_valid;
    logic        mem_stall;
    logic        mem_flush;
    logic        branch_taken;
    logic        bubble;
    logic [31:0] instruction_pkt;
    logic [31:0] instruction_pc;
    logic        instruction_valid;

    IFU #(
        .XLEN(32),
        .RESET_PC(32'h0000_1000)
    ) dut (
        .clk,
        .rst,
        .pc_next,
        .pc_valid,
        .pkt,
        .pkt_valid,
        .mem_stall,
        .mem_flush,
        .branch_taken,
        .bubble,
        .stall,
        .cpu_stall,
        .flush,
        .branch_pc,
        .instruction_pkt,
        .instruction_pc,
        .instruction_valid
    );

    always #5 clk = ~clk;

    task automatic check_stage(input logic [31:0] expected_pkt);
        begin
            if (!instruction_valid) begin
                $fatal(1, "Expected a valid instruction");
            end
            if (instruction_pkt !== expected_pkt) begin
                $fatal(1, "Expected instruction %h, got %h", expected_pkt, instruction_pkt);
            end
        end
    endtask

    initial begin
        $dumpfile("IFU_tb.vcd");
        $dumpvars(0, IFU_tb);

        repeat (2) @(posedge clk);
        #1;
        if (instruction_valid) begin
            $fatal(1, "Instruction should be invalid after reset");
        end

        rst = 1'b0;
        pkt = 32'h0000_0013; // addi x0, x0, 0
        pkt_valid = 1'b1;
        @(posedge clk);
        #1;
        if (instruction_valid) begin
            $fatal(1, "First buffer should not reach decode immediately");
        end

        pkt = 32'h0010_0093; // addi x1, x0, 1
        @(posedge clk);
        #1;
        check_stage(32'h0000_0013);

        stall = 1'b1;
        pkt = 32'h0020_0113; // addi x2, x0, 2
        @(posedge clk);
        #1;
        check_stage(32'h0000_0013);

        stall = 1'b0;
        pkt_valid = 1'b0;
        @(posedge clk);
        #1;
        check_stage(32'h0010_0093);

        flush = 1'b1;
        @(posedge clk);
        #1;
        if (instruction_valid) begin
            $fatal(1, "Flush should invalidate both buffers");
        end

        $display("IFU test passed");
        $finish;
    end
endmodule
