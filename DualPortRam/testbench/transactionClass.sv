class ram_trans;

    rand bit [63:0] data_in;
    rand bit [11:0] rd_address;
    rand bit [11:0] wrt_address;
    rand bit read;
    rand bit write;

    logic [63:0] data_out; // we shall collect the data from DUT so not randomizng it.

    static int trans_id; // Transaction Id.
    //Some transaction parameters to keep track of the different transactions.
    //Static infers that there should be only one memory for these constants.
    static int no_of_read_trans; 
    static int no_of_write_trans;
    static int no_of_read_write_trans;
    //Constraints
    constraint VALID_ADDR {wrt_address != rd_address;}
    constraint VALID_CTRL {{read,write} != 2'b00;}
    constraint VALID_DATA {data_in inside {[1:4294]};}

    //A Display virtual function to display the different Transaction Parameters.
    virtual function void display(input string message);
        $display("======================================================");
        $display("%s",message);
        $display("\tTransaction No: %d", trans_id);
        $display("\tNo of read Transactions: %d",no_of_read_trans);
        $display("\tNo of write Transactions: %d", no_of_write_trans);
        $display("\tNo of Read/Write Transaction: %d",no_of_read_write_trans);
        $display("\tRead = %d, Write = %d", read, write);
        $display("\tRead Address = %d,
                  Write Address = %d", rd_address, wrt_address);
        $display("\tData_in = %d",data_in);
        $display("\tData_out = %d", data_out); 
        $display("======================================================");
    endfunction: display

    // Modifying the Post-randomize function. Incrementing the counters based on the signal values
    function void post_randomize();
        if (this.read == 1 & this.write == 1)
        begin
            no_of_read_write_trans++;
        end
        if (this.read == 1 && this.write == 0)
        begin 
            no_of_read_trans++;
        end
        if (this.read == 0 && this.write == 1) 
        begin
            no_of_write_trans++;
        end
        this.display("\tRANDOMIZED DATA");
    endfunction:post_randomize

    // The return type of a function and a output of a function is not the same
    // This function shall be used as a part of scoreboard.
    virtual function bit compare (input ram_trans rcv,
                                  output string message);
        compare = '0;
        begin
            if (this.rd_address != rcv.wrt_address)
            begin
                $display($time);
                message = "-----ADDRESS MISMATCH----";
                return (0);
            end
            if (this.dat_out != rcv.data_out)
            begin
                $display($time);
                message = "-----DATA MISMATCH-----";
                return (0);
            end
            begin
                message = " SUCCESSFULLY COMPARED ";
                return (1);
            end
        end
    endfunction:compare

endclass:ram_trans