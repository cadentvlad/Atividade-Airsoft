extends CanvasLayer
class_name PainelJogo

@export var gerenciador: GameManager

@onready var label_etapa: Label = $Margin/VBox/LabelEtapa
@onready var label_tempo: Label = $Margin/VBox/LabelTempo
@onready var label_tempo_total: Label = $Margin/VBox/LabelTempoTotal
@onready var label_aviso_rapido: Label = $AvisoRapido

var painel_inicio: ColorRect # criado por código

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
	gerenciador.aguardando_inicio.connect(_on_aguardando_inicio)
	_criar_painel_inicio()
	painel_fim.visible = false
	label_aviso_rapido.visible = false


func _mostrar_aviso_rapido(texto: String, duracao: float = 2.5) -> void:
	label_aviso_rapido.text = texto
	label_aviso_rapido.visible = true
	await get_tree().create_timer(duracao).timeout
	label_aviso_rapido.text = ""
	label_aviso_rapido.visible = false


func _criar_painel_inicio() -> void:
	painel_inicio = ColorRect.new()
	painel_inicio.color = Color(0, 0, 0, 0.6)
	painel_inicio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(painel_inicio)
	painel_inicio.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var centro := CenterContainer.new()
	painel_inicio.add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var caixa := VBoxContainer.new()
	centro.add_child(caixa)

	var titulo := Label.new()
	titulo.text = "Acerte os alvos antes que o tempo acabe!"
	titulo.add_theme_font_size_override("font_size", 36)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caixa.add_child(titulo)

	var dica := Label.new()
	dica.text = "Aperte ESPAÇO para começar"
	dica.add_theme_font_size_override("font_size", 20)
	dica.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caixa.add_child(dica)

	painel_inicio.visible = false


func _on_aguardando_inicio() -> void:
	painel_inicio.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	if painel_inicio.visible and event.keycode == KEY_SPACE:
		painel_inicio.visible = false
		gerenciador.comecar_jogo()
	elif painel_fim.visible and event.keycode == KEY_R:
		painel_fim.visible = false
		gerenciador.reiniciar_jogo()


func _formatar_tempo(segundos: float) -> String:
	return "%.1fs" % max(segundos, 0.0)


func _on_etapa_iniciada(indice: int, total: int) -> void:
	label_etapa.text = "Etapa %d / %d" % [indice + 1, total]


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
