library ieee;
use ieee.std_logic_1164.all;

entity interrupt_controller is
	port(
		Clock : in std_logic;
      	Reset : in std_logic;
		
		--input
		instruction 	: in std_logic_vector(0 to 15);
		Int_request_bus : in std_logic_vector(0 to 15);  --# Controls used to activate new interrupts
														-- only one interrupt, for now
		
		--output
		EPC_en		: out std_logic;
		mx_epc		: out std_logic_vector(0 to 1);
		ISR_addr	: out std_logic_vector(0 to 15);
		cause		: out std_logic_vector(0 to 15)
	);
end entity;

architecture rtl of interrupt_controller is
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

-- Create an 16-bit interrupt controller
  signal int_mask, int_request, pending_int, current_int :
         std_logic_vector(0 to 15);
  signal interrupt, interrupt_ack, clear_pending : std_logic;
  signal dis_alert, en_alert : std_logic;
  signal exep_handling : std_logic;
begin

  -- Disable interrupts except 0
  int_mask <= (1 to 15 => '0', others => '1');
  
  ic: interrupt_ctl
    port map (
      Clock => Clock,
      Reset => Reset,

      Int_mask    => int_mask,      -- Mask to enable/disable interrupts
      Int_request => Int_request_bus,   -- Interrupt sources
      Pending     => pending_int,   -- Current set of pending interrupts
      Current     => current_int,   -- Vector identifying which interrupt is active

      Interrupt     => interrupt,     -- Signal when an interrupt is pending
      Acknowledge   => interrupt_ack, -- Acknowledge the interrupt has been serviced
      Clear_pending => clear_pending  -- Optional control to clear all
    );

  instructions: process (instruction) is
  begin
		-- Assumes all outputs false and if a case occurs, the last
		-- value atributed to a signal in a process is really atributed
		interrupt_ack <= '0';
		clear_pending <= '0';
		dis_alert     <= '0';
		en_alert      <= '0';
		case(instruction) is
		--clear current interrupt
			when "0000000000000001" =>
				interrupt_ack <= '1';
		--clear all interrupts
			when "0000000000000010" =>
				clear_pending <= '1';
		--disable interrupt alert
			when "0000000000000011" =>
				dis_alert <= '1';
		--enable interrupt alert (and if there are no other interrupts, return to the flow of the program)
			when "0000000000000100" =>
				en_alert <= '1';
		--Other instructions
			when others =>
				interrupt_ack <= '0';
				clear_pending <= '0';
				dis_alert     <= '0';
				en_alert      <= '0';
		end case;
  end process;
  
process(en_alert, dis_alert)
begin
	-- The reset signal overrrides the enable signal; reset the value to 0
	if (en_alert = '0') then
		exep_handling <= '0';
	-- Otherwise, change the variable only when updates are enabled
	elsif (dis_alert = '1') then
		exep_handling <= '1';
	end if;
end process;

end architecture;