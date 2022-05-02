-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Banco de registradores com entradas e saída de dados de tamanho genérico
-- entradas de endereço de tamanho genérico
-- clock e sinal de WE1

-- modificado para leitura dupla
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity banco_registradores_mod is
    generic (
        largura_dado : natural;
        largura_ende : natural
    );

    port (
        ent_Rd1_ende : in std_logic_vector((largura_ende - 1) downto 0);
        ent_Rd2_ende : in std_logic_vector((largura_ende - 1) downto 0);
        ent_Wd1_ende : in std_logic_vector((largura_ende - 1) downto 0);
        ent_Wd1_dado : in std_logic_vector((largura_dado - 1) downto 0);
        ent_Wd2_ende : in std_logic_vector((largura_ende - 1) downto 0);
        ent_Wd2_dado : in std_logic_vector((largura_dado - 1) downto 0);
        sai_Rd1_dado : out std_logic_vector((largura_dado - 1) downto 0);
        sai_Rd2_dado : out std_logic_vector((largura_dado - 1) downto 0);
        clk,WE1,WE2  : in std_logic
    );
end banco_registradores_mod;

architecture comportamental of banco_registradores_mod is
    type registerfile is array(0 to ((2 ** largura_ende) - 1)) of std_logic_vector((largura_dado - 1) downto 0);
    signal banco : registerfile;
begin
    leitura : process (clk) is
    begin
        -- lê o registrador de endereço Rd1 da instrução apontada por PC no ciclo anterior,
        -- lê o registrador de endereço Rd2 da instrução apontada por PC no ciclo anterior.
        sai_Rd1_dado <= banco(to_integer(unsigned(ent_Rd1_ende)));
        sai_Rd2_dado <= banco(to_integer(unsigned(ent_Rd2_ende)));
    end process;

    escrita : process (clk) is
    begin
        if rising_edge(clk) then
            if WE1 = '1' then
                banco(to_integer(unsigned(ent_Wd1_ende))) <= ent_Wd1_dado;
            end if;
            if WE2 = '1' then
                banco(to_integer(unsigned(ent_Wd2_ende))) <= ent_Wd2_dado;
            end if;
        end if;
    end process;
end comportamental;