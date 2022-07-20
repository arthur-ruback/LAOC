library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- esse bloco identifica qual a interrupção ativa e entrega a ISR correspondente
entity Interrupt_Decode_to_Addr is
    port (
        current : in std_logic_vector(0 to 15);
        ISR_addr: out std_logic_vector(0 to 15)
    );
end entity Interrupt_Decode_to_Addr;

architecture combinacional of Interrupt_Decode_to_Addr is
    
begin 
     -- só vai ter uma rotina de interrupção por enquanto, a do GPIO
    ISR_addr <= x"0028" when current = "1000000000000000" else -- overflow pula para a instrução 20 << 1
                x"0040" when current = "0100000000000000" else -- GPIO pula para a instrução 32 << 1
                (others => '0');
    
    
end architecture combinacional;