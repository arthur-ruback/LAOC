library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Decod_GPIO is
	port(Instrucao 			: in std_logic_vector(0 to 2); -- sao apenas 6 instrucoes
		  -- sinais de habilitacao dos registradores
		Rd_EN				: out std_logic;
		Wr_EN				: out std_logic;
		Interrupt_Conf_EN	: out std_logic;
		Direction_Conf_EN	: out std_logic
	);
end Decod_GPIO;

architecture combinacional of Decod_GPIO is

begin

Decod: process (Instrucao)
	begin
		case Instrucao is
			when "000" => --NOP
				Rd_EN <= '0';
				Wr_EN <= '0';
				Interrupt_Conf_EN <= '0';
				Direction_Conf_EN <= '0';
			when "001" => -- Data Read
				Rd_EN <= '1';
				Wr_EN <= '0';
				Interrupt_Conf_EN <= '0';
				Direction_Conf_EN <= '0';
			when "010" => -- Data Write
				Rd_EN <= '0';
				Wr_EN <= '1';
				Interrupt_Conf_EN <= '0';
				Direction_Conf_EN <= '0';
			when "011" => -- Interrupt Enable Configure
				Rd_EN <= '0';
				Wr_EN <= '0';
				Interrupt_Conf_EN <= '1';
				Direction_Conf_EN <= '0';
			when "100" => -- Direction Enable COnfigure
				Rd_EN <= '0';
				Wr_EN <= '0';
				Interrupt_Conf_EN <= '0';
				Direction_Conf_EN <= '1';
			when others =>
				Rd_EN <= '0';
				Wr_EN <= '0';
				Interrupt_Conf_EN <= '0';
				Direction_Conf_EN <= '0';
		end case;

end process Decod;

end combinacional;