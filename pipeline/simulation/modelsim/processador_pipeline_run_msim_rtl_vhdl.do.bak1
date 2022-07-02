transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/Gabriel/Documents/GitHub/LAOC/pipeline/banco_registradores_mod.vhd}
vcom -93 -work work {C:/Users/Gabriel/Documents/GitHub/LAOC/pipeline/via_de_dados_ciclo_unico.vhd}
vcom -93 -work work {C:/Users/Gabriel/Documents/GitHub/LAOC/pipeline/unidade_de_controle_ciclo_unico.vhd}
vcom -93 -work work {C:/Users/Gabriel/Documents/GitHub/LAOC/pipeline/ula_mod.vhd}
vcom -93 -work work {C:/Users/Gabriel/Documents/GitHub/LAOC/pipeline/to_7seg.vhd}
vcom -93 -work work {C:/Users/Gabriel/Documents/GitHub/LAOC/pipeline/somador.vhd}
vcom -93 -work work {C:/Users/Gabriel/Documents/GitHub/LAOC/pipeline/registrador.vhd}
vcom -93 -work work {C:/Users/Gabriel/Documents/GitHub/LAOC/pipeline/processador_ciclo_unico.vhd}
vcom -93 -work work {C:/Users/Gabriel/Documents/GitHub/LAOC/pipeline/pc.vhd}
vcom -93 -work work {C:/Users/Gabriel/Documents/GitHub/LAOC/pipeline/mux21.vhd}
vcom -93 -work work {C:/Users/Gabriel/Documents/GitHub/LAOC/pipeline/memi.vhd}
vcom -93 -work work {C:/Users/Gabriel/Documents/GitHub/LAOC/pipeline/memd.vhd}
vcom -93 -work work {C:/Users/Gabriel/Documents/GitHub/LAOC/pipeline/extensor.vhd}
vcom -93 -work work {C:/Users/Gabriel/Documents/GitHub/LAOC/pipeline/digi_clk.vhd}
vcom -93 -work work {C:/Users/Gabriel/Documents/GitHub/LAOC/pipeline/barrel_shift_x2.vhd}

vcom -93 -work work {C:/Users/Gabriel/Documents/GitHub/LAOC/pipeline/tb_processador_ciclo_unico.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L fiftyfivenm -L rtl_work -L work -voptargs="+acc"  tb_processador_ciclo_unico

add wave *
view structure
view signals
run -all
