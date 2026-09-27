extends Area3D
class_name CarregadorPickup

## Coloque este script em um Node3D com Area3D + CollisionShape3D + MeshInstance3D
## (ex: um pequeno cubo/prisma) e configure tipo/capacidade/massa no Inspector.

@export var tipo: TipoCarregador.Tipo = TipoCarregador.Tipo.RIFLE
@export var capacidade: int = 30
@export var massa_bb_g: float = 0.25

func criar_carregador() -> Carregador:
	return Carregador.criar(tipo, capacidade, massa_bb_g)
