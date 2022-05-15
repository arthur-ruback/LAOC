-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
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
end memd;

architecture comportamental of memd is
    --alocar espaço para a memoria e iniciar com 0
    type memory_t is array (0 to number_of_words - 1) of std_logic_vector(0 to MD_DATA_WIDTH - 1);
    signal ram      : memory_t := (others => (others => '0'));
    signal ram_addr : std_logic_vector(0 to MD_ADDR_WIDTH - 1);
begin
    ram_addr <= adress_mem(0 to MD_ADDR_WIDTH - 1);
    process (clk)
    begin
        if (rising_edge(clk)) then
            if (mem_write = '1') then
                ram(to_integer(unsigned(ram_addr))) <= write_data_mem;
            end if;
        end if;
		  -- leitura na borda de descida para instanciar ram
		  if (falling_edge(clk)) then
				if unsigned(ram_addr) < number_of_words then -- valid addr check
					read_data_mem <= ram(to_integer(unsigned(ram_addr)));
				end if;
		  end if;
    end process;
    
end comportamental;

