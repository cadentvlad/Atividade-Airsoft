extends CanvasLayer
class_name PainelJogo
 
@export var gerenciador: GameManager
 
@onready var label_etapa: Label = $Margin/VBox/LabelEtapa
@onready var label_tempo: Label = $Margin/VBox/LabelTempo
@onready var label_tempo_total: Label = $Margin/VBox/LabelTempoTotal
@onready var label_aviso_rapido: Label = $AvisoRapido
 
@onready var painel_fim: Control = $PainelFim
@onready var label_resultado: Label = $PainelFim/CentroFim/LabelResultado
@onready var label_tempo_final: Label = $PainelFim/CentroFim/LabelTempoFinal
@onready var label_dica: Label = $PainelFim/CentroFim/LabelDica
 
 
func _ready() -> void:
	if gerenciador == null:
		push_warning("PainelJogo sem referência ao GameManager (arraste no Inspector)")
		return
	gerenciador.etapa_iniciada.connect(_on_etapa_iniciada)
	gerenciador.tempo_alterado.connect(_on_tempo_alterado)
	gerenciador.tempo_total_alterado.connect(_on_tempo_total_alterado)
	gerenciador.jogo_vencido.connect(_on_vencido)
	gerenciador.jogo_perdido.connect(_on_perdido)
	painel_fim.visible = false
	label_aviso_rapido.visible = false
 
 
func _mostrar_aviso_rapido(texto: String, duracao: float = 2.5) -> void:
	label_aviso_rapido.text = texto
	label_aviso_rapido.visible = true
	await get_tree().create_timer(duracao).timeout
	label_aviso_rapido.text = ""
	label_aviso_rapido.visible = false
 
 
func _unhandled_input(event: InputEvent) -> void:
	if not painel_fim.visible:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		if gerenciador and gerenciador.has_method("reiniciar_jogo"):
			gerenciador.reiniciar_jogo()
			painel_fim.visible = false
 
 
func _formatar_tempo(segundos: float) -> String:
	return "%.1fs" % max(segundos, 0.0)
 
 
func _on_etapa_iniciada(indice: int, total: int) -> void:
	label_etapa.text = "Etapa %d / %d" % [indice + 1, total]
	_mostrar_aviso_rapido("Acerte os alvos antes que o tempo acabe!")
 
 
func _on_tempo_alterado(restante: float) -> void:
	label_tempo.text = "Tempo da etapa: " + _formatar_tempo(restante)
 
 
func _on_tempo_total_alterado(total: float) -> void:
	label_tempo_total.text = "Tempo total: " + _formatar_tempo(total)
 
 
func _on_vencido(tempo_total: float) -> void:
	label_resultado.text = "VITÓRIA!"
	label_tempo_final.text = "Tempo total: " + _formatar_tempo(tempo_total)
	label_dica.text = "Aperte R para jogar de novo"
	painel_fim.visible = true
 
 
func _on_perdido(motivo: String, tempo_total: float) -> void:
	label_resultado.text = "DERROTA — " + motivo
	label_tempo_final.text = "Tempo total: " + _formatar_tempo(tempo_total)
	label_dica.text = "Aperte R para tentar de novo"
	painel_fim.visible = true
