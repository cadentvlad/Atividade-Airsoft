extends Area3D
class_name ArmaPickup

## Arma largada no chão. Ao interagir (E), o jogador pega esta arma e a que ele
## segurava fica aqui, no mesmo lugar, com o carregador dela.

@export var tipo: TipoCarregador.Tipo = TipoCarregador.Tipo.SHOTGUN
## Opcional: perfil próprio. Se vazio, usa o perfil padrão do tipo escolhido acima.
@export var perfil_personalizado: PerfilArma

var perfil: PerfilArma
var _material: StandardMaterial3D
var _rotulo: Label3D


func _ready() -> void:
	if perfil == null:
		perfil = perfil_personalizado if perfil_personalizado else PerfilArma.padrao(tipo)
	if not _tem_colisao_propria():
		_gerar_visual_padrao()
	_criar_rotulo()
	_atualizar_visual()


func definir_perfil(novo: PerfilArma) -> void:
	perfil = novo
	_atualizar_visual()


func _tem_colisao_propria() -> bool:
	for filho in get_children():
		if filho is CollisionShape3D:
			return true
	return false


func _gerar_visual_padrao() -> void:
	var malha := MeshInstance3D.new()
	var caixa := BoxMesh.new()
	caixa.size = Vector3(0.7, 0.12, 0.1)
	malha.mesh = caixa
	_material = StandardMaterial3D.new()
	malha.material_override = _material
	add_child(malha)

	# Colisão maior que o visual, para facilitar a mira do raycast
	var colisao := CollisionShape3D.new()
	var forma := BoxShape3D.new()
	forma.size = Vector3(0.9, 0.4, 0.4)
	colisao.shape = forma
	add_child(colisao)


func _criar_rotulo() -> void:
	_rotulo = Label3D.new()
	_rotulo.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_rotulo.pixel_size = 0.004
	_rotulo.position = Vector3(0.0, 0.45, 0.0)
	_rotulo.outline_size = 8
	add_child(_rotulo)


func _atualizar_visual() -> void:
	if _material:
		_material.albedo_color = TipoCarregador.cor(perfil.tipo_compativel)
	if _rotulo:
		var atual := perfil.carregador.quantidade_atual if perfil.carregador else perfil.capacidade_inicial
		var cap := perfil.carregador.capacidade if perfil.carregador else perfil.capacidade_inicial
		_rotulo.text = "%s\n(%s)\n%d / %d BBs" % [
			perfil.modelo, TipoCarregador.nome(perfil.tipo_compativel), atual, cap]
