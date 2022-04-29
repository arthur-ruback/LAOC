-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Unidade Lógica e Aritmética com capacidade para 8 operações distintas, além de entradas e saída de dados genérica.
-- Os três bits que selecionam o tipo de operação da ULA são os 3 bits menos significativos do OPCODE (vide aqrquivo: par.xls)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula_mod is
  generic (
    largura_dado : natural := 16
  );

  port (
    entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
    entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
    seletor : in std_logic_vector(2 downto 0);
    saida_hi : out std_logic_vector((largura_dado - 1) downto 0);
    saida_lo : out std_logic_vector((largura_dado - 1) downto 0);
    flag_zero: out std_logic
  );
end ula_mod;

architecture comportamental of ula_mod is
  signal resultado_ula : std_logic_vector((2 * largura_dado - 1) downto 0);
  signal aux : std_logic_vector((largura_dado - 1) downto 0);
begin
  process (entrada_a, entrada_b, seletor, aux) is
  begin
    case(seletor) is
      when "000" => -- soma com sinal
      resultado_ula <= (x"0000") & std_logic_vector(signed(entrada_a) + signed(entrada_b));
      when "001" => -- subtração com sinal
      resultado_ula <= (x"0000") & std_logic_vector(signed(entrada_a) - signed(entrada_b));
      when "010" => -- and lógico
      resultado_ula <= (x"0000") & entrada_a and entrada_b;
      when "011" => -- or lógico
      resultado_ula <= (x"0000") & entrada_a or entrada_b;
      when "100" => -- not lógico
      resultado_ula <= (x"0000") & not(entrada_a);
      when "101" => -- multiplicação
      resultado_ula <= std_logic_vector(signed(entrada_a) * signed(entrada_b));
      when "110" => -- Divisão, hi = resto, lo = quociente
      -- TODO: CONSERTAR
      resultado_ula <= (x"00000000");
      when "111" => -- Comparação A < B
      if (signed(entrada_a) < signed(entrada_b)) then
        resultado_ula <= (others => '1');
      else
        resultado_ula <= (others => '0');
      end if;
      when others =>
      resultado_ula <= (x"00000000");
    end case;
    if resultado_ula = x"00000000" then
      flag_zero <= '1';
    else
      flag_zero <= '0';
    end if;
  end process;
  saida_hi <= resultado_ula((2 * largura_dado - 1) downto largura_dado);
  saida_lo <= resultado_ula(largura_dado - 1 downto 0);
end comportamental;