extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const DASH_SPEED = 400.0
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 0.5
const MAX_JUMPS = 1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var attack: Area2D = $Attack
@onready var attack_collision: CollisionShape2D = $Attack/attackCollisionPlayer
@onready var attack_original_position = attack.position
@onready var health_bar: Sprite2D = $"../HealthBar/Sprite2D"
@onready var sfx_jump: AudioStreamPlayer2D = $sfx_jump
@onready var sfx_dash: AudioStreamPlayer2D = $sfx_dash
@onready var sfx_footstep: AudioStreamPlayer2D = $sfx_footstep

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var dash_direction_x = 1
var jumps_remaining = MAX_JUMPS

var max_health: int = 10
var current_health: int = 10
var is_attacking = false

var idle_timer: float = 0.0
var is_moving: bool = false

func _physics_process(delta: float) -> void:
	# Get the input direction at the start
	var direction := Input.get_axis("move_left", "move_right")
	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return
		
		# Check if player is moving
	if velocity.length() > 0:
		is_moving = true
		idle_timer = 0.0
	else:
		is_moving = false
		idle_timer += delta
	
	# If player is 3 seconds idle. Coconut falls
	if idle_timer >= 3.0:
		var coconut = get_tree().get_first_node_in_group("coconut")
		if coconut and not coconut.is_falling:
		# Calculate the collisionbox of the player
			var collision_pos = global_position + body_collision.position
			coconut.start_falling(collision_pos)
			idle_timer = 0.0
	
	# Updates Timer
	if dash_timer > 0:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			dash_cooldown_timer = DASH_COOLDOWN
	
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and jumps_remaining > 0 and not is_dashing:
		velocity.y = JUMP_VELOCITY
		jumps_remaining -= 1
		
		# Random pitch jump
		$sfx_jump.pitch_scale = randf_range(0.9, 1.1)
		sfx_jump.play()
	
	# Reset jumps when on floor
	if is_on_floor():
		jumps_remaining = MAX_JUMPS
	
	# Handle dash
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and not is_dashing:
		# Dash in the direction the character is facing if no input, otherwise dash in input direction
		if direction == 0:
			# Use the sprite flip to determine direction
			dash_direction_x = -1 if animated_sprite.flip_h else 1
		else:
			dash_direction_x = 1 if direction > 0 else -1
		is_dashing = true
		dash_timer = DASH_DURATION
		# Dash play sound pitch scale
		$sfx_dash.pitch_scale = randf_range(0.8, 1.2)
		sfx_dash.play()
	
	# Flip the sprite
	if not is_dashing:
		if direction > 0:
			animated_sprite.flip_h = false
			# fixed bug, makes the player and attack box turn around
			attack_collision.position.x = 14
			body_collision.position.x = 3
		elif direction < 0:
			animated_sprite.flip_h = true
			# fixed bug, makes the player and attack box turn around
			attack_collision.position.x = 2
			body_collision.position.x = 14
		
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
			# Stops walking while idle
			if sfx_footstep and sfx_footstep.playing:
				sfx_footstep.stop()
		else:
			animated_sprite.play("run")
			# play walking 
			if sfx_footstep and not sfx_footstep.playing:
				sfx_footstep.pitch_scale = randf_range(0.8, 1.2)  # Variatie
				sfx_footstep.play()
	else:
		animated_sprite.play("jump")
		# Stops walking when in air
		if sfx_footstep and sfx_footstep.playing:
			sfx_footstep.stop()
		
	
	# Apply movement
	if is_dashing:
		velocity.x = dash_direction_x * DASH_SPEED
	elif direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	
func take_damage(amount: int):
	current_health = max(current_health - amount, 0)
	health_bar.update_bar(current_health, max_health)

func heal(amount: int):
	current_health = min(current_health + amount, max_health)
	health_bar.update_bar(current_health, max_health)
	
# Attacking animation trigger and input mouse for attacking
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and not is_attacking and is_on_floor():
		is_attacking = true
		animated_sprite.stop()
		animated_sprite.play("attack")
		attack.attack()

func _ready():
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
	if animated_sprite.animation == "attack":
		is_attacking = false
