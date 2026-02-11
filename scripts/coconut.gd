extends Area2D

@onready var sfx_player_get_damage: AudioStreamPlayer2D = $sfx_player_get_damage
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var sfx_coconut_player: AudioStreamPlayer2D = $sfx_coconut_player

var fall_speed: float = 0
var fall_gravity: float = 500
var is_falling: bool = false
var initial_position: Vector2
var spawn_height: float = 200.0

func _ready():
	add_to_group("coconut")
	initial_position = global_position
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	if is_falling:
		fall_speed += fall_gravity * delta
		global_position.y += fall_speed * delta
		
		# resets coconut when it falls too far
		if global_position.y > 300:
			reset_coconut()

# puts coconut above the player's collision box
func start_falling(player_position: Vector2):
	global_position.x = player_position.x
	global_position.y = player_position.y - spawn_height
	is_falling = true
	fall_speed = 0

func _on_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(1)
		body.modulate = Color(1.0, 0.311, 0.354, 1.0)
		
		# coconut sound
		if sfx_player_get_damage:
				sfx_player_get_damage.play()
				$sfx_coconut_player.pitch_scale = randf_range(0.8, 1.1)
				sfx_coconut_player.play()
		reset_coconut()
		
		# Check if player died
		if body.current_health <= 0:
			print("You died!")
			body.modulate = Color(0.81, 0.0, 0.186, 1.0)
			Engine.time_scale = 0.5
			body.get_node("CollisionShape2D").set_deferred("disabled", true)
			get_tree().create_timer(1.0).timeout.connect(func():
				Engine.time_scale = 1
				get_tree().reload_current_scene()
			)
			return
		else:
			await get_tree().create_timer(0.5).timeout
			if is_instance_valid(body):
				body.modulate = Color(1, 1, 1)

func reset_coconut():
	is_falling = false
	fall_speed = 0
	global_position = initial_position
