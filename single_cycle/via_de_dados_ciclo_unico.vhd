-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Via de dados do processador_ciclo_unico

library IEEE;
use IEEE.std_logic_1164.all;

entity via_de_dados_ciclo_unico is
  generic (
    -- declare todos os tamanhos dos barramentos (sinais) das portas da sua via_dados_ciclo_unico aqui.
    dp_ctrl_bus_width : natural := 17; -- tamanho do barramento de controle da via de dados (DP) em bits
    data_width : natural := 16; -- tamanho do dado em bits
    pc_width : natural := 16; -- tamanho da entrada de endereços da MI ou MP em bits (memi.vhd)
    fr_addr_width : natural := 4; -- tamanho da linha de endereços do banco de registradores em bits
    ula_ctrl_width : natural := 3; -- tamanho da linha de controle da ULA
    instr_width : natural := 16 -- tamanho da instrução em bits
  );
  port (
    -- declare todas as portas da sua via_dados_ciclo_unico aqui.
    clock : in std_logic;
    reset : in std_logic;
    controle : in std_logic_vector(dp_ctrl_bus_width - 1 downto 0);
    instrucao : in std_logic_vector(instr_width - 1 downto 0);
    pc_out : out std_logic_vector(pc_width - 1 downto 0);
    saida : out std_logic_vector(data_width - 1 downto 0)
  );
end entity via_de_dados_ciclo_unico;

architecture comportamento of via_de_dados_ciclo_unico is

  -- declare todos os componentes que serão necessários na sua via_de_dados_ciclo_unico a partir deste comentário
  component pc is
    generic (
      pc_width : natural := 16
    );
    port (
      entrada : in std_logic_vector(pc_width - 1 downto 0);
      saida : out std_logic_vector(pc_width - 1 downto 0);
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
      entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
      entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
      saida : out std_logic_vector((largura_dado - 1) downto 0)
    );
  end component;

  component banco_registradores_mod is
    generic (
      largura_dado : natural := 16;
      largura_ende : natural := 4
    );
    port (
      ent_Rd1_ende : in std_logic_vector((largura_ende - 1) downto 0);
      ent_Rd2_ende : in std_logic_vector((largura_ende - 1) downto 0);
      ent_Wd1_ende : in std_logic_vector((largura_ende - 1) downto 0);
      ent_Wd2_ende : in std_logic_vector((largura_ende - 1) downto 0);
      ent_Wd1_dado : in std_logic_vector((largura_dado - 1) downto 0);
      ent_Wd2_dado : in std_logic_vector((largura_dado - 1) downto 0);
      sai_Rd1_dado : out std_logic_vector((largura_dado - 1) downto 0);
      sai_Rd2_dado : out std_logic_vector((largura_dado - 1) downto 0);
      clk : in std_logic;
      We1, We2 : in std_logic
    );
  end component;

  component memd is
    port (
      clk : in std_logic;
      mem_write, mem_read : in std_logic;
      write_data_mem : in std_logic_vector(data_width - 1 downto 0);
      adress_mem : in std_logic_vector(instr_width - 1 downto 0);
      read_data_mem : out std_logic_vector(data_width - 1 downto 0)
    );
  end component;

  component ula_mod is
    generic (
      largura_dado : natural := 16
    );
    port (
      entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
      entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
      seletor : in std_logic_vector(2 downto 0);
      saida_hi : out std_logic_vector((largura_dado - 1) downto 0);
      saida_lo : out std_logic_vector((largura_dado - 1) downto 0)
    );
  end component;

  component mux21 is
    port (
      dado_ent_0, dado_ent_1 : in std_logic_vector(15 downto 0);
      sele_ent : in std_logic;
      dado_sai : out std_logic_vector(15 downto 0)
    );
  end component;

  component mux41 is
    generic (
      largura_dado : natural := 16
    );
    port (
      dado_ent_0, dado_ent_1, dado_ent_2, dado_ent_3 : in std_logic_vector((largura_dado - 1) downto 0);
      sele_ent : in std_logic_vector(1 downto 0);
      dado_sai : out std_logic_vector((largura_dado - 1) downto 0)
    );
  end component;

  component registrador is
    port (
      entrada_dados : in std_logic_vector(15 downto 0);
      WE, clk, reset : in std_logic;
      saida_dados : out std_logic_vector(15 downto 0)
    );
  end component;

  component extender is
    port (
      entrada_Rs : in std_logic_vector(10 downto 0);
      saida : out std_logic_vector((data_width - 1) downto 0)
    );
  end component;

  -- Declare todos os sinais auxiliares que serão necessários na sua via_de_dados_ciclo_unico a partir deste comentário.
  -- Você só deve declarar sinais auxiliares se estes forem usados como "fios" para interligar componentes.
  -- Os sinais auxiliares devem ser compatíveis com o mesmo tipo (std_logic, std_logic_vector, etc.) e o mesmo tamanho dos sinais dos portos dos
  -- componentes onde serão usados.
  -- Veja os exemplos abaixo:
  signal aux_addr_rd1 : std_logic_vector(fr_addr_width - 1 downto 0);
  signal aux_addr_rd2 : std_logic_vector(fr_addr_width - 1 downto 0);
  signal aux_addr_wd1 : std_logic_vector(fr_addr_width - 1 downto 0);
  signal aux_addr_wd2 : std_logic_vector(fr_addr_width - 1 downto 0);
  signal aux_data_rd1 : std_logic_vector(data_width - 1 downto 0);
  signal aux_data_rd2 : std_logic_vector(data_width - 1 downto 0);
  signal aux_data_wd1 : std_logic_vector(data_width - 1 downto 0);
  signal aux_data_wd2 : std_logic_vector(data_width - 1 downto 0);
  signal aux_crtl_w1 : std_logic;
  signal aux_crtl_w2 : std_logic;

  signal aux_alu_in_A : std_logic_vector(data_width - 1 downto 0);
  signal aux_alu_in_B : std_logic_vector(data_width - 1 downto 0);
  signal aux_ula_ctrl : std_logic_vector(ula_ctrl_width - 1 downto 0);
  signal aux_ula_out_HI : std_logic_vector(data_width - 1 downto 0);
  signal aux_ula_out_LO : std_logic_vector(data_width - 1 downto 0);

  signal aux_in_sign_ext : std_logic_vector(10 downto 0);
  signal aux_signExt_out : std_logic_vector(data_width - 1 downto 0);

  signal aux_funct : std_logic_vector(2 downto 0);

  signal aux_in_reg_A : std_logic_vector(data_width - 1 downto 0);
  signal aux_in_reg_B : std_logic_vector(data_width - 1 downto 0);
  signal aux_en_reg_A : std_logic;
  signal aux_en_reg_B : std_logic;

  signal aux_memd_out        : std_logic_vector(data_width - 1 downto 0);
  signal aux_out_mux_mem_alu : std_logic_vector(data_width - 1 downto 0);
  signal aux_in_mux_wa1      : std_logic_vector(data_width - 1 downto 0);

  signal aux_sel_mux_rgbk_A : std_logic;
  signal aux_sel_mux_rgbk_B : std_logic;

  signal aux_sel_mux_in_wa1 : std_logic;
  signal aux_sel_mux_in_wd1 : std_logic;
  signal aux_sel_mux_mem_alu : std_logic;

  signal aux_crtl_memd_wd : std_logic;
  signal aux_crtl_memd_rd : std_logic;

  signal aux_pc_out : std_logic_vector(pc_width - 1 downto 0);
  signal aux_novo_pc : std_logic_vector(pc_width - 1 downto 0);
  signal aux_pc_plus : std_logic_vector(pc_width - 1 downto 0);
  signal aux_we_pc : std_logic;
  signal aux_branch_pc : std_logic_vector(pc_width - 1 downto 0);
  signal aux_sel_mux_new_pc : std_logic_vector(1 downto 0);

  signal aux_rd1_plus_funct : std_logic_vector(data_width - 1 downto 0);

  signal foo : std_logic_vector(11 downto 0);

begin

  -- A partir deste comentário faça associações necessárias das entradas declaradas na entidade da sua via_dados_ciclo_unico com
  -- os sinais que você acabou de definir.
  -- Veja os exemplos abaixo:
  aux_addr_rd1    <= instrucao(8 downto 5);
  aux_addr_rd2    <= instrucao(12 downto 9);
  aux_in_mux_wa1  <= x"000" & instrucao(8 downto 5);
  aux_addr_wd2    <= instrucao(12 downto 9);
  aux_in_sign_ext <= instrucao(15 downto 5);
  aux_funct       <= instrucao(15 downto 13);

  -- UL UL UL MA1 MD1 MLM WE1 WE2 RA RB MA MB WEData RDData MPC MPC PCW
  -- 0  1  2  3   4   5   6   7   8  9  10 11 12     13     14  15  16

  aux_ula_ctrl(2 downto 0)       <= controle(2 downto 0);
  aux_sel_mux_in_wa1             <= controle(3);
  aux_sel_mux_in_wd1             <= controle(4);
  aux_sel_mux_mem_alu            <= controle(5);   
  aux_crtl_w1                    <= controle(6);   
  aux_crtl_w2                    <= controle(7);   
  aux_en_reg_A                   <= controle(8);
  aux_en_reg_B                   <= controle(9);
  aux_sel_mux_rgbk_A             <= controle(10);
  aux_sel_mux_rgbk_B             <= controle(11);
  aux_crtl_memd_wd               <= controle(12);
  aux_crtl_memd_rd               <= controle(13);
  aux_sel_mux_new_pc(1 downto 0) <= controle(15 downto 14);
  aux_we_pc                      <= controle(16);

  saida <= aux_data_rd1;
  pc_out <= aux_pc_out;

  -- A partir deste comentário instancie todos o componentes que serão usados na sua via_de_dados_ciclo_unico.
  -- A instanciação do componente deve começar com um nome que você deve atribuir para a referida instancia seguido de : e seguido do nome
  -- que você atribuiu ao componente.
  -- Depois segue o port map do referido componente instanciado.
  -- Para fazer o port map, na parte da esquerda da atribuição "=>" deverá vir o nome de origem da porta do componente e na parte direita da
  -- atribuição deve aparecer um dos sinais ("fios") que você definiu anteriormente, ou uma das entradas da entidade via_de_dados_ciclo_unico,
  -- ou ainda uma das saídas da entidade via_de_dados_ciclo_unico.
  -- Veja os exemplos de instanciação a seguir:

  aux_data_wd2 <= aux_ula_out_HI;

  instancia_ula1 : ula_mod
  port map(
    entrada_a => aux_alu_in_A,
    entrada_b => aux_alu_in_B,
    seletor => aux_ula_ctrl,
    saida_hi => aux_ula_out_HI,
    saida_lo => aux_ula_out_LO
  );

  instancia_banco_registradores : banco_registradores_mod
  port map(
    clk => clock,
    WE1 => aux_crtl_w1,
    WE2 => aux_crtl_w2,
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
    mem_write => aux_crtl_memd_wd,
    mem_read => aux_crtl_memd_rd,
    write_data_mem => aux_data_rd1,
    adress_mem => aux_data_rd2,
    read_data_mem => aux_memd_out
  );

  mux_rgbk_out_A : mux21
  port map(
    dado_ent_0 => aux_data_rd1,
    dado_ent_1 => aux_signExt_out,
    sele_ent => aux_sel_mux_rgbk_A,
    dado_sai => aux_in_reg_A
  );

  mux_rgbk_out_B : mux21
  port map(
    dado_ent_0 => aux_data_rd2,
    dado_ent_1 => aux_signExt_out,
    sele_ent => aux_sel_mux_rgbk_B,
    dado_sai => aux_in_reg_B
  );

  mux_in_wd1 : mux21
  port map(
    dado_ent_0 => aux_pc_plus,
    dado_ent_1 => aux_out_mux_mem_alu,
    sele_ent => aux_sel_mux_in_wd1,
    dado_sai => aux_data_wd1
  );

  mux_in_wa1 : mux21
  port map(
    dado_ent_0 => aux_in_mux_wa1,
    dado_ent_1 => (x"000F"), -- endereço para registrador de $ja
    sele_ent => aux_sel_mux_in_wa1,
    dado_sai(3 downto 0) => aux_addr_wd1,
    dado_sai(15 downto 4) => foo
  );

  mux_mem_alu : mux21
  port map(
    dado_ent_0 => aux_memd_out,
    dado_ent_1 => aux_ula_out_LO,
    sele_ent => aux_sel_mux_mem_alu,
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
    we => aux_we_pc,
    reset => reset
  );

  extensor1 : extender
  port map(
    entrada_Rs => aux_in_sign_ext,
    saida => aux_signExt_out
  );

  instancia_somador_plus2 : somador
  port map(
    entrada_a => aux_pc_out,
    entrada_b => aux_signExt_out,
    saida => aux_pc_plus
  );

  instancia_somador_branch : somador
  port map(
    entrada_a => aux_pc_plus,
    entrada_b => (x"0002"),
    saida => aux_branch_pc
  );

  mux_new_pc : mux41
  port map(
    dado_ent_0 => aux_pc_plus,
    dado_ent_1 => aux_branch_pc,
    dado_ent_2 => aux_data_rd1,
    dado_ent_3 => aux_rd1_plus_funct,
    sele_ent => aux_sel_mux_new_pc,
    dado_sai => aux_novo_pc
  );

  instancia_somador_funct : somador
  port map(
    entrada_a => aux_data_rd1,
    entrada_b => (("0000000000000") & instrucao(15 downto 13)),
    saida => aux_rd1_plus_funct
  );
end architecture comportamento;
