-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Memória de Programas ou Memória de Instruções de tamanho genérico
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_TEXTIO.ALL;


library STD;
use STD.TEXTIO.ALL;

entity memi is
	generic (
		INSTR_WIDTH   : natural; -- tamanho da instrucaoo em numero de bits
		MI_ADDR_WIDTH : natural  -- tamanho do endereco da memoria de instrucoes em numero de bits
	);
	port (
		set		 : in std_logic;
		clk       : in std_logic;
		--reset     : in std_logic; --retirei o reset
		Endereco  : in std_logic_vector(MI_ADDR_WIDTH - 1 downto 0);
		Instrucao : out std_logic_vector(INSTR_WIDTH - 1 downto 0)
	);
end entity;

architecture comportamental of memi is
	type rom_type is array (0 to 2 ** MI_ADDR_WIDTH - 1) of std_logic_vector(INSTR_WIDTH - 1 downto 0);
	signal rom : rom_type;

	 file program : text open read_mode is "program.txt"; -- cria arquivo
	 
begin
	
	carregar: process(set) is --carrega as instruções na memoria

		variable counter : integer := 0;
		variable current_read_line : line;
		variable current_read_instruction : std_logic_vector(15 downto 0);	
		
		begin
		
		while(not endfile(program)) loop
			 readline(program, current_read_line);
			 read(current_read_line, current_read_instruction);
			 rom(counter) <= current_read_instruction;
			 counter := counter + 1;
		end loop;

	end process carregar;
	
	leitura: process (Endereco) is
	begin
		if (rising_edge(clk)) then
				Instrucao <= rom(to_integer(unsigned(Endereco)));
		end if;
	end process;
	
	
end comportamental;