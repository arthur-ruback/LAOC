library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_interrupt_ctl is
end entity tb_interrupt_ctl;

architecture rtl of tb_interrupt_ctl is
    component interrupt_ctl is
        generic (
          RESET_ACTIVE_LEVEL : std_logic := '1' --# Asynch. reset control level
        );
        port (
          --# {{clocks|}}
          Clock : in std_logic; --# System clock
          Reset : in std_logic; --# Asynchronous reset
    
          --# {{control|}}
          Int_mask    : in std_logic_vector(0 to 15);  --# Set bits correspond to active interrupts
          Int_request : in std_logic_vector(0 to 15);  --# Controls used to activate new interrupts
          Pending     : out std_logic_vector(0 to 15); --# Set bits indicate which interrupts are pending
          Current     : out std_logic_vector(0 to 15); --# Single set bit for the active interrupt
    
          Interrupt     : out std_logic; --# Flag indicating when an interrupt is pending
          Acknowledge   : in std_logic;  --# Clear the active interupt
          Clear_pending : in std_logic   --# Clear all pending interrupts
        );
    end component;

    signal tb_Clock, tb_Reset : std_logic := '1';
    signal tb_Int_mask, tb_Int_request, tb_Pending, tb_Current : std_logic_vector(0 to 15);
    signal tb_Interrupt, tb_Acknowledge, tb_Clear_pending : std_logic;

begin
    my_interrupt_ctl: interrupt_ctl
        port map(
            Clock           => tb_Clock,  
            Reset           => tb_Reset,

            Int_mask        => tb_Int_mask,
            Int_request     => tb_Int_request,
            Pending         => tb_Pending,
            Current         => tb_Current,

            Interrupt       => tb_Interrupt,
            Acknowledge     => tb_Acknowledge,
            Clear_pending   => tb_Clear_pending
        );

    tb_Reset <= '1', '0' after 50 ns;
    tb_Clock <= not tb_Clock after 10 ns;

    tb_int_mask <= "1100000000000000"; -- somente os dois primeiros responderão

    tb_Int_request <= "1100000000000000", (others => '0') after 100 ns;

    tb_Acknowledge <= '0';

    tb_Clear_pending <= '0', '1' after 290 ns;
    
    
end architecture rtl;