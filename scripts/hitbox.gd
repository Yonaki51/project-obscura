extends Area2D

var cooldown: bool = false

func _physics_process(_delta):
	if cooldown:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist = global_position.distance_to(player.global_position)
		if dist < 25 and player.has_method("take_damage"):
			cooldown = true
			player.take_damage(1)
			
			if player.current_health <= 0:
				print("You died!")
				Engine.time_scale = 0.5
				player.get_node("CollisionShape2D").queue_free()
				get_tree().create_timer(1.0).timeout.connect(func():
					Engine.time_scale = 1
					get_tree().reload_current_scene()
				)
			else:
				await get_tree().create_timer(1.0).timeout
				cooldown = false
