library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_interrupt_controller is
end entity tb_interrupt_controller;

architecture teste of tb_interrupt_controller is
    
    component interrupt_controller
        port(
            Clock : in std_logic;
              Reset : in std_logic;
            
            --input
            instruction 	: in std_logic_vector(0 to 15);
            Int_request_bus : in std_logic_vector(0 to 15);  --# Controls used to activate new interrupts
                                                            -- only one interrupt, for now
            
            --output
            EPC_EN		: out std_logic;
            MEPC		: out std_logic_vector(0 to 1);
            ISR_addr	: out std_logic_vector(0 to 15);
            cause		: out std_logic_vector(0 to 15)
        );
    end component;

signal tb_Clock, tb_Reset                   : std_logic := '1';  
signal tb_instruction, tb_Int_request_bus   : std_logic_vector(0 to 15);                                             
signal tb_EPC_EN                            : std_logic;
signal tb_MEPC	                            : std_logic_vector(0 to 1);
signal tb_ISR_addr, tb_cause                : std_logic_vector(0 to 15);

begin
    my_interrupt_controller : interrupt_controller
    port map(
        Clock           => tb_Clock,
        Reset           => tb_Reset,
        instruction 	=> tb_instruction,
        Int_request_bus => tb_Int_request_bus,
        EPC_EN		    => tb_EPC_EN,
        MEPC		    => tb_MEPC,
        ISR_addr	    => tb_ISR_addr,
        cause		    => tb_cause
    );

    tb_Clock <= not tb_Clock after 10 ns;
    tb_Reset <= '1', '0' after 50 ns;
    
    tb_instruction <= x"0000", x"0004" after 160 ns, x"0001" after 240 ns, x"0004" after 300 ns; -- nada, en_alert  ='1', clear current, en_alert = '1'
    tb_Int_request_bus <= "1000000000000000", (others => '0') after 100 ns;

    
    
end architecture teste;