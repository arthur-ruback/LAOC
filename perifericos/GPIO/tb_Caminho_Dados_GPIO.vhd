library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_Caminho_Dados_GPIO is
end tb_Caminho_Dados_GPIO;

architecture teste of tb_Caminho_Dados_GPIO is
    component Caminho_Dados_GPIO
		 port (	reset               : in std_logic;
					clk                 : in std_logic;
					--sinais de controle
					Rd_EN				: in std_logic;
					Wr_EN				: in std_logic;
					Interrupt_Conf_EN	: in std_logic;
					Direction_Conf_EN	: in std_logic;
					-- sinais de dados
					Data                : in std_logic_vector(0 to 7); -- dados que podem ser config ou saida
					Data_read           : out std_logic_vector(0 to 7); -- dados recebidos pelos pinos
					Interrupt_flag      : out std_logic_vector(0 to 7);
					Pins                : inout std_logic_vector(0 to 7)
			  );
    end component;

    signal tb_reset, tb_clk, tb_Rd_EN, tb_Wr_EN, tb_Interrupt_Conf_EN, tb_Direction_Conf_EN	: std_logic := '0';
    signal tb_Data, tb_Data_read, tb_Interrupt_flag, tb_Pins : std_logic_vector(0 to 7);    

    begin
    --============    
    --INSTANCIACAO
    --============
    DUT: Caminho_Dados_GPIO
    port map(   reset               => tb_reset,               
                clk                 => tb_clk,                
                --sinais de controle
                Rd_EN               => tb_Rd_EN,				
                Wr_EN               => tb_Wr_EN,				
                Interrupt_Conf_EN   => tb_Interrupt_Conf_EN,	
                Direction_Conf_EN   => tb_Direction_Conf_EN,	
                -- sinais de dados
                Data                => tb_Data,                
                Data_read           => tb_Data_read,             
                Interrupt_flag      => tb_Interrupt_flag,      
                Pins                => tb_Pins                
        );
    
    
    --============    
    -- ATRIBUICOES
    --============
    tb_clk <= not tb_clk after 10 ns;
    tb_reset <= '1', '0' after 40 ns;

    tb_Data <= "11111111"; -- habilita as interrupçoes
    
	  
	 tb_Pins <= "11111111", "01111111" after 200 ns; 

    tb_Rd_EN <= '0'; -- nunca le nem nunca escreve
    tb_Wr_EN <= '0';
    tb_Interrupt_Conf_EN <= '1', '0' after 100 ns;
    tb_Direction_Conf_EN <= '0'; -- sempre entrada

end teste;