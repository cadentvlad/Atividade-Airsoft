extends RigidBody3D
class_name BB
 
@export_category("BB")
@export var bb_mass: float = 0.0002
@export var bb_radius: float = 0.003
@export_category("Air Drag")
@export var air_density: float = 1.225
@export var drag_coefficient: float = 0.47
@export_category("Backspin")
@export var BackspinDrag: float = 0.5 # Valor inicial para escala de Hop-up
@export var backspin_force_scale: float = 0.01
 
## Chamado pela Arma logo após instanciar a BB, para aplicar a massa do carregador
## equipado e o Hop-up atual. A BB continua 100% responsável pela própria física.
var _posicao_anterior: Vector3
 
func configurar(massa_kg: float, backspin_drag: float) -> void:
	bb_mass = massa_kg
	BackspinDrag = backspin_drag
	mass = massa_kg
 
 
func _ready():
	mass = bb_mass
	_posicao_anterior = global_position
 
 
func _physics_process(_delta):
	_verificar_impacto_por_trajeto()
	apply_air_drag()
	apply_backspin()
 
	# Remove a BB se ela sair de uma área razoável de jogo (requisito: "BB fora da área")
	if global_position.y < -10.0 or global_position.length() > 500.0:
		queue_free()
 
	_posicao_anterior = global_position
 
 
## Em vez de depender só da sobreposição da Area3D do alvo (que pode "vazar"
## com a BB indo r√°pido demais entre um frame de física e outro), lançamos um
## raio cobrindo todo o trajeto percorrido neste frame. Isso garante que a
## colisão seja detectada mesmo que a BB "pule" por cima do alvo.
func _verificar_impacto_por_trajeto() -> void:
	if _posicao_anterior.distance_squared_to(global_position) < 0.0001:
		return
 
	var espaco := get_world_3d().direct_space_state
	var consulta := PhysicsRayQueryParameters3D.create(_posicao_anterior, global_position)
	consulta.collide_with_areas = true
	consulta.collide_with_bodies = false
 
	var resultado := espaco.intersect_ray(consulta)
	if resultado.is_empty():
		return
 
	var colisor = resultado.get("collider")
	if colisor is Alvo:
		colisor.registrar_impacto()
		queue_free()
 
 
func apply_air_drag():
	var velocity = linear_velocity
	var speed = velocity.length()
	if speed <= 0.0:
		return
	var area = PI * bb_radius * bb_radius
	var drag_force_magnitude = (
		0.5
		* air_density
		* drag_coefficient
		* area
		* speed * speed
	)
	var drag_force = -velocity.normalized() * drag_force_magnitude # arrasto sempre contra movimento da BB.
	apply_central_force(drag_force)
 
 
func apply_backspin():
	var velocity = linear_velocity
	var speed = velocity.length()
	if speed <= 0.0 or BackspinDrag <= 0.0:
		return
	var direction = velocity.normalized()
	var lift_direction = Vector3.UP
	lift_direction -= direction * lift_direction.dot(direction)
	if lift_direction.length_squared() <= 0.000001:
		return
	lift_direction = lift_direction.normalized()
	# Fórmula simplificada proposta pelo professor
	var lift_magnitude = sqrt(speed) * BackspinDrag
	# Escala física da força
	var lift_force = lift_direction * lift_magnitude * backspin_force_scale
	apply_central_force(lift_force)
