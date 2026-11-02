extends Area3D
class_name CarregadorPickup

## Carregador coletável. Configure tipo/capacidade/massa no Inspector de cada instância.
## Se a cena não tiver CollisionShape3D próprio, o script gera caixa + colisão + rótulo.

@export var tipo: TipoCarregador.Tipo = TipoCarregador.Tipo.RIFLE
@export var capacidade: int = 30
@export var massa_bb_g: float = 0.25


func _ready() -> void:
	if not _tem_colisao_propria():
		_gerar_visual_padrao()
	_criar_rotulo()


func criar_carregador() -> Carregador:
	return Carregador.criar(tipo, capacidade, massa_bb_g)


func _tem_colisao_propria() -> bool:
	for filho in get_children():
		if filho is CollisionShape3D:
			return true
	return false


func _cor_do_tipo() -> Color:
	match tipo:
		TipoCarregador.Tipo.SHOTGUN:
			return Color(0.9, 0.3, 0.2)
		TipoCarregador.Tipo.RIFLE:
			return Color(0.2, 0.6, 0.9)
		TipoCarregador.Tipo.PISTOL_1911:
			return Color(0.9, 0.8, 0.2)
		TipoCarregador.Tipo.PISTOL_GLOCK:
			return Color(0.6, 0.3, 0.8)
	return Color.WHITE


func _gerar_visual_padrao() -> void:
	var malha := MeshInstance3D.new()
	var caixa := BoxMesh.new()
	caixa.size = Vector3(0.12, 0.3, 0.06)
	malha.mesh = caixa
	var material := StandardMaterial3D.new()
	material.albedo_color = _cor_do_tipo()
	malha.material_override = material
	add_child(malha)

	# Colisão um pouco maior que o visual, pra facilitar a mira do raycast
	var colisao := CollisionShape3D.new()
	var forma := BoxShape3D.new()
	forma.size = Vector3(0.3, 0.4, 0.2)
	colisao.shape = forma
	add_child(colisao)


func _criar_rotulo() -> void:
	var rotulo := Label3D.new()
	rotulo.text = "%s\n%.2f g | %d BBs" % [TipoCarregador.nome(tipo), massa_bb_g, capacidade]
	rotulo.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	rotulo.pixel_size = 0.004
	rotulo.position = Vector3(0.0, 0.4, 0.0)
	rotulo.outline_size = 8
	add_child(rotulo)
