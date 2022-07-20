library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity GPIO is
    port (
        -- genericos
        Clock           : std_logic;
        Reset           : std_logic;
        --sinais internos
        instrucao       : in std_logic_vector(0 to 7); --instrucao vinda do registrador especial
        Data            : in std_logic_vector(0 to 7); -- dados que serão utilizados para vários fins
        interrupt_flag  : out std_logic_vector(0 to 7);
        Data_read       : out std_logic_vector(0 to 7);
        Pins            : inout std_logic_vector(0 to 7)
    );
end entity GPIO;

architecture dataflow of GPIO is
    component Decod_GPIO
        port(   Instrucao 			: in std_logic_vector(0 to 2); -- sao apenas 6 instrucoes
                    -- sinais de habilitacao dos registradores
                Rd_EN				: out std_logic;
                Wr_EN				: out std_logic;
                Interrupt_Conf_EN	: out std_logic;
                Direction_Conf_EN	: out std_logic
        );
    end component;

    component Caminho_Dados_GPIO
        port(	reset               : in std_logic;
                clk                 : in std_logic;
                --sinais de controle
                Rd_EN				: in std_logic;
                Wr_EN				: in std_logic;
                Interrupt_Conf_EN	: in std_logic;
                Direction_Conf_EN	: in std_logic;
                -- sinais de dados
                Data                : in std_logic_vector(0 to 7); -- dados que podem ser config ou saida
                Data_read             : out std_logic_vector(0 to 7); -- dados recebidos pelos pinos
                Interrupt_flag      : out std_logic_vector(0 to 7);
                Pins                : inout std_logic_vector(0 to 7)
        );
    end component;
    
    signal Rd_EN, Wr_EN, Interrupt_Conf_EN, Direction_Conf_EN	: std_logic;

begin
    
    decodificador : Decod_GPIO
        port map(   Instrucao 	    =>	instrucao(5 to 7), -- 3 bits menos significativos da instrucao vinda de fora	
                    -- sinais de habilitacao dos registradores
                Rd_EN			    => Rd_EN,	
                Wr_EN			    => Wr_EN,	
                Interrupt_Conf_EN   => Interrupt_Conf_EN,	
                Direction_Conf_EN   => Direction_Conf_EN	
        );

    cam_dados_GPIO: Caminho_Dados_GPIO
    port map(	reset               => Reset,
                clk                 => Clock,
                --sinais de controle
                Rd_EN				=> Rd_EN,
                Wr_EN				=> Wr_EN,
                Interrupt_Conf_EN   => Interrupt_Conf_EN,
                Direction_Conf_EN	=> Direction_Conf_EN,
                -- sinais de dados
                Data                => Data,
                Data_read           => Data_read,
                Interrupt_flag      => Interrupt_flag,
                Pins                => Pins
);
    
    
end architecture dataflow;