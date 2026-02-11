extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sfx_swing: AudioStreamPlayer2D = $"../sfx_swing"

@export var damage: int = 10

func attack():
	animation_player.play("attack_player")
	
	# Swing sound play + pitch
	if sfx_swing:
		sfx_swing.pitch_scale = randf_range(0.8, 1.2)
		sfx_swing.play()
	
func _on_attack_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("enemy"):
		body.handle_hit(damage)
		

func _ready():
	connect("body_entered", _on_attack_body_entered)
