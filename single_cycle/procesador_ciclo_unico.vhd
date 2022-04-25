-- Processador de Ciclo Único 
-- UFMG
-- Arthur Coelho e Gabriel Pimenta

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity procesador_ciclo_unico is
    port (
        clk   : in std_logic;
        reset : in std_logic
    );
end entity;

architecture rtl of procesador_ciclo_unico is

    -- Declaração blocos
    component banco_registradores_mod is
        port (
            ent_Rd1_ende : in std_logic_vector(15 downto 0);
            ent_Rd2_ende : in std_logic_vector(15 downto 0);
            ent_Wd1_ende : in std_logic_vector(15 downto 0);
            ent_Wd1_dado : in std_logic_vector(15 downto 0);
            ent_Wd2_ende : in std_logic_vector(15 downto 0);
            ent_Wd2_dado : in std_logic_vector(15 downto 0);
            sai_Rd1_dado : out std_logic_vector(15 downto 0);
            sai_Rd2_dado : out std_logic_vector(15 downto 0);
            clk,WE1,WE2  : in std_logic
        );
    end component;

    component mux21 is
        port (
        dado_ent_0, dado_ent_1 : in std_logic_vector(15 downto 0);
        sele_ent               : in std_logic;
        dado_sai               : out std_logic_vector(15 downto 0)
        );
    end component;

    component registrador is
        port (
            entrada_dados  : in std_logic_vector(15 downto 0);
            WE, clk, reset : in std_logic;
            saida_dados    : out std_logic_vector(15 downto 0)
        );
    end component;

    component ula_mod is
        port (
            entrada_a : in std_logic_vector(15 downto 0);
            entrada_b : in std_logic_vector(15 downto 0);
            seletor   : in std_logic_vector(2 downto 0);
            saida_hi  : out std_logic_vector(15 downto 0);
            saida_lo  : out std_logic_vector(15 downto 0)
        );
    end component;

    -- Declaração Sinais
    signal WE1, WE2                               : std_logic;
    signal A1, A2, WA1, WA2, WD1, WD2, RD1, RD2   : std_logic_vector(15 downto 0);
    signal signExt_out, in_reg_A, in_reg_B        : std_logic_vector(15 downto 0);
    signal c_mux_regBankOut_A, c_mux_regBankOut_B : std_logic;
    signal HI, LOW, in_ALU_A, in_ALU_B            : std_logic_vector(15 downto 0);
    signal c_reg_A, c_reg_B                       : std_logic;
    

begin

    -- Instanciação blocos
    regbank: banco_registradores_mod
        generic map (
            largura_dado => 16,
            largura_ende => 16
        )
        port map (
            clk   => clk,
            WE1   => WE1,
            WE2   => WE2,
            ent_Rd1_ende => A1,
            ent_Rd2_ende => A2,
            ent_Wd1_ende => WA1,
            ent_Wd1_dado => WD1,
            ent_Wd2_ende => WA2,
            ent_Wd2_dado => WD2,
            sai_Rd1_dado => RD1,
            sai_Rd2_dado => RD2
        );
    
    mux_regBankOut_A: mux21
        generic map (
            largura_dado => 16
        )
        port map (
            dado_ent_0 => RD1,
            dado_ent_1 => signExt_out,
            sele_ent   => c_mux_regBankOut_A,
            dado_sai   => in_reg_A
            
        );

    mux_regBankOut_B: mux21
        generic map (
            largura_dado => 16
        )
        port map (
            dado_ent_0 => RD2,
            dado_ent_1 => signExt_out,
            sele_ent   => c_mux_regBankOut_B,
            dado_sai   => in_reg_B
            
        );

    reg_A: registrador
        generic map (
            largura_dado => 16
        )
        port map (
            clk   => clk,
            reset => reset,
            WE    => c_reg_A,
            entrada_dados => in_reg_A,
            saida_dados => in_ALU_A
        );

    reg_B: registrador
        generic map (
            largura_dado => 16
        )
        port map (
            clk   => clk,
            reset => reset,
            WE    => c_reg_B,
            entrada_dados => in_reg_B,
            saida_dados => in_ALU_B
        );

end architecture;