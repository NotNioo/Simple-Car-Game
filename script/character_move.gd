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


func _ready() -> void:
	engine_sound.play()


func _physics_process(delta):
	var rotation_dt: float = camera.rotation_speed * delta

	# =========================
	# ACCELERATION / BRAKING
	# =========================

	if Input.is_action_pressed("up"):
		if speed < 0:
			# Brake when reversing
			speed = move_toward(speed, 0.0, braking * delta)
		else:
			# Front Acceleration
			speed = move_toward(speed, max_speed, acceleration * delta)

	elif Input.is_action_pressed("down"):
		if speed > 0:
			# Brake when accelerating
			speed = move_toward(speed, 0.0, braking * delta)
		else:
			# Back Acceleration
			speed = move_toward(speed, -max_speed, acceleration * delta)

	else:
		# Release gas -> car keep sliding
		speed *= exp(-drag * delta)

		if abs(speed) < stop_threshold:
			speed = 0.0
	
	if Input.is_action_pressed("left") && speed != 0.0:
		rotation -= rotation_dt

	if Input.is_action_pressed("right") && speed != 0.0:
		rotation += rotation_dt
	# =========================
	# MOVEMENT
	# =========================

	var forward := Vector2.UP.rotated(rotation)

	velocity = forward * speed

	move_and_slide()

	# =========================
	# COLLISION
	# =========================

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		on_car_collided(collision)

	# =========================
	# ENGINE SOUND
	# =========================

	var speed_ratio := remap(
		velocity.length(),
		0.0,
		max_speed,
		0.8,
		1.5
	)

	engine_sound.pitch_scale = clamp(speed_ratio, 0.8, 1.5)
	speed_label.text = "Speed: %.2f" % speed

func on_car_collided(collision):
	var object = collision.get_collider()

	if object.is_in_group("map"):
		var collision_normal = collision.get_normal()

		# Car front side
		var forward = -transform.y

		# Direction from the car to the collided object
		var hit_direction = -collision_normal

		# How close collision with car front side
		var front_hit = forward.dot(hit_direction)

		if front_hit > 0.9:
			get_tree().paused = true
			game_over.show_game_over()
