extends AnimatableBody2D

@export var fall_delay: float = 1.5
@export var fall_speed: float = 100.0
@export var shake_intensity: float = 0.5

@onready var timer: Timer = $Timer
@onready var detection_area: Area2D = $DetectionArea
@onready var sprite_2d: Sprite2D = $Sprite2D

var is_falling := false
var is_shaking := false
var original_position: Vector2

func _ready():
	original_position = position
	timer.wait_time = fall_delay
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player") and not is_falling:
		timer.start()
		is_shaking = true

func _on_body_exited(body: Node2D):
	if body.is_in_group("player") and not is_falling:
		timer.stop()
		is_shaking = false
		position = original_position

func _on_timer_timeout():
	is_shaking = false
	is_falling = true

func _physics_process(delta):
	if is_shaking:
		sprite_2d.position = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
	elif is_falling:
		sprite_2d.position = Vector2.ZERO
		position.y += fall_speed * delta
