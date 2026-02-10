extends Area2D

var player_in_area: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		player_in_area = true
		_damage_loop(body)

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false

func _damage_loop(body):
	while player_in_area and is_instance_valid(body):
		body.take_damage(1)
		body.modulate = Color(1.0, 0.311, 0.354, 1.0)
		
		if body.current_health <= 0:
			print("You died!")
			body.modulate = Color(0.81, 0.0, 0.186, 1.0)
			Engine.time_scale = 0.5
			body.get_node("CollisionShape2D").disabled = true
			get_tree().create_timer(1.0).timeout.connect(func():
				Engine.time_scale = 1
				get_tree().reload_current_scene()
			)
			return
		else:
			await get_tree().create_timer(0.5).timeout
			if is_instance_valid(body):
				body.modulate = Color(1, 1, 1)
			await get_tree().create_timer(0.5).timeout  # Totaal 1 seconde (0.5 + 0.5)
