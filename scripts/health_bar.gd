extends Sprite2D

func update_bar(current_health: int, max_health: int):
	var pct = float(current_health) / max_health
	frame = 8 - round(pct * 8)
