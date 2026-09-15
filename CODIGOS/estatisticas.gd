extends Node


# =========================================================
# ESTATÍSTICAS DA TENTATIVA ATUAL
# =========================================================

var tempo_gasto := 0.0
var dashs := 0
var flechas := 0
var inimigos := 0

# Quantidade total de tentativas feitas desde o início
# da sequência daquela fase.
var tentativas := 0


# =========================================================
# CONTROLE DO TEMPO
# =========================================================

var tempo_contando := false
var momento_inicio := 0
var tempo_finalizado := 0.0


# =========================================================
# INICIAR NOVA TENTATIVA
# =========================================================

func iniciar_tentativa() -> void:
	# A tentativa anterior terminou.
	# Começa uma nova sem apagar o número de tentativas.
	tentativas += 1

	# Estatísticas da nova tentativa começam do zero.
	tempo_gasto = 0.0
	dashs = 0
	flechas = 0
	inimigos = 0

	tempo_contando = false
	momento_inicio = 0
	tempo_finalizado = 0.0


# =========================================================
# INICIAR CONTAGEM DO TEMPO
# =========================================================

func iniciar_tempo() -> void:
	momento_inicio = Time.get_ticks_msec()
	tempo_contando = true
	tempo_finalizado = 0.0


# =========================================================
# FINALIZAR TENTATIVA
# =========================================================

func finalizar_tentativa() -> void:
	if not tempo_contando:
		return

	var agora := Time.get_ticks_msec()

	tempo_gasto = float(agora - momento_inicio) / 1000.0
	tempo_finalizado = tempo_gasto

	tempo_contando = false


# =========================================================
# DASH
# =========================================================

func registrar_dash() -> void:
	dashs += 1


# =========================================================
# FLECHA
# =========================================================

func registrar_flecha() -> void:
	flechas += 1


# =========================================================
# INIMIGO
# =========================================================

func registrar_inimigo() -> void:
	inimigos += 1


# =========================================================
# FINALIZAR FASE COM VITÓRIA
# =========================================================

func finalizar_fase() -> void:
	if tempo_contando:
		finalizar_tentativa()


# =========================================================
# FINALIZAR FASE COM DERROTA
# =========================================================

func finalizar_derrota() -> void:
	if tempo_contando:
		finalizar_tentativa()


# =========================================================
# OBTER TEMPO
# =========================================================

func obter_tempo_gasto() -> float:
	if tempo_contando:
		var agora := Time.get_ticks_msec()
		return float(agora - momento_inicio) / 1000.0

	return tempo_gasto


# =========================================================
# TEMPO FORMATADO
# =========================================================

func obter_tempo_formatado() -> String:
	var segundos_totais: int = int(round(obter_tempo_gasto()))

	var minutos: int = segundos_totais / 60
	var segundos: int = segundos_totais % 60

	return "%02d:%02d" % [minutos, segundos]


# =========================================================
# OBTER DASHs
# =========================================================

func obter_dashs() -> int:
	return dashs


# =========================================================
# OBTER FLECHAS
# =========================================================

func obter_flechas() -> int:
	return flechas


# =========================================================
# OBTER INIMIGOS
# =========================================================

func obter_inimigos() -> int:
	return inimigos


# =========================================================
# OBTER TENTATIVAS
# =========================================================

func obter_tentativa() -> int:
	return tentativas


# =========================================================
# ZERAR TENTATIVAS
# =========================================================

func reiniciar_contador_tentativas() -> void:
	tentativas = 0
