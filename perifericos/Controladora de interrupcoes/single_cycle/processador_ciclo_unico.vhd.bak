-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte

-- Processador de Ciclo Único 
-- UFMG
-- Arthur Coelho e Gabriel Pimentel

library IEEE;
use IEEE.std_logic_1164.all;

entity processador_ciclo_unico is
  generic (
    DATA_WIDTH : natural := 16; -- tamanho do barramento de dados em bits
    PROC_INSTR_WIDTH : natural := 16; -- tamanho da instrução do processador em bits
    PROC_ADDR_WIDTH : natural := 16; -- tamanho do endereço da memória de programa do processador em bits
    DP_CTRL_BUS_WIDTH : natural := 18 -- tamanho do barramento de controle em bits
  );
  
  port (
    --		Chaves_entrada 			: in std_logic_vector(DATA_WIDTH-1 downto 0);
    --		Chave_enter				: in std_logic;
    Leds_vermelhos_saida : out std_logic_vector(0 to DATA_WIDTH - 1);
    Chave_reset : in std_logic;
    Clock_in : in std_logic;
	 disp0 : out std_logic_vector(0 to 6);
	 disp1 : out std_logic_vector(0 to 6);
	 disp2 : out std_logic_vector(0 to 6);
	 disp3 : out std_logic_vector(0 to 6)
  );
end processador_ciclo_unico;

architecture comportamento of processador_ciclo_unico is
  -- declare todos os componentes que serão necessários no seu processador_ciclo_unico a partir deste comentário
  component via_de_dados_ciclo_unico is
    generic (
      -- declare todos os tamanhos dos barramentos (sinais) das portas da sua via_dados_ciclo_unico aqui.
      DP_CTRL_BUS_WIDTH : natural := 18; -- tamanho do barramento de controle da via de dados (DP) em bits
      DATA_WIDTH : natural := 16; -- tamanho do dado em bits
      PC_WIDTH : natural := 16; -- tamanho da entrada de endereços da MI ou MP em bits (memi.vhd)
      FR_ADDR_WIDTH : natural := 4; -- tamanho da linha de endereços do banco de registradores em bits
      INSTR_WIDTH : natural := 16 -- tamanho da instrução em bits
    );
    port (
      -- declare todas as portas da sua via_dados_ciclo_unico aqui.
      clock : in std_logic;
      reset : in std_logic;
      controle : in std_logic_vector (0 to DP_CTRL_BUS_WIDTH - 1);
      instrucao : in std_logic_vector (0 to INSTR_WIDTH - 1);
      pc_out : out std_logic_vector (0 to PC_WIDTH - 1);
      saida : out std_logic_vector (0 to DATA_WIDTH - 1)
    );
  end component;
  
  component digi_clk is
  port(clk1: in std_logic;
		clk:out std_logic);
  end component;
  
  component to_7seg is
  port(
		A : in  STD_LOGIC_VECTOR (0 to 3);
      seg7 : out  STD_LOGIC_VECTOR (0 to 6)
  );
  end component;

  component unidade_de_controle_ciclo_unico is
    generic (
      INSTR_WIDTH : natural := 16;
      OPCODE_WIDTH : natural := 5;
      DP_CTRL_BUS_WIDTH : natural := 18;
      ULA_CTRL_WIDTH : natural := 3
    );
    port (
      instrucao : in std_logic_vector(0 to INSTR_WIDTH - 1); -- instrução
      controle : out std_logic_vector(0 to DP_CTRL_BUS_WIDTH - 1) -- controle da via
    );
  end component;

  component memi is
    generic (
      INSTR_WIDTH : natural := 16; -- tamanho da instrução em número de bits
      MI_ADDR_WIDTH : natural := 11 -- tamanho do endereço da memória de instruções em número de bits
    );
    port (
      clk : in std_logic;
      reset : in std_logic;
      Endereco : in std_logic_vector(0 to MI_ADDR_WIDTH - 1);
      Instrucao : out std_logic_vector(0 to INSTR_WIDTH - 1)
    );
  end component;

  -- Declare todos os sinais auxiliares que serão necessários no seu processador_ciclo_unico a partir deste comentário.
  -- Você só deve declarar sinais auxiliares se estes forem usados como "fios" para interligar componentes.
  -- Os sinais auxiliares devem ser compatíveis com o mesmo tipo (std_logic, std_logic_vector, etc.) e o mesmo tamanho dos sinais dos portos dos
  -- componentes onde serão usados.
  -- Veja os exemplos abaixo:

  -- A partir deste comentário faça associações necessárias das entradas declaradas na entidade do seu processador_ciclo_unico com 
  -- os sinais que você acabou de definir.
  -- Veja os exemplos abaixo:
  signal aux_instrucao : std_logic_vector(0 to PROC_INSTR_WIDTH - 1);
  signal aux_controle : std_logic_vector(0 to DP_CTRL_BUS_WIDTH - 1);
  signal aux_endereco : std_logic_vector(0 to PROC_ADDR_WIDTH - 1);
  signal aux_saida : std_logic_vector(0 to 15);
  signal Clock : std_logic;

begin
  -- A partir deste comentário instancie todos o componentes que serão usados no seu processador_ciclo_unico.
  -- A instanciação do componente deve começar com um nome que você deve atribuir para a referida instancia seguido de : e seguido do nome
  -- que você atribuiu ao componente.
  -- Depois segue o port map do referido componente instanciado.
  -- Para fazer o port map, na parte da esquerda da atribuição "=>" deverá vir o nome de origem da porta do componente e na parte direita da 
  -- atribuição deve aparecer um dos sinais ("fios") que você definiu anteriormente, ou uma das entradas da entidade processador_ciclo_unico,
  -- ou ainda uma das saídas da entidade processador_ciclo_unico.
  -- Veja os exemplos de instanciação a seguir:
  
  clock_divider : digi_clk
  port map(
		clk1 => Clock_in,
		clk => Clock
  );
  
  instancia_memi : memi
  port map(
    clk => Clock,
    reset => Chave_reset,
    Endereco => aux_endereco(4 to 14), --memoria de instrucao tem bloco de 16 bits e pula de 1 em 1, 
													-- entao ignora o ultimo bit de PC, que pula de 2 em 2
    Instrucao => aux_instrucao
  );

  instancia_unidade_de_controle_ciclo_unico : unidade_de_controle_ciclo_unico
  port map(
    instrucao => aux_instrucao, -- instrução
    controle => aux_controle -- controle da via
  );

  instancia_via_de_dados_ciclo_unico : via_de_dados_ciclo_unico
  port map(
    -- declare todas as portas da sua via_dados_ciclo_unico aqui.
    clock => Clock,
    reset => Chave_reset,
    controle => aux_controle,
    instrucao => aux_instrucao,
    pc_out => aux_endereco,
    saida => aux_saida
  );
  
  Leds_vermelhos_saida <= aux_saida;
  
  seg0 : to_7seg
  port map(
		A => aux_saida(0 to 3),
		seg7 => disp0(0 to 6)
  );
  
  seg1 : to_7seg
  port map(
		A => aux_saida(4 to 7),
		seg7 => disp1(0 to 6)
  );
  
  seg2 : to_7seg
  port map(
		A => aux_saida(8 to 11),
		seg7 => disp2(0 to 6)
  );
  
  seg3 : to_7seg
  port map(
		A => aux_saida(12 to 15),
		seg7 => disp3(0 to 6)
  );
  
end comportamento;
