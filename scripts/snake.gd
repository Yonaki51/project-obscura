extends Area2D

var damage_active: bool = false
@onready var player: CharacterBody2D = $"../../../player"

func _physics_process(_delta):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist = global_position.distance_to(player.global_position)
		if dist < 5:
			if not damage_active and player.has_method("take_damage"):
				damage_active = true
				_damage_loop(player)
		else:
			damage_active = false

func _damage_loop(player):
	while damage_active and is_instance_valid(player):
		var dist = global_position.distance_to(player.global_position)
		if dist >= 5:
			damage_active = false
			return
		
		player.take_damage(1)
		player.modulate = Color(1.0, 0.311, 0.354, 1.0)
		
		if player.current_health <= 0:
			print("You died!")
			player.modulate = Color(0.81, 0.0, 0.186, 1.0)
			Engine.time_scale = 0.5
			player.get_node("CollisionShape2D").disabled = true
			get_tree().create_timer(1.0).timeout.connect(func():
				Engine.time_scale = 1
				get_tree().reload_current_scene()
			)
			return
		else:
			await get_tree().create_timer(0.5).timeout
			if is_instance_valid(player):
				player.modulate = Color(1, 1, 1)
			await get_tree().create_timer(0.5).timeout  # Totaal 1 seconde
