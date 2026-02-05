extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const DASH_SPEED = 400.0
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 0.5
const MAX_JUMPS = 1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var dash_direction_x = 1  # Direction for dash: -1 (left) or 1 (right)
var jumps_remaining = MAX_JUMPS


func _physics_process(delta: float) -> void:
	# Get the input direction at the start
	var direction := Input.get_axis("move_left", "move_right")
	
	# Update timers
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
	
	# Flip the sprite (only when not dashing to maintain dash direction)
	if not is_dashing:
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true
		
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
		
	
	# Apply movement
	if is_dashing:
		velocity.x = dash_direction_x * DASH_SPEED
	elif direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
