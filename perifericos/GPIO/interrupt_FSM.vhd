library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity interrupt_FSM is
    port (
            -- genericos
            Clock       : in std_logic;
            Reset       : in std_logic;
            -- entradas
            Interrupt   : in std_logic; --avisa que houve alguma interrupção
            en_alert    : in std_logic; -- avisa que é pra voltar a receber interrupções
            dis_alert   : in std_logic; -- avisa que não deve mais receber interrupções
            -- saidas
            EPC_EN      : out std_logic; -- habilita o registrador EPC para o endereço de retorno
            MEPC        : out std_logic_vector(0 to 1) -- MUX que controla qual será a próxima instrução
    );
end entity interrupt_FSM;

architecture FSM of interrupt_FSM is
    type state is (WAIT_FOR_INT, REDIRECT, EXECUTE_ISR, NEW_REDIRECT, RETURN_STATE);
    signal current_state, next_state : state;

begin
    
	 sync: process (Reset, Clock)
    begin
        if(rising_edge(Clock)) then
            if(Reset = '1') then
                current_state <= WAIT_FOR_INT;
            else
                current_state <= next_state;
				end if;
        end if;
    end process sync;

    proc_FSM: process(current_state, Interrupt, en_alert)
    begin
        -- a principio, todo mundo desabilitado
        -- se algum case mudar o valor, esse novo valor que será utilizado
        EPC_EN <= '0';
        MEPC   <= "00";
        
		  case current_state is
            
				when WAIT_FOR_INT =>
                if(Interrupt = '1') then
						next_state <= REDIRECT;
					 else
						next_state <= WAIT_FOR_INT;
					 end if;
            
            when REDIRECT =>
                EPC_EN <= '1'; -- guarda a instrução de retorno
                MEPC <= "10"; -- desvia para a ISR

                next_state <= EXECUTE_ISR;

            when EXECUTE_ISR => -- a ISR acaba quando en_alert fica em 1. Confere se tem nova interrupção
                if(en_alert = '0') then
                    next_state <= EXECUTE_ISR;
                elsif (en_alert = '1' and Interrupt = '1') then
                    next_state <= NEW_REDIRECT;
                elsif (en_alert = '1' and Interrupt = '0') then
                    next_state <= RETURN_STATE;
                else
                    next_state <= RETURN_STATE;
                end if;

            when NEW_REDIRECT => --desvia direto para a proxima ISR, sem retornar ao fluxo normal
                MEPC <= "10"; --desvia para a ISR
                    
                next_state <= EXECUTE_ISR;

            when RETURN_STATE =>
                MEPC <= "01"; -- retorna para a instrução guardada em EPC
                
                next_state <= WAIT_FOR_INT;
            when others =>
                next_state <= WAIT_FOR_INT;

        end case;
		end process proc_FSM; 
    
    
    
end architecture FSM;