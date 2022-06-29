-- Quartus Prime VHDL Template
-- Single port RAM with single read/write address 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memd is

	generic (
        number_of_words : natural := 4096; -- número de words que a sua memória é capaz de armazenar
        MD_DATA_WIDTH   : natural := 16; -- tamanho da palavra em bits
        MD_ADDR_WIDTH   : natural := 16 -- tamanho do endereco da memoria de dados em bits
    );

	port (
        clk                 : in std_logic;
        mem_write           : in std_logic;
        write_data_mem      : in std_logic_vector(0 to MD_DATA_WIDTH - 1);
        adress_mem          : in std_logic_vector(0 to MD_ADDR_WIDTH - 1);
        read_data_mem       : out std_logic_vector(0 to MD_DATA_WIDTH - 1)
    );

end entity;

architecture rtl of memd is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector((MD_DATA_WIDTH-1) downto 0);
	type memory_t is array(2**MD_ADDR_WIDTH-1 downto 0) of word_t;

	-- Declare the RAM signal.	
	signal ram : memory_t;

	-- Register to hold the address 
	signal addr_reg : natural range 0 to 2**MD_ADDR_WIDTH-1;

begin

	process(clk)
	begin
	if(rising_edge(clk)) then
		if(mem_write = '1') then
			ram(to_integer(unsigned(adress_mem))) <= write_data_mem;
		end if;

		-- Register the address for reading
		addr_reg <= to_integer(unsigned(adress_mem));
	end if;
	end process;

	read_data_mem <= ram(addr_reg);

end rtl;
