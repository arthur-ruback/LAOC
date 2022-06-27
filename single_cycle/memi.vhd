-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Memória de Programas ou Memória de Instruções de tamanho genérico
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memi is
	generic (
		INSTR_WIDTH   : natural := 16; -- tamanho da instrucaoo em numero de bits
		MI_ADDR_WIDTH : natural := 16 -- tamanho do endereco da memoria de instrucoes em numero de bits
	);
	port (
		clk       : in std_logic;
		reset     : in std_logic; --retirei o reset
		Endereco  : in std_logic_vector(0 to MI_ADDR_WIDTH - 1);
		Instrucao : out std_logic_vector(0 to INSTR_WIDTH - 1)
	);
end entity;

architecture comportamental of memi is
	type memory_t is array (0 to 2 ** MI_ADDR_WIDTH - 1) of std_logic_vector(0 to INSTR_WIDTH - 1);
	
	function init_rom
		return memory_t is 
		variable tmp : memory_t := (others => (others => '0'));
	begin 
		tmp := (					-- exemplo de uma instrução qualquer de 16 bits (4 símbos em hexadecimal)
				--0      => X"4064", -- LI1 100
				--1      => X"4FA3", -- LI2 -93
				--2      => X"0980", -- ADD r3
				0 => X"4008",
				1 => X"5800",
				2 => X"0C80",
				3 => X"4001",
				4 => X"5800",
				5 => X"0D00",
				6 => X"4001",
				7 => X"5800",
				8 => X"0A00",
				9 => X"6480",
				10 => X"1805",
				11 => X"64D0",
				12 => X"7500",
				13 => X"64A0",
				14 => X"9C80",
				15 => X"2FF9",
				16 => X"7800",
				others => X"0000"
				);
		return tmp;
	end init_rom;
	
	signal rom : memory_t := init_rom;
begin
	process (Endereco) is
	begin
		Instrucao <= rom(to_integer(unsigned(Endereco)));
	end process;
end comportamental;

