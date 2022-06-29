library ieee;
use ieee.std_logic_1164.all;

entity barrel_shift_x2 is
	generic (
		largura_dado : natural := 16
	);

	port (
		entrada   : in std_logic_vector(0 to (largura_dado - 1));
		saida     : out std_logic_vector(0 to (largura_dado - 1))
	);
end barrel_shift_x2;

architecture dataflow of barrel_shift_x2 is
begin
	saida <= entrada(1 to 15) & '0';
end dataflow;