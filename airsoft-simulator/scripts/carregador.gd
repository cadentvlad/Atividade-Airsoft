class_name Carregador
extends Resource

## O carregador é o único responsável por: tipo, capacidade, munição atual e massa da BB.
## A arma apenas consulta e consome — nunca guarda essas informações duplicadas.

signal municao_alterada(atual: int, capacidade: int)
 
@export var tipo: TipoCarregador.Tipo = TipoCarregador.Tipo.RIFLE
@export var capacidade: int = 30
@export var massa_bb_g: float = 0.25 # armazenado em gramas só para ser amigável no editor
@export var quantidade_atual: int = 30
 
static func criar(_tipo: TipoCarregador.Tipo, _capacidade: int, _massa_g: float) -> Carregador:
	var c := Carregador.new()
	c.tipo = _tipo
	c.capacidade = _capacidade
	c.massa_bb_g = _massa_g
	c.quantidade_atual = _capacidade
	return c
 
## Massa em quilogramas — é isso que deve ser usado em qualquer cálculo físico.
func massa_bb_kg() -> float:
	return massa_bb_g / 1000.0
 
func tem_municao() -> bool:
	return quantidade_atual > 0
 
func esta_vazio() -> bool:
	return quantidade_atual <= 0
 
func consumir() -> bool:
	if not tem_municao():
		return false
	quantidade_atual -= 1
	municao_alterada.emit(quantidade_atual, capacidade)
	return true
 
func recarregar_completo() -> void:
	quantidade_atual = capacidade
	municao_alterada.emit(quantidade_atual, capacidade)
