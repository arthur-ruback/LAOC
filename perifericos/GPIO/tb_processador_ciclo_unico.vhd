-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Testbench para o processador_ciclo_unico
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Este arquivo irá gerar um sinal de clock e reset de modo a possibilitar a simulação do DUT processador_ciclo_unico

entity tb_processador_ciclo_unico is
end tb_processador_ciclo_unico;

architecture estimulos of tb_processador_ciclo_unico is
	
	-- Declarar a unidade sob teste
	component processador_ciclo_unico
		generic (
			DATA_WIDTH : natural := 16; -- tamanho do barramento de dados em bits
			PROC_INSTR_WIDTH : natural := 16; -- tamanho da instrução do processador em bits
			PROC_ADDR_WIDTH : natural := 16; -- tamanho do endereço da memória de programa do processador em bits
			DP_CTRL_BUS_WIDTH : natural := 19 -- tamanho do barramento de controle em bits
		  );
		port (
			Chave_reset : in std_logic; 
			Clock_in   : in std_logic;
			Leds_vermelhos_saida : out std_logic_vector(0 to DATA_WIDTH - 1);
			PORT_A      : inout std_logic_vector(0 to 7)
		);
	end component;

	signal clk : std_logic;
	signal rst : std_logic;
	signal PORT_A : std_logic_vector(0 to 7);
	signal Leds_vermelhos_saida : std_logic_vector(0 to 15);
	

	-- Definição das configurações de clock				
	constant PERIODO    : time := 20 ns;
	constant DUTY_CYCLE : real := 0.5;
	constant OFFSET     : time := 5 ns;
begin
	-- instancia o componente 
	instancia : processador_ciclo_unico port map(Clock_in => clk, Chave_reset => rst, PORT_A => PORT_A, Leds_vermelhos_saida => Leds_vermelhos_saida);
	
	rst <= '1', '0' after 100 ns;		
	
	
	-- processo para gerar o sinal de clock 		
	gera_clock : process
	begin
		wait for OFFSET;
		CLOCK_LOOP : loop
			clk <= '0';
			wait for (PERIODO - (PERIODO * DUTY_CYCLE));
			clk <= '1';
			wait for (PERIODO * DUTY_CYCLE);
		end loop CLOCK_LOOP;
	end process gera_clock;
	
	PORT_A <= X"00", x"01" after 1000ns;

	
end;