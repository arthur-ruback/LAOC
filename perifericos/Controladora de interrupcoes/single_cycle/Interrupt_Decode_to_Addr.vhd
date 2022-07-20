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
    ISR_addr <= "1000000000000000" when current = "1000000000000000" else
                (others => '0');
    
    
end architecture combinacional;