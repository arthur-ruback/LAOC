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
    entrada_a : in std_logic_vector(0 to (largura_dado - 1));
    entrada_b : in std_logic_vector(0 to (largura_dado - 1));
    seletor   : in std_logic_vector(0 to 3);
    saida_hi  : out std_logic_vector(0 to (largura_dado - 1));
    saida_lo  : out std_logic_vector(0 to (largura_dado - 1));
    flag_zero : out std_logic;
	 overflow  : out std_logic
  );
end ula_mod;

architecture comportamental of ula_mod is
  signal resultado_ula : std_logic_vector(0 to (2 * largura_dado - 1));
  signal aux : std_logic_vector(0 to (largura_dado - 1));
begin

	
  alu_op: process (entrada_a, entrada_b, seletor, aux) is
  begin
    case(seletor) is
      when "0000" => -- soma com sinal
      resultado_ula <= (x"0000") & std_logic_vector(signed(entrada_a) + signed(entrada_b));
      when "0001" => -- subtração com sinal
      resultado_ula <= (x"0000") & std_logic_vector(signed(entrada_a) - signed(entrada_b));
      when "0010" => -- and lógico
      resultado_ula <= (x"0000") & entrada_a and entrada_b;
      when "0011" => -- or lógico
      resultado_ula <= (x"0000") & entrada_a or entrada_b;
      when "0100" => -- not lógico
      resultado_ula <= (x"0000") & not(entrada_a);
      when "0101" => -- multiplicação
      resultado_ula <= std_logic_vector(signed(entrada_a) * signed(entrada_b));
      when "0110" => -- Divisão, hi = resto, lo = quociente
      -- TODO: CONSERTAR
      resultado_ula <= (x"00000000");
      when "0111" => -- Comparação A < B
			if (signed(entrada_a) < signed(entrada_b)) then
			  resultado_ula <= (others => '1');
			else
			  resultado_ula <= (others => '0');
			end if;
		when "1000" => -- Comparação A == B
			if (signed(entrada_a) = signed(entrada_b)) then
			  resultado_ula <= (others => '1');
			else
			  resultado_ula <= (others => '0');
			end if;
      when others =>
      resultado_ula <= (x"00000000");
    end case;
  end process alu_op;
  
  
  proc_flag_zero: process (resultado_ula)
  begin
	 if resultado_ula = x"00000000" then
      flag_zero <= '1';
    else
      flag_zero <= '0';
    end if;
  end process proc_flag_zero;

  proc_overflow : process (seletor, entrada_a, entrada_b, resultado_ula)  
    if (seletor = "0000") then --caso seja soma
      -- se ambas as entradas forem positivas e o resultado for negativo
      if(resultado_ula(15) = '1' and entrada_a(15) = '0' and entrada_b(15) = '0') then
        overflow <= '1'; 
      -- se ambas as entradas forem negativas e o resultado for positivo
      elsif (resultado_ula(15) = '0' and entrada_a(15) = '1' and entrada_b(15) = '1') then
        overflow <= '1';
      else
        overflow <= '0';
      end if;
    else  
      overflow <= '0';
    end if;
  end process proc_overflow;

  saida_hi <= resultado_ula(0 to largura_dado-1);
  saida_lo <= resultado_ula(largura_dado to (2 * largura_dado - 1));
end comportamental;