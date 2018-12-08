import rv32i_types::*;

module cache_control
(
    input clk,

    /* Signals from CPU */
    input rv32i_mem_wmask mem_byte_enable,
    input mem_read,
    input mem_write,

    /* Signals from P-memory */
    input pmem_resp,

    /* Signals to P-memory */
    output logic pmem_read,
    output logic pmem_write,

    /* Signals to CPU */
    output logic mem_resp,

    /* Signal from Cache Datapath */
    input logic hit_0,
    input logic hit_1,
    input logic valid_out_0,
    input logic dirty_out_0,
    input logic valid_out_1,
    input logic dirty_out_1,

    input logic lru_out,

	 output logic load_regs,
    /* Signal send to Cache Datapath */
    output logic load_data_0,
    output logic load_tag_0,
    output logic load_valid_0,
    output logic load_dirty_0,

    output logic load_data_1,
    output logic load_tag_1,
    output logic load_valid_1,
    output logic load_dirty_1,

    output logic valid_in,
    output logic dirty_in,
    output logic way_sel,
    output logic load_lru,
    output logic lru_in,
    output logic [1:0] pmem_sel,
    output logic data_sel
    );

enum int unsigned {
    /* All the states, needs to be modified for the final CP */
    // idle,    // Not really useful
    read_write,
    write_back,
    access_pmem
} state, next_state;

logic is_hit;

assign is_hit = hit_0 | hit_1;

always_comb
begin : state_actions
    /* Default output assignments */
    pmem_read = 1'b0;
    pmem_write = 1'b0;

    mem_resp = 1'b0;

    load_data_0 = 1'b0;
    load_tag_0 = 1'b0;
    load_valid_0 = 1'b0;
    load_dirty_0 = 1'b0;

    load_data_1 = 1'b0;
    load_tag_1 = 1'b0;
    load_valid_1 = 1'b0;
    load_dirty_1 = 1'b0;

    load_lru = 1'b0;
    way_sel = 1'b0;
    valid_in = 1'b0;
    dirty_in = 1'b0;
    lru_in = 1'b0;

    pmem_sel = 2'b00;
    data_sel = 1'b0;
	 load_regs = 0;
    case(state)
        // idle: // waiting for responses

        read_write: begin
            if (mem_read && is_hit) begin
                //read
                if (hit_0 == 1) begin
                    way_sel = 0;
                    mem_resp = 1;
                    lru_in = 1;
                    load_lru = 1;
                end else begin
                    way_sel = 1;
                    mem_resp = 1;
                    lru_in = 0;
                    load_lru = 1;
                end

            /* If we need to write data */
            end else if (mem_write && is_hit) begin
                if (hit_0 == 1) begin
                    way_sel = 0;
                    mem_resp = 1;
                    lru_in = 1;     // indicate the other cache way is available
                    load_lru = 1;
                    dirty_in = 1;   // set dirty bit
                    load_dirty_0 = 1;
                    data_sel = 1;   // load data
                    load_data_0 = 1;
                end else begin
                    way_sel = 1;
                    mem_resp = 1;
                    lru_in = 0;     // indicate the other cache way is available
                    load_lru = 1;
                    dirty_in = 1;   // set dirty bit
                    load_dirty_1 = 1;
                    data_sel = 1;   // load data
                    load_data_1 = 1;
                end
            end else if(mem_read || mem_write) begin
					load_regs = 1;
					if (lru_out == 0) begin 
					    way_sel = 1'b0;
					    if(dirty_out_0 == 0) pmem_sel = 0;
						 else pmem_sel = 2'b01;
					end else begin
						 way_sel = 1'b1;
					    if(dirty_out_1 == 0) pmem_sel = 0;
						 else pmem_sel = 2'b10;
					end
				end
        end

        access_pmem: begin
            pmem_read = 1;
            valid_in = 1;

            if (lru_out == 0) begin     // Accessing Cache Way 0
                load_data_0 = 1;
                load_tag_0 = 1;
                load_valid_0 = 1;
            end

            else begin     // Accessing Cache Way 1
                load_data_1 = 1;
                load_tag_1 = 1;
                load_valid_1 = 1;
            end
        end

        write_back: begin
				pmem_write = 1;
				dirty_in = 0;
				
            if (lru_out == 0) begin
                load_dirty_0 = 1;
            end else begin
                load_dirty_1 = 1;
            end
				
				if (pmem_resp == 1) begin
						load_regs = 1;
						pmem_sel = 0;
				end
        end

        /* Default state, in case accessing by mistake */
        default: ;
    endcase
end

always_comb
begin : next_state_logic
     next_state = state;

     case (state)
        read_write: begin
            if (mem_read || mem_write) begin
                if (hit_0 == 1 || hit_1 == 1)begin// If there is a hit in Cache Way, looping
                    next_state = read_write;
                end else begin/* If both ways are valid */
                    if (dirty_out_0 == 1 && lru_out == 0) begin// Need use cashway 0 and it is dirty
                        next_state = write_back;
                    end else if (dirty_out_1 == 1 && lru_out == 1) begin// Need to write back way 1
                        next_state = write_back;
                    end else begin
                        next_state = access_pmem;	// Stay conflicted for now
                    end
                end
            end
        end

        access_pmem: begin
            if (pmem_resp == 0) // If the memory is not ready, loop
                next_state = access_pmem;
            else
                next_state = read_write;
        end

        write_back: begin
            if (pmem_resp == 0) // If the memory is not ready, loop
                next_state = write_back;
            else
                next_state = access_pmem;
        end

        default: next_state = read_write;
     endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
    state <= next_state;
end

endmodule : cache_control
