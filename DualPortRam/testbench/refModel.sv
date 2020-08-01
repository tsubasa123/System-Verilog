//Reference model for comparison of the values...
class ram_model;
    //mailbox definitions
    mailbox #(ram_trans) wrtmon2rm;
    mailbox #(ram_trans) rdmon2rm;
    mailbox #(ram_trans) rm2sb;

    logic [63:0] ref_data[int]; //Associative array to hold the data. The int type is the address type.

    //transaction data
    ram_trans wrtmondata;
    ram_trans rdmondata;

    //The new function
    function new (mailbox #(ram_trans) wrtmon2rm,
                  mailbox #(ram_trans) rdmon2rm,
                  mailbox #(ram_trans) rm2sb);

        this.rm2sb = rm2sb;
        this.wrtmon2rm = wrtmon2rm;
        this.rdmon2sb = rdmon2sb;
    endfunction:new

    // Task to write the data from the write transaction to ref model data address
    virtual task mem_write(ram_trans wrtmondata);
        ref_data[wrtmondata.wrt_address] = wrtmondata.data_in;
    endtask:mem_write

    //Task to read the data from the ref model based on the read transaction specs
    virtual task mem_read(ram_trans rdmondata);
        if(ref_data.exists[rdmondata.rd_address])
            rdmondata.data_out = ref_data[rdmondata.rd_address];
    endtask:mem_read

    //Creating the write operation..
    virtual task ramWrite(ram_trans wrtmondata);
        begin
            if(wrtmondata.write)
                mem_write(wrtmondata); 
        end
    endtask:ramWrite

    //Creating the read operation
    virtual task ramRead(ram_trans rdmondata);
        begin
            if (rdmondata.read)
                mem_read(rdmondata); 
        end
    endtask:ramRead

    virtual task start();
        fork
            begin
                fork
                    begin
                        forever // Thread to write the data after getting it from the mailbox into the ref model
                            begin
                                wrtmon2rm.get(wrtmondata);
                                ramWrite(wrtmondata);
                            end
                    end

                    begin
                        forever // Thread to read the data the read mailbox and send to scoreboard
                            begin
                                rdmon2sb.get(rdmondata);
                                ramRead(rdmondata);
                                rm2sb.put(rdmondata);
                            end 
                    end
                join
            end
            
        join_none
    endtask:start

endclass:ram_model



