extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var damage: int = 10

func attack():
	monitoring = true
	animation_player.play("attack_player")
	
func _on_attack_body_entered(body: CharacterBody2D) -> void:
	if body.has_method("handle_hit"):
		body.handle_hit(damage)
		print("Hit:")

func _ready():
	connect("body_entered", _on_attack_body_entered)
