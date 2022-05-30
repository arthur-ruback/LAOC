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
		port (
			Chave_reset : in std_logic; 
			Clock_in   : in std_logic
		);
	end component;

	signal clk : std_logic;
	signal rst : std_logic;
	

	-- Definição das configurações de clock				
	constant PERIODO    : time := 20 ns;
	constant DUTY_CYCLE : real := 0.5;
	constant OFFSET     : time := 5 ns;
begin
	-- instancia o componente 
	instancia : processador_ciclo_unico port map(Clock_in => clk, Chave_reset => rst);
	
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
	
	-- processo para iniciar o carregamento de memi e iniciar/finalizar o programa

	
end;