library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--é bem especifica para este pipeline
entity forwarding_unit is
    port(    instruction_0_4_red    : in std_logic_vector(0 to 4);
             instruction_5_8        : in std_logic_vector(0 to 3);
             instruction_9_12       : in std_logic_vector(0 to 3);
             instruction_5_8_red    : in std_logic_vector(0 to 3);
             instruction_9_12_red   : in std_logic_vector(0 to 3);
             aux_sel_mux_for_A      : out std_logic_vector(0 to 1);
             aux_sel_mux_for_B      : out std_logic_vector(0 to 1)
    );
end forwarding_unit;

    architecture comportamental of forwarding_unit is
        begin
        
        for_unit : process (instruction_0_4_red, instruction_5_8, instruction_9_12, instruction_5_8_red, instruction_9_12_red)
        begin
            case instruction_0_4_red is --avalia qual a instrucao do segundo estagio pra saber de onde tirar o dado
                when "00001" | "10010" | "00010" | "10000" | "10001" => -- operacoes da ULA: add, sub, and, or, slt
                    
                    -- mux FOR_A
                    if instruction_5_8 = instruction_5_8_red then -- leitura r1 branco = destino rd1 vermelho
                        aux_sel_mux_for_A <= "10"; -- entrega o sinal LO da alu
                    else
                        aux_sel_mux_for_A <= "00"; -- entrega o sinal do banco de regs
                    end if;

                    --MUX FOR_B
                    if instruction_9_12 = instruction_5_8_red then-- leiura r2 branco = destino rd1 vermelho
                        aux_sel_mux_for_B <= "10";
                    else
                        aux_sel_mux_for_B <= "00";
                    end if;

                when "01110" | "00100" => -- mul, div
                    -- mux FOR_A
                    if instruction_5_8 = instruction_5_8_red then -- leitura r1 branco = destino rd1 vermelho
                        aux_sel_mux_for_A <= "10"; -- entrega o sinal LO da alu
                    elsif instruction_5_8 = instruction_9_12_red then --leitura r1 = destino rd2 vermelho
                        aux_sel_mux_for_A <= "01"; -- entrega o sinal HI da alu
                    else
                        aux_sel_mux_for_A <= "00"; -- entrega o sinal do banco de regs
                    end if;
                    
                    --MUX FOR_B
                    if instruction_9_12 = instruction_5_8_red then-- leiura r2 branco = destino rd1 vermelho
                        aux_sel_mux_for_B <= "10";
                    elsif instruction_9_12 = instruction_9_12_red then --leitura r2 = destino rd2 vermelho
                        aux_sel_mux_for_B <= "01"; -- entrega o sinal HI da alu
                    else
                        aux_sel_mux_for_B <= "00";
                    end if;

                when "01101" => --load word
                                    -- mux FOR_A
                if instruction_5_8 = instruction_9_12_red then -- leitura r1 branco = destino load word
                    aux_sel_mux_for_A <= "11"; -- entrega o sinal da memoria
                else
                    aux_sel_mux_for_A <= "00"; -- entrega o sinal do banco de regs
                end if;

                --MUX FOR_B
                if instruction_9_12 = instruction_9_12_red then-- leiura r2 branco = destino load word
                    aux_sel_mux_for_B <= "11";
                else
                    aux_sel_mux_for_B <= "00";
                end if;

                when others =>-- como a instrucao nao carrega no banco de registradores, nao precisa de foward
                    aux_sel_mux_for_A <= "00";
                    aux_sel_mux_for_B <= "00";
            end case;

        end process for_unit;
    end comportamental;