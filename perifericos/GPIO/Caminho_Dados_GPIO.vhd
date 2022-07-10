library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Caminho_Dados_GPIO is
    port(	reset               : in std_logic;
            clk                 : in std_logic;
            --sinais de controle
            Rd_EN				: in std_logic;
            Wr_EN				: in std_logic;
            Interrupt_Conf_EN	: in std_logic;
            Direction_Conf_EN	: in std_logic;
            -- sinais de dados
            Data                : in std_logic_vector(0 to 7); -- dados que podem ser config ou saida
            Data_in             : out std_logic_vector(0 to 7); -- dados recebidos pelos pinos
            Interrupt_flag      : out std_logic_vector(0 to 7);
            Pins                : inout std_logic_vector(0 to 7)

    );
end Caminho_Dados_GPIO;

architecture dataflow of Caminho_Dados_GPIO is
    --===========
    --COMPONENTES
    --===========
    component registrador
        generic (
            largura_dado : natural := 16
        );
        port (
            entrada_dados  : in std_logic_vector(0 to (largura_dado - 1));
            WE, clk, reset : in std_logic;
            saida_dados    : out std_logic_vector(0 to (largura_dado - 1))
        );
    end component;

    --======
    --SINAIS
    --======
    signal Direction_Conf, Interrupt_Conf :std_logic_vector(0 to 7); --sinal que vai direto nos buffers tri-state
    signal pre_buffer :std_logic_vector(0 to 7); --sinal que sai do reg de saida e vai para o buffer tri-state

begin
--=============
--INSTANCIACOES
--=============

    INT: registrador --recebe a configuracao de interrupcoes
            generic map (largura_dado => 8)
            port map(   entrada_dados   => Data,  
                        WE              => Interrupt_Conf_EN,
                        clk             => clk,
                        reset           => reset,
                        saida_dados     => Interrupt_Conf
            );    
    
    DIR: registrador --recebe a configuracao de direcao dos pinos
            generic map (largura_dado => 8)
            port map(   entrada_dados   => Data,  
                        WE              => Direction_Conf_EN,
                        clk             => clk,
                        reset           => reset,
                        saida_dados     => Direction_Conf
            );
    
    DATAIN: registrador --recebe dados de fora
    generic map (largura_dado => 8)
    port map(   entrada_dados   => Pins,  
                WE              => Rd_EN,
                clk             => clk,
                reset           => reset,
                saida_dados     => Data_in
    );

    DATAOUT: registrador --entrega dados para fora
    generic map (largura_dado => 8)
    port map(   entrada_dados   => Data,  
                WE              => Wr_EN,
                clk             => clk,
                reset           => reset,
                saida_dados     => pre_buffer
    );

--===========
--ATRIBUICOES
--===========
edge_detection: process (Pins, clk)
begin
    
    for i in 0 to 7 loop
        if (rising_edge(Pins(i)) or falling_edge(Pins(i)) ) then -- so habilita a interrupção se estiver configurado
            if (Interrupt_Conf(i) = '1') then
					Interrupt_flag(i) <= '1';
				end if;
        elsif (rising_edge(clk)) then -- apaga no próximo pulso de clock
            Interrupt_flag(i) <= '0';
        end if;
    end loop;

end process edge_detection;

buffer_tri_state: for i in 0 to 7 generate -- buffer tri-state
        Pins(i) <= pre_buffer(i) when Direction_Conf(i) = '0' else
                   'Z';
end generate buffer_tri_state;

end dataflow;