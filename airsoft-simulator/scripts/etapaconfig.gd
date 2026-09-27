class_name EtapaConfig
extends Resource
 
@export var quantidade_alvos: int = 3
@export var escala_alvo: float = 1.0       # 1.0 = tamanho normal, 0.5 = metade, etc.
@export var distancia: float = 8.0          # metros do ponto central
@export var dispersao_angular_graus: float = 40.0 # o quão espalhados os alvos ficam
@export var tempo_limite_seg: float = 30.0
