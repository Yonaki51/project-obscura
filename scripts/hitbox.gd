extends Area2D

@onready var player: CharacterBody2D = $"../../../player"
@onready var sfx_swing_enemy: AudioStreamPlayer2D = $"../sfx_swing_enemy"
@onready var sfx_player_get_damage: AudioStreamPlayer2D = $sfx_player_get_damage

var cooldown: bool = false

func _physics_process(_delta):
	if cooldown:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist = global_position.distance_to(player.global_position)
		if dist < 20 and player.has_method("take_damage"):
			cooldown = true
			player.take_damage(1)
			player.modulate = Color(1.0, 0.311, 0.354, 1.0)
			
			# Player gets damage sound
			if sfx_player_get_damage:
				$sfx_player_get_damage.pitch_scale = randf_range(0.9, 1.0)
				sfx_player_get_damage.play()
			
			if player.current_health <= 0:
				print("You died!")
				player.modulate = Color(0.81, 0.0, 0.186, 1.0)
				Engine.time_scale = 0.5
				player.get_node("CollisionShape2D").disabled = true
				get_tree().create_timer(1.0).timeout.connect(func():
					Engine.time_scale = 1
					get_tree().reload_current_scene()
				)
			else:
				await get_tree().create_timer(0.5).timeout
				player.modulate = Color(1, 1, 1)
				await get_tree().create_timer(1.0).timeout
				cooldown = false
