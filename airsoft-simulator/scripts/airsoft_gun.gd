extends Node3D
class_name AirsoftGun

signal disparo_realizado(velocidade: float)
signal sem_municao
signal sem_carregador
signal hopup_alterado(valor: float)
signal modo_alterado(modo: int)
signal carregador_alterado(carregador: Carregador)
signal carregador_rejeitado(motivo: String)

enum ModoTiro { SEMI, AUTO }

@export var bb_scene: PackedScene

@export_category("Compatibilidade")
@export var tipo_compativel: TipoCarregador.Tipo = TipoCarregador.Tipo.RIFLE
@export var modelo: String = "AK-47 Airsoft"

# Modelo simplificado (opção 1 do enunciado): o ajuste da mola define
# diretamente a energia do disparo em joules.
@export_category("Mola / Energia")
@export var ajuste_mola_joules: float = 1.49

@export_category("Motor / Cadência")
@export var rpm: float = 8100.0
@export var rotacoes_por_disparo: int = 30 # "N" da fórmula do enunciado

@export_category("Hop-up")
@export var hopup_min: float = 0.0
@export var hopup_max: float = 2.0
@export var hopup_step: float = 0.05
var hopup_atual: float = 0.1

@export_category("Carregador inicial")
@export var capacidade_inicial: int = 30
@export var massa_inicial_g: float = 0.25

var modo_tiro: ModoTiro = ModoTiro.SEMI
var carregador_atual: Carregador = null
var gatilho_pressionado: bool = false
var _proximo_disparo_permitido_ms: int = 0

@onready var muzzle_point: Marker3D = $MuzzlePoint


func _ready() -> void:
	print(">>> AirsoftGun _ready() rodou. Node path: ", get_path())
	if carregador_atual == null:
		equipar_carregador(Carregador.criar(tipo_compativel, capacidade_inicial, massa_inicial_g))


# ROF (disparos por segundo) a partir do RPM do motor e do número de rotações
# necessárias para completar um disparo. Aumentar o RPM aumenta a cadência.
func get_rof() -> float:
	return rpm / (60.0 * rotacoes_por_disparo)


func get_intervalo_disparo() -> float:
	return 1.0 / get_rof()


func pode_disparar() -> bool:
	return Time.get_ticks_msec() >= _proximo_disparo_permitido_ms


func calcular_velocidade(massa_kg: float) -> float:
	return sqrt((2.0 * ajuste_mola_joules) / massa_kg)


func meters_per_second_to_fps(speed_mps: float) -> float:
	return speed_mps * 3.28084


## Tenta equipar um novo carregador. Retorna false (e emite carregador_rejeitado)
## se o tipo não bater com o da arma.
func equipar_carregador(novo: Carregador) -> bool:
	if novo.tipo != tipo_compativel:
		carregador_rejeitado.emit(
			"Carregador incompatível: arma usa " + TipoCarregador.nome(tipo_compativel)
			+ ", carregador é " + TipoCarregador.nome(novo.tipo)
		)
		return false
	carregador_atual = novo
	carregador_alterado.emit(carregador_atual)
	return true


func alternar_modo() -> void:
	modo_tiro = ModoTiro.AUTO if modo_tiro == ModoTiro.SEMI else ModoTiro.SEMI
	modo_alterado.emit(modo_tiro)


func ajustar_hopup(delta: float) -> void:
	hopup_atual = clamp(hopup_atual + delta, hopup_min, hopup_max)
	hopup_alterado.emit(hopup_atual)


func shoot() -> void:
	if not pode_disparar():
		return

	if carregador_atual == null:
		sem_carregador.emit()
		return

	if not carregador_atual.consumir():
		sem_municao.emit()
		return

	var massa_kg = carregador_atual.massa_bb_kg()
	var velocidade = calcular_velocidade(massa_kg)

	var bb: BB = bb_scene.instantiate()
	bb.configurar(massa_kg, hopup_atual)
	get_tree().current_scene.add_child(bb)
	bb.global_position = muzzle_point.global_position
	bb.linear_velocity = muzzle_point.global_transform.basis.z * velocidade

	_proximo_disparo_permitido_ms = Time.get_ticks_msec() + int(get_intervalo_disparo() * 1000.0)

	print("----- DISPARO -----")
	print("Massa: ", massa_kg, " kg | Energia: ", ajuste_mola_joules, " J")
	print("Velocidade: ", velocidade, " m/s (", meters_per_second_to_fps(velocidade), " FPS)")
	print("ROF: ", get_rof(), " BB/s | Intervalo: ", get_intervalo_disparo(), " s")
	print("Munição: ", carregador_atual.quantidade_atual, "/", carregador_atual.capacidade)

	disparo_realizado.emit(velocidade)


func _process(_delta: float) -> void:
	if modo_tiro == ModoTiro.AUTO and gatilho_pressionado:
		shoot()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			gatilho_pressionado = event.pressed
			if event.pressed and modo_tiro == ModoTiro.SEMI:
				shoot()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			ajustar_hopup(hopup_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			ajustar_hopup(-hopup_step)

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F:
			alternar_modo()
