extends CharacterBody2D

const SPEED = 50
const GRAVITY = 300  # Pixels per seconde², pas aan naar smaak

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_down: RayCast2D = $RayCastDown
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var health: int = 20

var direction = -1
var is_dead = false
var vertical_velocity = 0.0

func _process(delta: float):
	if is_dead:
		# Laat de enemy vallen
		vertical_velocity += GRAVITY * delta
		position.y += vertical_velocity * delta
		return

	# Movement collisions
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = false
	elif ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = true

	position.x += direction * SPEED * delta

func handle_hit(damage: int):
	health -= damage
	#if health = 0
	if health <= 0 and not is_dead:
		get_node("CollisionShape2D").disabled = true
		is_dead = true
		await get_tree().create_timer(0.3).timeout
		queue_free()
