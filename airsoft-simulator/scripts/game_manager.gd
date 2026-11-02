extends Node
class_name GameManager

signal aguardando_inicio
signal etapa_iniciada(indice: int, total: int)
signal etapa_concluida(indice: int)
signal tempo_alterado(restante: float)
signal tempo_total_alterado(tempo_total: float)
signal jogo_vencido(tempo_total: float)
signal jogo_perdido(motivo: String, tempo_total: float)

@export var etapas: Array[EtapaConfig] = []
@export var ponto_central: Node3D  # um Marker3D no meio do campo, apontando pra onde os alvos devem aparecer
@export var alvo_scene: PackedScene
@export var arma_path: NodePath
## Se ligado, o jogo espera o jogador apertar ESPAÇO antes de começar.
@export var esperar_inicio: bool = true

@export_category("Áudio")
## Som tocado sempre que um alvo é atingido e some.
@export var som_acerto: AudioStream
@export var volume_acerto_db: float = -4.0

var _audio_acerto: AudioStreamPlayer

var arma: AirsoftGun

var etapa_atual: int = -1
var alvos_restantes: int = 0
var tempo_restante: float = 0.0
var tempo_total: float = 0.0
var jogo_ativo: bool = false
var _alvos_ativos: Array[Alvo] = []


func _ready() -> void:
	_audio_acerto = AudioStreamPlayer.new()
	_audio_acerto.max_polyphony = 4 # acertos seguidos não cortam um ao outro
	_audio_acerto.volume_db = volume_acerto_db
	add_child(_audio_acerto)
	if arma_path != NodePath():
		arma = get_node(arma_path) as AirsoftGun
	if esperar_inicio:
		call_deferred("_aguardar_inicio")
	else:
		call_deferred("iniciar_jogo")


## Deixa o jogo parado (sem alvos, sem tempo, arma travada) até o jogador começar.
## É chamado em deferred para o PainelJogo já estar conectado ao sinal.
func _aguardar_inicio() -> void:
	jogo_ativo = false
	_parar_arma()
	aguardando_inicio.emit()


## Chamado pelo PainelJogo quando o jogador aperta ESPAÇO na tela inicial.
func comecar_jogo() -> void:
	reiniciar_jogo()


func iniciar_jogo() -> void:
	jogo_ativo = true
	tempo_total = 0.0
	etapa_atual = -1
	_avancar_etapa()


## Chamado pelo PainelJogo quando o jogador pede pra jogar de novo depois do fim.
func reiniciar_jogo() -> void:
	_limpar_alvos()
	if arma:
		arma.set_process(true)
		arma.set_process_unhandled_input(true)
	iniciar_jogo()


func _avancar_etapa() -> void:
	etapa_atual += 1
	if etapa_atual >= etapas.size():
		_vencer()
		return
	_spawnar_etapa(etapas[etapa_atual])
	etapa_iniciada.emit(etapa_atual, etapas.size())


func _limpar_alvos() -> void:
	for alvo in _alvos_ativos:
		if is_instance_valid(alvo):
			alvo.queue_free()
	_alvos_ativos.clear()


func _spawnar_etapa(config: EtapaConfig) -> void:
	_limpar_alvos()
	alvos_restantes = config.quantidade_alvos
	tempo_restante = config.tempo_limite_seg

	var origem = ponto_central.global_position
	var frente = -ponto_central.global_transform.basis.z
	var direita = ponto_central.global_transform.basis.x

	for i in config.quantidade_alvos:
		var angulo_graus = randf_range(-config.dispersao_angular_graus, config.dispersao_angular_graus)
		var angulo_rad = deg_to_rad(angulo_graus)
		var direcao = (frente * cos(angulo_rad) + direita * sin(angulo_rad)).normalized()

		var alvo: Alvo = alvo_scene.instantiate()
		get_tree().current_scene.add_child(alvo)
		alvo.global_position = origem + direcao * config.distancia
		alvo.scale = Vector3.ONE * config.escala_alvo
		alvo.atingido.connect(_on_alvo_atingido)
		_alvos_ativos.append(alvo)


func _on_alvo_atingido(alvo: Alvo) -> void:
	if som_acerto:
		_audio_acerto.stream = som_acerto
		_audio_acerto.play()
	_alvos_ativos.erase(alvo)
	alvos_restantes -= 1
	if alvos_restantes <= 0:
		etapa_concluida.emit(etapa_atual)
		_avancar_etapa()


func _process(delta: float) -> void:
	if not jogo_ativo:
		return

	tempo_total += delta
	tempo_total_alterado.emit(tempo_total)

	if etapa_atual < 0 or etapa_atual >= etapas.size():
		return
	tempo_restante -= delta
	tempo_alterado.emit(tempo_restante)
	if tempo_restante <= 0.0:
		_perder("Tempo esgotado na etapa %d" % (etapa_atual + 1))


func _vencer() -> void:
	jogo_ativo = false
	_parar_arma()
	jogo_vencido.emit(tempo_total)


func _perder(motivo: String) -> void:
	jogo_ativo = false
	_limpar_alvos()
	_parar_arma()
	jogo_perdido.emit(motivo, tempo_total)


func _parar_arma() -> void:
	if arma:
		arma.set_process(false)
		arma.set_process_unhandled_input(false)
