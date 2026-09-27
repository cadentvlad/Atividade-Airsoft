extends Camera3D
class_name Interacao
 
## Anexe este script na própria Camera3D da sua cena.
 
@export var arma_path: NodePath
@export var alcance: float = 3.0
 
var arma: AirsoftGun
 
func _ready() -> void:
	if arma_path != NodePath():
		arma = get_node(arma_path) as AirsoftGun
 
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		_tentar_interagir()
 
func _tentar_interagir() -> void:
	var centro = get_viewport().get_visible_rect().size / 2.0
	var origem = project_ray_origin(centro)
	var direcao = project_ray_normal(centro)
	var destino = origem + direcao * alcance
 
	var consulta = PhysicsRayQueryParameters3D.create(origem, destino)
	consulta.collide_with_areas = true
	consulta.collide_with_bodies = true
 
	var resultado = get_world_3d().direct_space_state.intersect_ray(consulta)
	if resultado.is_empty():
		return
 
	var colisor = resultado.get("collider")
	if colisor is CarregadorPickup:
		var novo = colisor.criar_carregador()
		if arma.equipar_carregador(novo):
			# Requisito mínimo: substitui o carregador. Melhoria possível:
			# reposicionar o pickup antigo no lugar deste em vez de remover.
			colisor.queue_free()
