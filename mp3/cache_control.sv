module cache_control
(
    input              clk,

    output logic       cmem_resp,
    input              cmem_read,
    input              cmem_write,
    input              pmem_resp,
    output logic       pmem_read,
    output logic       pmem_write,

    input              hit0,
    input              hit1,
    input              dirty0,
    input              dirty1,
    input              lru_out,

    output logic       load_lru,
    output logic       load_dirty0,
    output logic       load_dirty1,
    output logic       load_data0,
    output logic       load_data1,
    output logic       load_tag0,
    output logic       load_tag1,
    output logic       load_valid0,
    output logic       load_valid1,

    output logic       datain_sel,
    output logic [1:0] addr_sel

);

   enum int unsigned{
      idle, read, flush
   } state, next_state;

   always_ff @(posedge clk)
     begin
        state <= next_state;
     end

   always_comb
     begin
        next_state = state;
        case (state)
          idle:begin
             if(!(hit0 || hit1)) begin
                if ((lru_out && dirty1) || (!lru_out && dirty0))begin
                   next_state = flush;
                end else begin
                   next_state = read;
                end
             end
          end
          read:begin
             if(pmem_resp) begin
                next_state = idle;
             end else begin
                next_state = read;
             end
          end
          flush:begin
             if(pmem_resp) begin
                next_state = read;
             end else begin
                next_state = flush;
             end
          end
        endcase // case (state)
     end


   always_comb
     begin
        load_lru = 0;
        load_dirty0 = 0;
        load_dirty1 = 0;
        load_data0 = 0;
        load_data1 = 0;
        load_tag0 = 0;
        load_tag1 = 0;
        load_valid0 = 0;
        load_valid1 = 0;
        addr_sel = 0;
        datain_sel = 0;
        pmem_read = 0;
        pmem_write = 0;
        cmem_resp = 0;
        case (state)
          idle: begin
             if (cmem_read && (hit0 || hit1)) begin
                // hit
                cmem_resp = 1;
                load_lru = 1;
             end else if (cmem_write && (hit0 || hit1)) begin
                datain_sel = 1;
                load_lru = 1;
                cmem_resp = 1;
                if(hit0) begin
                   load_data0 = 1;
                   load_dirty0 = 1;
                end else begin
                   load_data1 = 1;
                   load_dirty1 = 1;
                end
             end
          end
          read: begin
             pmem_read = 1;
             if(lru_out) begin
                load_dirty1 = 1;
                load_tag1 = 1;
                load_valid1 = 1;
                if(pmem_resp) load_data1 = 1;
             end else begin
                load_dirty0 = 1;
                load_tag0 = 1;
                load_valid0 = 1;
                if(pmem_resp) load_data0 = 1;
               end
          end
          flush: begin
             pmem_write = 1;
             if(lru_out) begin
                addr_sel = 2;
             end else begin
                addr_sel = 1;
             end
          end
        endcase // case (state)
     end



endmodule : cache_control
