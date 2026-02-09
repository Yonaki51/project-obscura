extends Sprite2D

func _ready():
	frame = 8
	

func update_bar(current_health: int, max_health: int):
	var pct = float(current_health) / max_health
	frame = round(pct * 8)
