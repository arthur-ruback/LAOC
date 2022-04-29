-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Unidade de controle ciclo único (look-up table) do processador
-- puramente combinacional
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- unidade de controle
entity unidade_de_controle_ciclo_unico is
    generic (
        INSTR_WIDTH       : natural := 16;
        OPCODE_WIDTH      : natural := 5;
        DP_CTRL_BUS_WIDTH : natural := 17;
        ULA_CTRL_WIDTH    : natural := 3
    );
    port (
        instrucao : in std_logic_vector(INSTR_WIDTH - 1 downto 0);       -- instrução
        controle  : out std_logic_vector(DP_CTRL_BUS_WIDTH - 1 downto 0) -- controle da via
    );
end unidade_de_controle_ciclo_unico;

architecture beh of unidade_de_controle_ciclo_unico is
    -- As linhas abaixo não produzem erro de compilação no Quartus II, mas no Modelsim (GHDL) produzem.	
    --signal inst_aux : std_logic_vector (INSTR_WIDTH-1 downto 0);			-- instrucao
    --signal opcode   : std_logic_vector (OPCODE_WIDTH-1 downto 0);			-- opcode
    --signal ctrl_aux : std_logic_vector (DP_CTRL_BUS_WIDTH-1 downto 0);		-- controle

    signal inst_aux : std_logic_vector (15 downto 0); -- instrucao
    signal opcode   : std_logic_vector (4 downto 0);  -- opcode
    signal ctrl_aux : std_logic_vector (16 downto 0);  -- controle

begin
    inst_aux <= instrucao;
    -- A linha abaixo não produz erro de compilação no Quartus II, mas no Modelsim (GHDL) produz.	
    --	opcode <= inst_aux (INSTR_WIDTH-1 downto INSTR_WIDTH-OPCODE_WIDTH);
    opcode <= inst_aux (4 downto 0);

    -- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
    -- 0  1  2  3   4   5   6   7   8  9  10 11 12     13     14  15  16

    process (opcode) 
							--
							---OLHAR O ZERO NO BRANCH!!!
							--
    begin
        case opcode is
                -------------
					 -- SYSCALL --
					------------- 
            when "00000" =>
									-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "0  0  0  0   0   0   0   0   0  0   0  0 0       0      1   1   1";
                ---------
					 -- ADD --
					 ---------
            when "00001" =>
                				-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "0  0  0  0   1   1   1   0   0  0   0  0 0       0      1   1   1";
                ---------
					 -- AND --
					 ---------
            when "00010" =>
 									-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "0  1  0  0   1   1   1   0   0  0   0  0 0       0      1   1   1";
                ---------
					 -- BEQ -- OLHAR A QUESTÃO DO ZERO NO BRANCH!!!!!!!!!!!!!!!!!!!!
					 ---------
            when "00011" =>
									-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "0  0  1  0   0   0   0   0   0  0   0  0 0       0      1   0   1";
                ---------
					 -- DIV --
					 ---------
            when "00100" =>
									-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "1  1  0  0   1   1   1   1   0  0   0  0 0       0      1   1   1";
						-----------
						-- JUMPI --
						-----------
				 when "00101" =>
									-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "0  0  0  0   0   0   0   0   0  0   0  0 0       0      1   0   1";           
						-----------
						-- JUMPL --
						-----------
				when "00110" =>
									-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "0  0  0  1   0   0   1   0   0  0   0  0 0       0      0   0   1";
						-----------
						-- JUMPR --
						-----------
				when "00111" =>
									-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "0  0  0  0   0   0   0   0   0  0   0  0 0       0      0   0   1";
						---------
						-- LI1 --
						---------
				when "01000" =>
									-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "0  0  0  0   0   0   0   0   1  0   1  0 0       0      1   1   1";				
						----------
						-- LI2 --
						----------
				when "01001" =>
									-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "0  0  0  0   0   0   0   0   0  1   0  1 0       0      1   1   1";
						----------
						-- LOP1 --
						----------
				when "01010" =>
									-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "0  0  0  0   0   0   0   0   1  0   0  0 0       0      1   1   1";
						----------
						-- LOP2 --
						----------
				when "01011" =>
									-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "0  0  0  0   0   0   0   0   0  1   0  0 0       0      1   1   1";
						-----------
						-- LOP12 --
						-----------
				when "01100" =>
									-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "0  0  0  0   0   0   0   0   1  1   0  0 0       0      1   1   1";
						--------
						-- LW --
						--------
				when "01101" =>
									-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "0  0  0  0   1   0   1   0   0  0   0  0 0       0      1   1   1";
						---------
						-- MUL --
						---------
				when "01110" =>
									-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "1  0  1  0   1   1   1   1   0  0   0  0 0       0      1   1   1";
						---------
						-- NOP --
						---------
				when "01111" =>
									-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "0  0  0  0   0   0   0   0   0  0   0  0 0       0      1   1   1";
						--------
						-- OR --
						--------
				when "10000" =>
									-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "0  1  1  0   1   1   1   0   0  0   0  0 0       0      1   1   1";
						---------
						-- SLT --
						---------
				when "10001" =>
									-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "1  1  1  0   1   1   1   0   0  0   0  0 0       0      1   1   1";
						---------
						-- SUB --
						---------
				when "10010" =>
									-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "0  0  1  0   1   1   1   0   0  0   0  0 0       0      1   1   1";
						---------
						-- SW --
						---------
				when "10011" =>
									-- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
                ctrl_aux <=  "0  0  0  0   0   0   0   0   0  0   0  0 1       0      1   1   1";
				
				when others =>
                ctrl_aux <= (others => '0');
        end case;
    end process;
    controle <= ctrl_aux;
end beh;