-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Via de dados do processador_ciclo_unico
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity via_de_dados_ciclo_unico is
  generic (
    -- declare todos os tamanhos dos barramentos (sinais) das portas da sua via_dados_ciclo_unico aqui.
    dp_ctrl_bus_width : natural := 18; -- tamanho do barramento de controle da via de dados (DP) em bits
    data_width : natural := 16; -- tamanho do dado em bits
    pc_width : natural := 16; -- tamanho da entrada de endereços da MI ou MP em bits (memi.vhd)
    fr_addr_width : natural := 4; -- tamanho da linha de endereços do banco de registradores em bits
    ula_ctrl_width : natural := 4; -- tamanho da linha de controle da ULA
    instr_width : natural := 16 -- tamanho da instrução em bits
  );
  port (
    -- declare todas as portas da sua via_dados_ciclo_unico aqui.
    clock : in std_logic;
    reset : in std_logic;
    controle : in std_logic_vector(0 to dp_ctrl_bus_width - 1);
    instrucao : in std_logic_vector(0 to instr_width - 1);
    pc_out : out std_logic_vector(0 to pc_width - 1);
    saida : out std_logic_vector(0 to data_width - 1)
  );
end entity via_de_dados_ciclo_unico;

architecture comportamento of via_de_dados_ciclo_unico is

  -- declare todos os componentes que serão necessários na sua via_de_dados_ciclo_unico a partir deste comentário
  component pc is
    generic (
      pc_width : natural := 16
    );
    port (
      entrada : in std_logic_vector(0 to pc_width - 1);
      saida : out std_logic_vector(0 to pc_width - 1);
      clk : in std_logic;
      we : in std_logic;
      reset : in std_logic
    );
  end component;

  component somador is
    generic (
      largura_dado : natural := 16
    );
    port (
      entrada_a : in std_logic_vector(0 to (largura_dado - 1));
      entrada_b : in std_logic_vector(0 to (largura_dado - 1));
      saida : out std_logic_vector(0 to (largura_dado - 1))
    );
  end component;

  component banco_registradores_mod is
    generic (
      largura_dado : natural := 16;
      largura_ende : natural := 4
    );
    port (
      ent_Rd1_ende : in std_logic_vector(0 to (largura_ende - 1));
      ent_Rd2_ende : in std_logic_vector(0 to (largura_ende - 1));
      ent_Wd1_ende : in std_logic_vector(0 to (largura_ende - 1));
      ent_Wd2_ende : in std_logic_vector(0 to (largura_ende - 1));
      ent_Wd1_dado : in std_logic_vector(0 to (largura_dado - 1));
      ent_Wd2_dado : in std_logic_vector(0 to (largura_dado - 1));
      sai_Rd1_dado : out std_logic_vector(0 to (largura_dado - 1));
      sai_Rd2_dado : out std_logic_vector(0 to (largura_dado - 1));
      clk : in std_logic;
      We1, We2 : in std_logic
    );
  end component;

  component memd is
    port (
      clk : in std_logic;
      mem_write : in std_logic;
      write_data_mem : in std_logic_vector(0 to data_width - 1);
      adress_mem : in std_logic_vector(0 to instr_width - 1);
      read_data_mem : out std_logic_vector(0 to data_width - 1)
    );
  end component;

  component ula_mod is
    generic (
      largura_dado : natural := 16
    );
    port (
      entrada_a : in std_logic_vector(0 to (largura_dado - 1));
      entrada_b : in std_logic_vector(0 to (largura_dado - 1));
      seletor : in std_logic_vector(0 to 3);
      saida_hi : out std_logic_vector(0 to (largura_dado - 1));
      saida_lo : out std_logic_vector(0 to (largura_dado - 1));
      flag_zero : out std_logic
    );
  end component;

  component mux21 is
    port (
      dado_ent_0, dado_ent_1 : in std_logic_vector(0 to 15);
      sele_ent : in std_logic;
      dado_sai : out std_logic_vector(0 to 15)
    );
  end component;

  component mux41 is
    generic (
      largura_dado : natural
    );
    port (
        dado_ent_0, dado_ent_1, dado_ent_2, dado_ent_3 : in std_logic_vector(0 to (largura_dado - 1));
        sele_ent                                       : in std_logic_vector(0 to 1);
        dado_sai                                       : out std_logic_vector(0 to (largura_dado - 1))
    );
  end component;

  component registrador is
	 generic(largura_dado: natural := 16);
    port (
      entrada_dados : in std_logic_vector(0 to largura_dado - 1);
      WE, clk, reset : in std_logic;
      saida_dados : out std_logic_vector(0 to largura_dado - 1)
    );
  end component;

  component extensor is
    port (
      entrada_Rs : in std_logic_vector(0 to 10);
      saida : out std_logic_vector(0 to (data_width - 1))
    );
  end component;
  
  component barrel_shift_x2 is
  port (
		entrada : in std_logic_vector(0 to 15);
		saida : out std_logic_vector(0 to 15)
	);
	end component;

  component forwarding_unit is
    port (instruction_0_4_red    : in std_logic_vector(0 to 4);
    instruction_5_8        : in std_logic_vector(0 to 3);
    instruction_9_12       : in std_logic_vector(0 to 3);
    instruction_5_8_red    : in std_logic_vector(0 to 3);
    instruction_9_12_red   : in std_logic_vector(0 to 3);
    aux_sel_mux_for_A      : out std_logic_vector(0 to 1);
    aux_sel_mux_for_B      : out std_logic_vector(0 to 1)
    );
  end component;
	
	

  -- Declare todos os sinais auxiliares que serão necessários na sua via_de_dados_ciclo_unico a partir deste comentário.
  -- Você só deve declarar sinais auxiliares se estes forem usados como "fios" para interligar componentes.
  -- Os sinais auxiliares devem ser compatíveis com o mesmo tipo (std_logic, std_logic_vector, etc.) e o mesmo tamanho dos sinais dos portos dos
  -- componentes onde serão usados.
  -- Veja os exemplos abaixo:
  
  
  -- sinais relativos ao pipeline de partes da instrucao
  --vermelho, segundo estagio do pipeline
  signal instruction_0_4_red : std_logic_vector(0 to 4); --campo de identificaçao da instrucao
  signal instruction_5_8_red : std_logic_vector(0 to 3); -- bits de 5 a 8 da instrucao: waddr1 ou addr1
  signal instruction_9_12_red : std_logic_vector(0 to 3); -- bits de 9 a 12 da instrucao: waddr2 ou addr2
  signal instruction_13_15_red : std_logic_vector(0 to 2); -- bits de 13 a 15 da instrucao: funct
  --verde, terceiro estagio do pipeline
  signal instruction_5_8_green : std_logic_vector(0 to 3); 
  signal instruction_9_12_green : std_logic_vector(0 to 3); 
  
  -- sinais relativos ao banco de registradores
  signal aux_addr_rd1 : std_logic_vector(0 to fr_addr_width - 1);
  signal aux_addr_rd2 : std_logic_vector(0 to fr_addr_width - 1);
  signal aux_addr_wd1 : std_logic_vector(0 to fr_addr_width - 1);
  signal aux_addr_wd2 : std_logic_vector(0 to fr_addr_width - 1);
  signal aux_data_rd1 : std_logic_vector(0 to data_width - 1);
  signal aux_data_rd2 : std_logic_vector(0 to data_width - 1);
  signal aux_data_wd1 : std_logic_vector(0 to data_width - 1);
  signal aux_data_wd2 : std_logic_vector(0 to data_width - 1);
  signal aux_ctrl_w1 : std_logic;
  signal aux_ctrl_w2 : std_logic;
  --vermelhos, segundo estágio do pipeline
  signal aux_ctrl_w1_red : std_logic;
  signal aux_ctrl_w2_red : std_logic;
  signal aux_data_rd1_red : std_logic_vector(0 to data_width - 1);
  signal aux_data_rd2_red : std_logic_vector(0 to data_width - 1);

 --verdes, terceiro estágio do pipeline
 signal aux_ctrl_w1_green : std_logic;
 signal aux_ctrl_w2_green : std_logic;
	
  -- sinais relativos a ULA
  signal aux_alu_in_A : std_logic_vector(0 to data_width - 1);
  signal aux_alu_in_B : std_logic_vector(0 to data_width - 1);
  signal aux_ula_ctrl : std_logic_vector(0 to ula_ctrl_width - 1);
  signal aux_ula_out_HI : std_logic_vector(0 to data_width - 1);
  signal aux_ula_out_LO : std_logic_vector(0 to data_width - 1);
  signal aux_flag_zero       : std_logic;
  --vermelhos, segundo estágio do pipeline
  signal aux_ula_ctrl_red : std_logic_vector(0 to ula_ctrl_width - 1);
  --verdes, terceiro estagio do pipeline
  signal aux_ula_out_HI_green : std_logic_vector(0 to data_width - 1);
  signal aux_ula_out_LO_green : std_logic_vector(0 to data_width - 1);

	
  --sinais relativos ao extensor com sinal
  signal aux_in_sign_ext : std_logic_vector(0 to 10);
  signal aux_signExt_out : std_logic_vector(0 to data_width - 1);
  signal aux_signExt_out_x2 : std_logic_vector(0 to data_width - 1);
  --vermelhos, segundo estagio do pipeline
  signal aux_signExt_out_red : std_logic_vector(0 to data_width - 1);

  --signal aux_funct : std_logic_vector(0 to 2);
  
  -- sinais relativos aos registradores de operacao
  signal aux_in_reg_A : std_logic_vector(0 to data_width - 1);
  signal aux_in_reg_B : std_logic_vector(0 to data_width - 1);
  signal aux_en_reg_A : std_logic;
  signal aux_en_reg_B : std_logic;
  
  -- sinal do mux logo antes dos regisradores A e B
  signal aux_sel_mux_rgbk_A  : std_logic;
  signal aux_sel_mux_rgbk_B  : std_logic;

  -- sinal dos mux de forwarding
  signal aux_sel_mux_for_A : std_logic_vector(1 downto 0);
  signal aux_sel_mux_for_B : std_logic_vector(1 downto 0);
  signal aux_out_mux_for_A : std_logic_vector(0 to data_width - 1);
  signal aux_out_mux_for_B : std_logic_vector(0 to data_width - 1);

  -- sinais ligados a memoria de dados
  signal aux_memd_out        : std_logic_vector(0 to data_width - 1);
  signal aux_in_mux_wa1      : std_logic_vector(0 to data_width - 1);
  signal aux_ctrl_memd_wd 	  : std_logic;
  --vermelhos, segundo estágio do pipeline
  signal aux_ctrl_memd_wd_red 	  : std_logic;
  --verdes, terceiro estagio do pipeline
  signal aux_memd_out_green : std_logic_vector(0 to data_width - 1);

  -- sinal utilizado para calcular o endereco no jump
  signal aux_rd2_plus_funct : std_logic_vector(0 to data_width - 1);

  -- sinais dos multiplexadores antes do banco de registradores
  signal aux_sel_mux_in_wa1  : std_logic;
  signal aux_sel_mux_in_wd1  : std_logic;
  signal aux_sel_mux_mem_alu : std_logic;
  signal aux_out_mux_mem_alu : std_logic_vector(0 to data_width - 1);
  --vermelhos, segundo estágio do pipeline
  signal aux_sel_mux_in_wa1_red  : std_logic;
  signal aux_sel_mux_in_wd1_red  : std_logic;
  signal aux_sel_mux_mem_alu_red : std_logic;
  --verdes, terceiro estágio do pipeline
  signal aux_sel_mux_in_wa1_green  : std_logic;
  signal aux_sel_mux_in_wd1_green  : std_logic;
  signal aux_sel_mux_mem_alu_green : std_logic;
  

  -- sinais para controle de branch e jump
  signal aux_branch : std_logic;
  signal aux_jump   : std_logic;
  --vermelhos, segundo estágio do pipeline
  signal aux_branch_red : std_logic;
  signal aux_jump_red : std_logic;

  -- sinais mux do MPC, mais à esquerda no deseho
  signal aux_out_mux_pc1      : std_logic_vector(0 to pc_width - 1); 
  signal aux_sel_mux_pc1 : std_logic;
  signal aux_branch_pc   : std_logic_vector(0 to pc_width - 1); -- PC+2 + Sign ext
  signal aux_rd1_plus_funct : std_logic_vector(0 to data_width - 1);
  --vermelhos, segundo estágio do pipeline
  signal aux_sel_mux_pc1_red : std_logic;
  
  -- sinais do mux logo antes do PC
  signal aux_sel_mux_pc2     : std_logic;
  signal aux_pc_plus     : std_logic_vector(0 to pc_width - 1);
  --vermelho, segundo estágio do pipeline
  signal aux_pc_plus_red     : std_logic_vector(0 to pc_width - 1);
  --verde, terceiro estágio do pipeline
  signal aux_pc_plus_green     : std_logic_vector(0 to pc_width - 1);
  

  -- sinais ligados ao PC
  signal aux_pc_out      : std_logic_vector(0 to pc_width - 1);
  signal aux_novo_pc     : std_logic_vector(0 to pc_width - 1);
  signal aux_we_pc       : std_logic;
  --vermlhos, segundo estágio do pipeline
  signal aux_we_pc_red       : std_logic;
  
  -- o compilador do modelsim recusou atribuição direta de entrada_b
  -- foi preciso criar sinais novos
  signal aux_entrada_b : std_logic_vector(15 downto 0);
  signal foo : std_logic_vector(0 to 11);

  --sinais relativos ao registrador vermelho de pipeline
  signal aux_in_ctrl_reg_red  : std_logic_vector(0 to 13);
  signal aux_out_ctrl_reg_red : std_logic_vector(0 to 13);
  signal aux_in_ctrl_reg_green  : std_logic_vector(0 to 4);
  signal aux_out_ctrl_reg_green : std_logic_vector(0 to 4);

  
  
  begin



  -- sinal criado para compilar no modelsim, pois nao pode colocar "000..." na instanciacao
  aux_entrada_b <=(("0000000000000") & instruction_13_15_red);
  
  
  -- A partir deste comentário faça associações necessárias das entradas declaradas na entidade da sua via_dados_ciclo_unico com
  -- os sinais que você acabou de definir.
  -- Veja os exemplos abaixo:
  aux_addr_rd1    <= instrucao(5 to 8);
  aux_addr_rd2    <= instrucao(9 to 12);
  aux_in_mux_wa1  <= x"000" & instruction_5_8_green; -- escreve somente no terceiro estagio verde de writeback
  aux_addr_wd2    <= instruction_9_12_green; -- usa smente no verde
  aux_in_sign_ext <= instrucao(5 to 15);
  --aux_funct       <= instrucao(13 to 15);
  

  --==================
  --SINAIS DE CONTROLE
  --==================

  -- UL UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData Jump Branch MPC PCW
  -- 0  1  2  3  4   5   6   7   8   9  10 11 12 13     14   15     16  17

  aux_ula_ctrl(0 to 3)       <= controle(0 to 3);
  aux_sel_mux_in_wa1             <= controle(4);
  aux_sel_mux_in_wd1             <= controle(5);
  aux_sel_mux_mem_alu            <= controle(6);   
  aux_ctrl_w1                    <= controle(7);   
  aux_ctrl_w2                    <= controle(8);   
  aux_en_reg_A                   <= controle(9);
  aux_en_reg_B                   <= controle(10);
  aux_sel_mux_rgbk_A             <= controle(11);
  aux_sel_mux_rgbk_B             <= controle(12);
  aux_ctrl_memd_wd               <= controle(13);
  aux_jump                       <= controle(14);
  aux_branch                     <= controle(15);
  aux_sel_mux_pc1                <= controle(16);
  aux_we_pc                      <= controle(17);
  aux_sel_mux_pc2                <= (aux_jump_red) OR ((aux_branch_red) AND (aux_flag_zero));

  -- registrador de pipeline vermelho, sinais de controle
  aux_in_ctrl_reg_red <= aux_ula_ctrl(0 to 3) & aux_sel_mux_in_wa1 & aux_sel_mux_in_wd1 & aux_sel_mux_mem_alu & aux_ctrl_w1 &
                         aux_ctrl_w2 & aux_ctrl_memd_wd & aux_jump & aux_branch & aux_sel_mux_pc1 & aux_we_pc;
  
  aux_ula_ctrl_red(0 to 3)  <= aux_out_ctrl_reg_red (0 to 3); 
  aux_sel_mux_in_wa1_red    <= aux_out_ctrl_reg_red (4);
  aux_sel_mux_in_wd1_red    <= aux_out_ctrl_reg_red (5);
  aux_sel_mux_mem_alu_red   <= aux_out_ctrl_reg_red (6);
  aux_ctrl_w1_red           <= aux_out_ctrl_reg_red (7);
  aux_ctrl_w2_red           <= aux_out_ctrl_reg_red (8);
  aux_ctrl_memd_wd_red      <= aux_out_ctrl_reg_red (9);
  aux_jump_red              <= aux_out_ctrl_reg_red (10);
  aux_branch_red            <= aux_out_ctrl_reg_red (11);
  aux_sel_mux_pc1_red       <= aux_out_ctrl_reg_red (12);
  aux_we_pc_red             <= aux_out_ctrl_reg_red (13);

  -- registrador de pipeline verde, sinais de controle
  aux_in_ctrl_reg_green <= aux_sel_mux_in_wa1_red & aux_sel_mux_in_wd1_red & aux_sel_mux_mem_alu_red & aux_ctrl_w1_red & aux_ctrl_w2_red;
  
  aux_sel_mux_in_wa1_green <= aux_out_ctrl_reg_green(0);
  aux_sel_mux_in_wd1_green <= aux_out_ctrl_reg_green(1);
  aux_sel_mux_mem_alu_green <= aux_out_ctrl_reg_green(2);
  aux_ctrl_w1_green <= aux_out_ctrl_reg_green(3); 
  aux_ctrl_w2_green <= aux_out_ctrl_reg_green(4);
  
  
   

  saida <= instrucao;
  pc_out <= aux_pc_out;

  -- A partir deste comentário instancie todos o componentes que serão usados na sua via_de_dados_ciclo_unico.
  -- A instanciação do componente deve começar com um nome que você deve atribuir para a referida instancia seguido de : e seguido do nome
  -- que você atribuiu ao componente.
  -- Depois segue o port map do referido componente instanciado.
  -- Para fazer o port map, na parte da esquerda da atribuição "=>" deverá vir o nome de origem da porta do componente e na parte direita da
  -- atribuição deve aparecer um dos sinais ("fios") que você definiu anteriormente, ou uma das entradas da entidade via_de_dados_ciclo_unico,
  -- ou ainda uma das saídas da entidade via_de_dados_ciclo_unico.
  -- Veja os exemplos de instanciação a seguir:

  
  aux_data_wd2 <= aux_ula_out_HI_green;

  instancia_ula1 : ula_mod
  port map(
    entrada_a => aux_alu_in_A,
    entrada_b => aux_alu_in_B,
    seletor => aux_ula_ctrl_red,
    saida_hi => aux_ula_out_HI,
    saida_lo => aux_ula_out_LO,
    flag_zero => aux_flag_zero
  );

  instancia_banco_registradores : banco_registradores_mod
  port map(
    clk => clock,
    WE1 => aux_ctrl_w1_green,
    WE2 => aux_ctrl_w2_green,
    ent_Rd1_ende => aux_addr_rd1,
    ent_Rd2_ende => aux_addr_rd2,
    ent_Wd1_ende => aux_addr_wd1,
    ent_Wd2_ende => aux_addr_wd2,
    sai_Rd1_dado => aux_data_rd1,
    sai_Rd2_dado => aux_data_rd2,
    ent_Wd1_dado => aux_data_wd1,
    ent_Wd2_dado => aux_data_wd2
  );

  data_mem : memd
  port map(
    clk => clock,
    mem_write => aux_ctrl_memd_wd_red,
    write_data_mem => aux_data_rd1_red,
    adress_mem => aux_rd2_plus_funct,
    read_data_mem => aux_memd_out
  );

  mux_rgbk_out_A : mux21
  port map(
    dado_ent_0 => aux_out_mux_for_A,
    dado_ent_1 => aux_signExt_out,
    sele_ent => aux_sel_mux_rgbk_A,
    dado_sai => aux_in_reg_A
  );

  mux_rgbk_out_B : mux21
  port map(
    dado_ent_0 => aux_out_mux_for_B,
    dado_ent_1 => aux_signExt_out,
    sele_ent => aux_sel_mux_rgbk_B,
    dado_sai => aux_in_reg_B
  );

  mux_in_wd1 : mux21
  port map(
    dado_ent_0 => aux_pc_plus_green,
    dado_ent_1 => aux_out_mux_mem_alu,
    sele_ent => aux_sel_mux_in_wd1_green,
    dado_sai => aux_data_wd1
  );

  mux_in_wa1 : mux21
  port map(
    dado_ent_0 => aux_in_mux_wa1,
    dado_ent_1 => (x"000F"), -- endereço para registrador de $ja
    sele_ent => aux_sel_mux_in_wa1_green,
    dado_sai(12 to 15) => aux_addr_wd1,
    dado_sai(0 to 11) => foo
  );

  mux_mem_alu : mux21
  port map(
    dado_ent_0 => aux_memd_out_green,
    dado_ent_1 => aux_ula_out_LO_green,
    sele_ent => aux_sel_mux_mem_alu_green,
    dado_sai => aux_out_mux_mem_alu
  );

  reg_A : registrador
  port map(
    clk => clock,
    reset => reset,
    WE => aux_en_reg_A,
    entrada_dados => aux_in_reg_A,
    saida_dados => aux_alu_in_A
  );

  reg_B : registrador
  port map(
    clk => clock,
    reset => reset,
    WE => aux_en_reg_B,
    entrada_dados => aux_in_reg_B,
    saida_dados => aux_alu_in_B
  );

  instancia_pc : pc
  port map(
    entrada => aux_novo_pc,
    saida => aux_pc_out,
    clk => clock,
    we => aux_we_pc_red,
    reset => reset
  );

  extensor1 : extensor
  port map(
    entrada_Rs => aux_in_sign_ext,
    saida => aux_signExt_out
  );

  instancia_somador_plus2 : somador
  port map(
    entrada_a => aux_pc_out,
    entrada_b => (x"0002"),
    saida => aux_pc_plus
  );
  
  instancia_barrel_shift : barrel_shift_x2 -- desloca 1 bit pois pc endereça cada byte
  port map(
		entrada => aux_signExt_out_red,
		saida => aux_signExt_out_x2
	);

  instancia_somador_imediate : somador
  port map(
    entrada_a => aux_pc_plus_red,
    entrada_b => aux_signExt_out_x2, 
    saida => aux_branch_pc
  );

  mux_pc1 : mux21
  port map(
    dado_ent_0 => aux_rd1_plus_funct,
    dado_ent_1 => aux_branch_pc,
    sele_ent => aux_sel_mux_pc1_red,
    dado_sai => aux_out_mux_pc1
  );

  mux_pc2 : mux21
  port map(
    dado_ent_0 => aux_pc_plus,
    dado_ent_1 => aux_out_mux_pc1,
    sele_ent => aux_sel_mux_pc2,
    dado_sai => aux_novo_pc
  );

  instancia_somador_funct_rd1 : somador
  port map(
    entrada_a => aux_data_rd1_red,
    entrada_b => aux_entrada_b,
    saida => aux_rd1_plus_funct
  );
  
  

  instancia_somador_funct_rd2 : somador
  port map(
    entrada_a => aux_data_rd2_red,
    entrada_b => aux_entrada_b,
    saida => aux_rd2_plus_funct
  );

  --=========================
  --Registradores de PIPELINE
  --=========================

  reg_controle_red : registrador
  generic map (largura_dado => 14)
  port map(
    clk => clock,
    reset => reset,
    WE => '1', --registrador vai estar sempre operando, para fazer stall tem que usar os sinais de controle
    entrada_dados => aux_in_ctrl_reg_red,
    saida_dados => aux_out_ctrl_reg_red
  );

  reg_RD1_red : registrador
  generic map (largura_dado => data_width)
  port map(
    clk => clock,
    reset => reset,
    WE => '1', --registrador vai estar sempre operando, para fazer stall tem que usar os sinais de controle
    entrada_dados => aux_data_rd1,
    saida_dados => aux_data_rd1_red
  );

  reg_RD2_red : registrador
  generic map (largura_dado => data_width)
  port map(
    clk => clock,
    reset => reset,
    WE => '1', --registrador vai estar sempre operando, para fazer stall tem que usar os sinais de controle
    entrada_dados => aux_data_rd2,
    saida_dados => aux_data_rd2_red
  );

  reg_inst_0_4_red : registrador
  generic map (largura_dado => 5)
  port map(
    clk => clock,
    reset => reset,
    WE => '1', --registrador vai estar sempre operando, para fazer stall tem que usar os sinais de controle
    entrada_dados => instrucao(0 to 4),
    saida_dados => instruction_0_4_red
  );  
  
  
  reg_inst_5_8_red : registrador
  generic map (largura_dado => fr_addr_width)
  port map(
    clk => clock,
    reset => reset,
    WE => '1', --registrador vai estar sempre operando, para fazer stall tem que usar os sinais de controle
    entrada_dados => instrucao(5 to 8),
    saida_dados => instruction_5_8_red
  );

  reg_inst_9_12_red : registrador
  generic map (largura_dado => fr_addr_width)
  port map(
    clk => clock,
    reset => reset,
    WE => '1', --registrador vai estar sempre operando, para fazer stall tem que usar os sinais de controle
    entrada_dados => instrucao(9 to 12),
    saida_dados => instruction_9_12_red
  );

  reg_inst_13_15_red : registrador
  generic map (largura_dado => 3)
  port map(
    clk => clock,
    reset => reset,
    WE => '1', --registrador vai estar sempre operando, para fazer stall tem que usar os sinais de controle
    entrada_dados => instrucao(13 to 15), -- funct
    saida_dados => instruction_13_15_red
  );

  reg_sig_ext_red : registrador
  generic map (largura_dado => data_width)
  port map(
    clk => clock,
    reset => reset,
    WE => '1', --registrador vai estar sempre operando, para fazer stall tem que usar os sinais de controle
    entrada_dados => aux_signExt_out,
    saida_dados => aux_signExt_out_red
  );

  reg_pc_plus_red : registrador
  generic map (largura_dado => pc_width)
  port map(
    clk => clock,
    reset => reset,
    WE => '1', --registrador vai estar sempre operando, para fazer stall tem que usar os sinais de controle
    entrada_dados => aux_pc_plus,
    saida_dados => aux_pc_plus_red
  );

  reg_controle_green : registrador
  generic map (largura_dado => 5)
  port map(
    clk => clock,
    reset => reset,
    WE => '1', --registrador vai estar sempre operando, para fazer stall tem que usar os sinais de controle
    entrada_dados => aux_in_ctrl_reg_green,
    saida_dados => aux_out_ctrl_reg_green
  );

  reg_memd_green : registrador
  generic map (largura_dado => data_width)
  port map(
    clk => clock,
    reset => reset,
    WE => '1', --registrador vai estar sempre operando, para fazer stall tem que usar os sinais de controle
    entrada_dados => aux_memd_out,
    saida_dados => aux_memd_out_green
  );

  reg_alu_LO_green : registrador
  generic map (largura_dado => data_width)
  port map(
    clk => clock,
    reset => reset,
    WE => '1', --registrador vai estar sempre operando, para fazer stall tem que usar os sinais de controle
    entrada_dados => aux_ula_out_LO,
    saida_dados => aux_ula_out_LO_green
  );

  reg_alu_HI_green : registrador
  generic map (largura_dado => data_width)
  port map(
    clk => clock,
    reset => reset,
    WE => '1', --registrador vai estar sempre operando, para fazer stall tem que usar os sinais de controle
    entrada_dados => aux_ula_out_HI,
    saida_dados => aux_ula_out_HI_green
  );

  reg_inst_5_8_green : registrador
  generic map (largura_dado => fr_addr_width)
  port map(
    clk => clock,
    reset => reset,
    WE => '1', --registrador vai estar sempre operando, para fazer stall tem que usar os sinais de controle
    entrada_dados => instruction_5_8_red,
    saida_dados => instruction_5_8_green
  );

  reg_inst_9_12_green : registrador
  generic map (largura_dado => fr_addr_width)
  port map(
    clk => clock,
    reset => reset,
    WE => '1', --registrador vai estar sempre operando, para fazer stall tem que usar os sinais de controle
    entrada_dados => instruction_9_12_red,
    saida_dados => instruction_9_12_green
  );

  reg_pc_plus_green : registrador
  generic map (largura_dado => pc_width)
  port map(
    clk => clock,
    reset => reset,
    WE => '1', --registrador vai estar sempre operando, para fazer stall tem que usar os sinais de controle
    entrada_dados => aux_pc_plus_red,
    saida_dados => aux_pc_plus_green
  );
  --=================
  --MUX DE FORWARDING
  --=================

  mux_for_A: mux41
    generic map (largura_dado => data_width)
    port map(dado_ent_0 => aux_data_rd1,
             dado_ent_1 => aux_ula_out_HI,
             dado_ent_2 => aux_ula_out_LO,
             dado_ent_3 => aux_memd_out,
             sele_ent   => aux_sel_mux_for_A,
             dado_sai   => aux_out_mux_for_A

            );

  mux_for_B: mux41
  generic map (largura_dado => data_width)
  port map(dado_ent_0 => aux_data_rd2,
            dado_ent_1 => aux_ula_out_HI,
            dado_ent_2 => aux_ula_out_LO,
            dado_ent_3 => aux_memd_out,
            sele_ent   => aux_sel_mux_for_B,
            dado_sai   => aux_out_mux_for_B

          );
--===============
--FORWARDING UNIT
--===============
    for_unit: forwarding_unit
    port map( instruction_0_4_red   =>  instruction_0_4_red,  
              instruction_5_8       =>  instrucao(5 to 8),      
              instruction_9_12      =>  instrucao(9 to 12),     
              instruction_5_8_red   =>  instruction_5_8_red,  
              instruction_9_12_red  =>  instruction_9_12_red, 
              aux_sel_mux_for_A     =>  aux_sel_mux_for_A,      
              aux_sel_mux_for_B     =>  aux_sel_mux_for_B    
    );
end architecture comportamento;
