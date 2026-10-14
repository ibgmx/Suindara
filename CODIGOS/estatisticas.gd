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

# Tempo acumulado antes da contagem atual.
var tempo_acumulado := 0.0

# Controle da pausa.
var tempo_pausado := false
var momento_inicio_pausa := 0


# =========================================================
# INICIAR NOVA TENTATIVA
# =========================================================

func iniciar_tentativa() -> void:
	tentativas += 1

	tempo_gasto = 0.0
	dashs = 0
	flechas = 0
	inimigos = 0

	tempo_contando = false
	momento_inicio = 0
	tempo_finalizado = 0.0
	tempo_acumulado = 0.0

	tempo_pausado = false
	momento_inicio_pausa = 0


# =========================================================
# INICIAR CONTAGEM DO TEMPO
# =========================================================

func iniciar_tempo() -> void:
	tempo_acumulado = 0.0
	tempo_gasto = 0.0
	tempo_finalizado = 0.0

	momento_inicio = Time.get_ticks_msec()
	tempo_contando = true

	tempo_pausado = false
	momento_inicio_pausa = 0


# =========================================================
# PAUSAR CONTAGEM DAS ESTATÍSTICAS
# =========================================================

func pausar_tempo() -> void:
	if not tempo_contando or tempo_pausado:
		return

	var agora := Time.get_ticks_msec()

	tempo_acumulado += float(agora - momento_inicio) / 1000.0
	tempo_pausado = true
	momento_inicio_pausa = agora


# =========================================================
# RETOMAR CONTAGEM DAS ESTATÍSTICAS
# =========================================================

func retomar_tempo() -> void:
	if not tempo_contando or not tempo_pausado:
		return

	momento_inicio = Time.get_ticks_msec()
	tempo_pausado = false
	momento_inicio_pausa = 0


# =========================================================
# FINALIZAR TENTATIVA
# =========================================================

func finalizar_tentativa() -> void:
	if not tempo_contando:
		return

	if not tempo_pausado:
		var agora := Time.get_ticks_msec()
		tempo_acumulado += float(agora - momento_inicio) / 1000.0

	tempo_gasto = tempo_acumulado
	tempo_finalizado = tempo_gasto
	tempo_contando = false
	tempo_pausado = false


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
	if not tempo_contando:
		return tempo_gasto

	if tempo_pausado:
		return tempo_acumulado

	var agora := Time.get_ticks_msec()
	var tempo_atual := float(agora - momento_inicio) / 1000.0

	return tempo_acumulado + tempo_atual


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
