class_name PerfilArma
extends Resource

## Configuração de uma arma (modelo, tipo de carregador, energia, cadência).
## Cada arma guarda o próprio carregador equipado, que acompanha a arma quando ela é trocada.

@export var modelo: String = "Arma"
@export var tipo_compativel: TipoCarregador.Tipo = TipoCarregador.Tipo.RIFLE
@export var ajuste_mola_joules: float = 1.0 # modelo simplificado: energia direta em joules
@export var rpm: float = 6000.0
@export var rotacoes_por_disparo: int = 30
@export var capacidade_inicial: int = 20
@export var massa_inicial_g: float = 0.25

# Estado de jogo (não exportado): carregador atualmente equipado nesta arma.
var carregador: Carregador = null

static func padrao(tipo: TipoCarregador.Tipo) -> PerfilArma:
	var p := PerfilArma.new()
	p.tipo_compativel = tipo
	match tipo:
		TipoCarregador.Tipo.RIFLE:
			p.modelo = "Rifle"
			p.ajuste_mola_joules = 1.49
			p.rpm = 8100.0
			p.capacidade_inicial = 30
			p.massa_inicial_g = 0.30
		TipoCarregador.Tipo.SHOTGUN:
			p.modelo = "Shotgun Pump"
			p.ajuste_mola_joules = 1.2
			p.rpm = 3000.0
			p.capacidade_inicial = 20
			p.massa_inicial_g = 0.35
		TipoCarregador.Tipo.PISTOL_1911:
			p.modelo = "Pistola 1911"
			p.ajuste_mola_joules = 0.9
			p.rpm = 4500.0
			p.capacidade_inicial = 12
			p.massa_inicial_g = 0.25
		TipoCarregador.Tipo.PISTOL_GLOCK:
			p.modelo = "Pistola Glock"
			p.ajuste_mola_joules = 1.0
			p.rpm = 6000.0
			p.capacidade_inicial = 20
			p.massa_inicial_g = 0.20
	return p
