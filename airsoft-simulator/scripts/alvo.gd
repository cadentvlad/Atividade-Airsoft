extends Area3D
class_name Alvo
 
signal atingido(alvo: Alvo)
 
@export var pontos: int = 1
 
func _ready() -> void:
	if not _tem_colisao_propria():
		_gerar_visual_padrao()
 
 
func _tem_colisao_propria() -> bool:
	for filho in get_children():
		if filho is CollisionShape3D:
			return true
	return false
 
 
## Cria um cilindro simples como visual/colisão padrão, caso você não tenha
## montado um MeshInstance3D/CollisionShape3D próprios na cena do alvo.
func _gerar_visual_padrao() -> void:
	var malha := MeshInstance3D.new()
	var forma_visual := CylinderMesh.new()
	forma_visual.top_radius = 0.4
	forma_visual.bottom_radius = 0.4
	forma_visual.height = 0.8
	malha.mesh = forma_visual
	add_child(malha)
 
	var colisao := CollisionShape3D.new()
	var forma_colisao := CylinderShape3D.new()
	forma_colisao.radius = 0.4
	forma_colisao.height = 0.8
	colisao.shape = forma_colisao
	add_child(colisao)
 
 
## Chamado pela BB quando o raycast de trajeto confirma um acerto.
func registrar_impacto() -> void:
	atingido.emit(self)
	queue_free()
