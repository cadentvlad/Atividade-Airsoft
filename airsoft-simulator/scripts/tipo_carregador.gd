class_name TipoCarregador
extends RefCounted

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

static func cor(tipo: Tipo) -> Color:
	match tipo:
		Tipo.SHOTGUN:
			return Color(0.9, 0.3, 0.2)
		Tipo.RIFLE:
			return Color(0.2, 0.6, 0.9)
		Tipo.PISTOL_1911:
			return Color(0.9, 0.8, 0.2)
		Tipo.PISTOL_GLOCK:
			return Color(0.6, 0.3, 0.8)
	return Color.WHITE
