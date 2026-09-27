class_name TipoCarregador
extends RefCounted

## Enum único usado tanto pela Arma quanto pelo Carregador para decidir compatibilidade.
## Nunca comparar strings digitadas livremente — sempre comparar valores neste enum.
enum Tipo {
	SHOTGUN,
	RIFLE,
	PISTOL_1911,
	PISTOL_GLOCK
}

static func nome(tipo: Tipo) -> String:
	match tipo:
		Tipo.SHOTGUN:
			return "Shotgun"
		Tipo.RIFLE:
			return "Rifle"
		Tipo.PISTOL_1911:
			return "Pistol 1911"
		Tipo.PISTOL_GLOCK:
			return "Pistol Glock"
	return "Desconhecido"
