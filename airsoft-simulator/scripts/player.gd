extends CharacterBody3D
class_name Player

@export var velocidade: float = 5.0
@export var sensibilidade_mouse: float = 0.003
@export var pitch_min_graus: float = -85.0
@export var pitch_max_graus: float = 85.0

const GRAVIDADE: float = 9.8

@onready var head: Node3D = $Head


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * sensibilidade_mouse)
		head.rotation.x += event.relative.y * sensibilidade_mouse
		head.rotation.x = clamp(
			head.rotation.x,
			deg_to_rad(pitch_min_graus),
			deg_to_rad(pitch_max_graus)
		)

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = (
			Input.MOUSE_MODE_VISIBLE
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
			else Input.MOUSE_MODE_CAPTURED
		)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVIDADE * delta
	else:
		velocity.y = 0.0

	var entrada := Vector2.ZERO
	if Input.is_key_pressed(KEY_W):
		entrada.y += 1.0
	if Input.is_key_pressed(KEY_S):
		entrada.y -= 1.0
	if Input.is_key_pressed(KEY_A):
		entrada.x += 1.0
	if Input.is_key_pressed(KEY_D):
		entrada.x -= 1.0
	entrada = entrada.normalized()

	var direcao := (transform.basis * Vector3(entrada.x, 0.0, entrada.y)).normalized()
	velocity.x = direcao.x * velocidade
	velocity.z = direcao.z * velocidade

	move_and_slide()
