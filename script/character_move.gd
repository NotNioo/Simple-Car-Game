extends CharacterBody2D

var speed := 0.0

@export var max_speed := 300.0
@export var acceleration := 250.0
@export var drag := 1.0
@export var stop_threshold := 15.0
@export var braking := 220.0

@onready var engine_sound = $EngineSound
@onready var game_over = $"../../../GameOver"
@onready var camera = $"../Camera2D"
@onready var speed_label = $"../CanvasLayer/SpeedLabel"
@onready var car_sprite = $AnimatedSprite2D

var falling := false
var fall_velocity := Vector2.ZERO

@export var fall_duration := 0.8
@export var fall_deceleration := 500.0


func _ready() -> void:
	engine_sound.play()


func _physics_process(delta: float) -> void:
	# =========================================================
	# FALLING
	# =========================================================

	if falling:
		# Gradually slow down while keeping the same direction.
		fall_velocity = fall_velocity.move_toward(
			Vector2.ZERO,
			fall_deceleration * delta
		)

		velocity = fall_velocity
		move_and_slide()

		return


	var rotation_dt: float = camera.rotation_speed * delta


	# =========================================================
	# ACCELERATION / BRAKING
	# =========================================================

	if Input.is_action_pressed("up"):
		if speed < 0.0:
			speed = move_toward(speed, 0.0, braking * delta)
		else:
			speed = move_toward(
				speed,
				max_speed,
				acceleration * delta
			)

	elif Input.is_action_pressed("down"):
		if speed > 0.0:
			speed = move_toward(speed, 0.0, braking * delta)
		else:
			speed = move_toward(
				speed,
				-max_speed,
				acceleration * delta
			)

	else:
		speed *= exp(-drag * delta)

		if abs(speed) < stop_threshold:
			speed = 0.0


	# =========================================================
	# ROTATION
	# =========================================================

	if Input.is_action_pressed("left") and speed != 0.0:
		rotation -= rotation_dt

	if Input.is_action_pressed("right") and speed != 0.0:
		rotation += rotation_dt


	# =========================================================
	# MOVEMENT
	# =========================================================

	var forward := Vector2.UP.rotated(rotation)

	velocity = forward * speed

	move_and_slide()


	# =========================================================
	# COLLISION
	# =========================================================

	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		on_car_collided(collision)


	# =========================================================
	# ENGINE SOUND
	# =========================================================

	var speed_ratio := remap(
		velocity.length(),
		0.0,
		max_speed,
		0.8,
		1.5
	)

	engine_sound.pitch_scale = clamp(
		speed_ratio,
		0.8,
		1.5
	)

	speed_label.text = "Speed: %.2f" % speed


# =========================================================
# MAP COLLISION
# =========================================================

func on_car_collided(collision) -> void:
	var object = collision.get_collider()

	if object.is_in_group("map"):
		var collision_normal = collision.get_normal()

		var forward = -transform.y
		var hit_direction = -collision_normal

		var front_hit = forward.dot(hit_direction)

		if front_hit > 0.9:
			game_over.show_game_over()


# =========================================================
# FALL OUT OF MAP
# =========================================================

func start_fall() -> void:
	if falling:
		return

	falling = true

	# Store the velocity at the exact moment the car leaves the map.
	fall_velocity = velocity

	# Disable collision so nothing interferes with the fall.
	var collision_shape := get_node_or_null("CollisionShape2D")

	if collision_shape:
		collision_shape.set_deferred("disabled", true)

	engine_sound.stop()

	# Reset the sprite in case this function is ever called again.
	car_sprite.visible = true
	car_sprite.scale = Vector2.ONE
	car_sprite.modulate.a = 1.0

	var tween := create_tween()
	tween.set_parallel(true)

	# Shrink the car.
	tween.tween_property(
		car_sprite,
		"scale",
		Vector2.ZERO,
		fall_duration
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

	# Fade it out completely.
	tween.tween_property(
		car_sprite,
		"modulate:a",
		0.0,
		fall_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# Slight rotation while falling.
	tween.tween_property(
		car_sprite,
		"rotation",
		car_sprite.rotation + deg_to_rad(30.0),
		fall_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	await tween.finished

	# Make absolutely sure the car is no longer rendered.
	car_sprite.visible = false
	visible = false

	velocity = Vector2.ZERO
	fall_velocity = Vector2.ZERO
	speed = 0.0

	game_over.show_game_over()
