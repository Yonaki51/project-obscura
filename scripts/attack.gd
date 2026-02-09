extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var damage: int = 10

func attack():
	animation_player.play("attack_player")
	
func _on_attack_body_entered(body: CharacterBody2D) -> void:
	print("Raak:", body.name, " groups:", body.get_groups())
	if body.is_in_group("enemy"):
		body.handle_hit(damage)

func _ready():
	connect("body_entered", _on_attack_body_entered)
