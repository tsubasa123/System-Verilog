//The scoreboard class which will generate coverage for read transaction
class ram_sb;

    mailbox #(ram_trans) rm2sb;
    mailbox #(ram_trans) rdmon2sb;

    ram_trans cov_data; // Coverage for Read operation.
    ram_trans rm_data;
    ram_trans rcvd_data;

    // Done event signals the end of verification to generate coverage.
    event DONE;
    // Counters to identify the event if it is done or not.
    //They are various counters which keep track of the transactions.
    int data_verified = 0;
    int rm_data_count = 0;
    int mon_data_count = 0;

    function new(mailbox #(ram_trans) rm2sb,
                 mailbox #(ram_trans) rdmon2sb);
        this.rm2sb = rm2sb;
        this.rdmon2sb = rdmon2sb;
        //this.rmdata = new;
        mem_coverage = new();
    endfunction:new

    //Start method for scoreboard...
    virtual task start();
        fork
            forever 
                begin
                    rm2sb.get(rm_data);
                    rm_data_count++;

                    rdmon2sb.get(rcvd_data);
                    mon_data_count++;
                    check(rcvd_data);
                end
        join_none
    endtask:start

    //Generate coverage for read transaction
    covergroup mem_coverage;
        RD_ADD: coverpoint cov_data.rd_address
            {
                bins ZERO           = {0};
                bins LOW1           = {[1:585]};
                bins LOW2           = {[586:1170]};
                bins MID_LOW        = {[1171:1755]};
                bins MID            = {[1756:2340]};
                bins MID_HIGH       = {[2341:2925]};
                bins HIGH1          = {[2926:3510]};
                bins HIGH2          = {[3511:4094]};
                bins MAX            = {[4095]};
            }   
        DATA: coverpoint cov_data.data_out
            {
                bins ZERO           = {0};
                bins LOW1           = {[1:500]};
                bins LOW2           = {[501:1000]};
                bins MID_LOW        = {[1001:1500]};
                bins MID            = {[1501:2000]};
                bins MID_HIGH       = {[2001:2500]};
                bins HIGH1          = {[2501:3000]};
                bins HIGH2          = {[3001:4293]};
                bins MAX            = {[4294]};
            }
        RD: coverpoint cov_data.read
            {
                bins read = {1};
            }
        READxADDxDATA: cross RD,RD_ADD,DATA;
    endgroup:mem_coverage

    //Check Method to compare the data.. Call the compare method defined in the interface class
    virtual task check(input rc_data);
        string diff;
        if (rc_data.read == 1)
        begin
            if (rc_data.data_out == 0) //Since we initialize the entire memory with zero in the DUV so default value is zero
                $$display("SB:RANDOM DATA NOT WRITTEN");
            if (rc_data.data_out != 0)
                begin
                    if (!rm_data.compare(rc_data,diff))
                        begin:failed_compare
                            rc_data.display("SB: RECIEVED DATA");
                            rm_data.display("DATA SENT TO DUT");
                            $display("%s\n%m\n\n",diff);
                            $finsh;
                        end:failed_compare
                    else
                        $display("SB: %s\n%m\n\n",diff);
                end
            data_verified++;
            cov_data = rm_data;
            mem_coverage.sample();

        if(data_verified >= (number_of_transactions - rc_data.no_of_write_trans))
            begin
                ->DONE;
            end
        end
    endtask:check

    // Generate Scoreboard Report
    virtual function void report ();
        $display("--------------------SCOREBOARD REPORT------------------------");
        $display("%0d Read Data Generated, %0d Recieved Data Recieved, %0d Read Data Verified\n",rm_data_count, mon_data_count, data_verified);
        $display("---------------------------------------------------------------");
    endfunction:report

endclass:ram_sb

    