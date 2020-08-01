// It generates packets of data to send to both the drivers...
class ram_gen;

    ram_trans gen_trans; // Transaction Handle to generate random data
    ram_trans data2send; // The randomly generated data shall be put in these pointer to send it via mailbox

    mailbox #(ram_trans) gen2rd;
    mailbox #(ram_trans) gen2wrt;

    function new(mailbox #(ram_trans) gen2rd,
                 mailbox #(ram_trans) gen2wrt);

        this.gen2rd = gen2rd; // The gen2rd with the this pointer is the property
        this.gen2wrt = gen2wrt; // The RHS side of the assignment is the argument.
        this.gen_trans = new;
    endfunction: new

    virtual task start();
        fork
            begin  // The "number_of_transactions is defined in the package class"
                for (int i=0; i<number_of_transactions; i++)
                begin
                    gen_trans.trans_id++;
                    // assert means {if (true) then execute the rest of the statements, if (false ) then return no further execution}
                    assert(gen_trans.randomize()); 
                    data2send = new gen_trans; // Shallow Copy.
                    gen2rd.put(data2send); //The Put method puts the data
                    gen2wrt.put(data2send); // in the mailbox...
                end
            end
        join_none
    endtask: start
endclass:ram_gen