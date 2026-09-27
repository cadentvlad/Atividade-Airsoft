extends CanvasLayer
class_name HUD
 
@export var arma_path: NodePath
var arma: AirsoftGun
 
@onready var label_municao: Label = $Margin/VBox/LabelMunicao
@onready var label_massa: Label = $Margin/VBox/LabelMassa
@onready var label_modo: Label = $Margin/VBox/LabelModo
@onready var label_hopup: Label = $Margin/VBox/LabelHopup
@onready var label_aviso: Label = $Margin/VBox/LabelAviso
 
 
func _ready() -> void:
	if arma_path != NodePath():
		arma = get_node(arma_path) as AirsoftGun
 
	if arma == null:
		push_warning("HUD sem referência de arma (preencha o campo Arma Path no Inspector)")
		return
 
	arma.disparo_realizado.connect(_on_disparo)
	arma.sem_municao.connect(_on_sem_municao)
	arma.sem_carregador.connect(_on_sem_carregador)
	arma.modo_alterado.connect(_on_modo_alterado)
	arma.hopup_alterado.connect(_on_hopup_alterado)
	arma.carregador_alterado.connect(_on_carregador_alterado)
	arma.carregador_rejeitado.connect(_on_carregador_rejeitado)
 
	_on_modo_alterado(arma.modo_tiro)
	_on_hopup_alterado(arma.hopup_atual)
	if arma.carregador_atual:
		_on_carregador_alterado(arma.carregador_atual)
 
 
func _atualizar_municao() -> void:
	if arma.carregador_atual:
		label_municao.text = "%d / %d" % [arma.carregador_atual.quantidade_atual, arma.carregador_atual.capacidade]
 
 
func _on_disparo(_velocidade: float) -> void:
	_atualizar_municao()
	label_aviso.text = ""
 
 
func _on_sem_municao() -> void:
	label_aviso.text = "SEM MUNIÇÃO"
 
 
func _on_sem_carregador() -> void:
	label_aviso.text = "SEM CARREGADOR"
 
 
func _on_modo_alterado(modo: int) -> void:
	label_modo.text = "AUTO" if modo == AirsoftGun.ModoTiro.AUTO else "SEMI"
 
 
func _on_hopup_alterado(valor: float) -> void:
	label_hopup.text = "Hop-up: %.2f" % valor
 
 
func _on_carregador_alterado(carregador: Carregador) -> void:
	_atualizar_municao()
	label_massa.text = "%.2f g" % carregador.massa_bb_g
	label_aviso.text = ""
 
 
func _on_carregador_rejeitado(motivo: String) -> void:
	label_aviso.text = motivo
