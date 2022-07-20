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
		EPC_EN		: out std_logic;
		MEPC		: out std_logic_vector(0 to 1);
		ISR_addr	: out std_logic_vector(0 to 15);
		cause		: out std_logic_vector(0 to 15)
	);
end entity;

architecture rtl of interrupt_controller is
	--===========
	--COMPONENTES
	--===========
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

    component Interrupt_Instruction_Decode
	port (
        instruction : in std_logic_vector(0 to 15);
        interrupt_ack : out std_logic;
        clear_pending : out std_logic;
        dis_alert     : out std_logic;
        en_alert      : out std_logic

    );
	end component;

	component interrupt_FSM
	port (
		-- genericos
		Clock       : in std_logic;
		Reset       : in std_logic;
		-- entradas
		Interrupt   : in std_logic; --avisa que houve alguma interrupção
		en_alert    : in std_logic; -- avisa que é pra voltar a receber interrupções
		dis_alert   : in std_logic; -- avisa que não deve mais receber interrupções
		-- saidas
		EPC_EN      : out std_logic; -- habilita o registrador EPC para o endereço de retorno
		MEPC        : out std_logic_vector(0 to 1) -- MUX que controla qual será a próxima instrução
    );
	end component;

	component Interrupt_Decode_to_Addr
		port (
			current : in std_logic_vector(0 to 15);
			ISR_addr: out std_logic_vector(0 to 15)
		);
	end component;
  
  
  --=======
  --SINAIS
  --=======
-- Create an 16-bit interrupt controller
  signal int_mask, int_request, pending_int, current_int :
         std_logic_vector(0 to 15);
  signal interrupt, interrupt_ack, clear_pending : std_logic;
  signal dis_alert, en_alert : std_logic;
  signal exep_handling : std_logic;
  signal sig_ISR_addr: std_logic_vector(0 to 15);


begin
  --============
  -- ATRIBUIÇÕES
  -- ===========	
  -- Disable interrupts except 0
  int_mask 	<= (1 to 15 => '0', others => '1');
  ISR_addr 	<= sig_ISR_addr;
  cause 	<= sig_ISR_addr;
  
  --=============
  --INSTANCIAÇÕES
  --=============
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

	Inst_Decode: Interrupt_Instruction_Decode
		port map (
			instruction 	=> instruction, 
			interrupt_ack 	=> interrupt_ack,
			clear_pending 	=> clear_pending,
			dis_alert 		=> dis_alert,     
			en_alert 		=> en_alert     
		);

	FSM: interrupt_FSM
		port map(	
			-- genericos
			Clock 		=> Clock,      
			Reset 		=> Reset,      
			-- entradas
			Interrupt 	=> Interrupt,  
			en_alert 	=> en_alert,   
			dis_alert 	=> dis_alert,  
			-- saidas
			EPC_EN 		=> EPC_EN,     
			MEPC   		=> MEPC     
		);

	Decode_Addr: Interrupt_Decode_to_Addr
		port map(
			current 	=> current_int,
			ISR_addr 	=> sig_ISR_addr
		);

  
-- process(en_alert, dis_alert)
-- begin
-- 	-- The reset signal overrrides the enable signal; reset the value to 0
-- 	if (en_alert = '0') then
-- 		exep_handling <= '0';
-- 	-- Otherwise, change the variable only when updates are enabled
-- 	elsif (dis_alert = '1') then
-- 		exep_handling <= '1';
-- 	end if;
-- end process;

end architecture;