extends CharacterBody2D

var speed := 0.0
@export var max_speed := 300.0
@export var acceleration := 250.0
@export var braking := 250.0

@onready var engine_sound = $EngineSound
@onready var game_over = $"../../../GameOver"
@onready var camera = $"../Camera2D"

func _ready() -> void:
	engine_sound.play()
	
func _physics_process(delta):

	var direction := Vector2.ZERO
	var rotation_dt: float = camera.rotation_speed * delta

	if Input.is_action_pressed("up"):
		direction = Vector2.UP.rotated(rotation)
		speed = move_toward(speed, max_speed, acceleration * delta)

		if Input.is_action_pressed("left"):
			rotation -= rotation_dt

		if Input.is_action_pressed("right"):
			rotation += rotation_dt

	elif Input.is_action_pressed("down"):
		direction = Vector2.DOWN.rotated(rotation)
		speed = move_toward(speed, -max_speed, acceleration * delta)
		
		if Input.is_action_pressed("left"):
			rotation += rotation_dt

		if Input.is_action_pressed("right"):
			rotation -= rotation_dt
	
	else:
		speed = move_toward(speed, 0.0, braking * delta)
		
	if speed != 0:
		velocity = direction * abs(speed)
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		on_car_collided(collision)
	
	# Pitch suara berdasarkan kecepatan
	var speed_ratio := remap(
		velocity.length(), 
		0.0,
		max_speed,
		0.8,
		1.5
	)

	engine_sound.pitch_scale = clamp(speed_ratio, 0.8, 1.5)

func on_car_collided(collision):
	var object = collision.get_collider()
	if object.is_in_group("map"):
		var collision_normal = collision.get_normal()
		# Arah depan mobil
		var forward = -transform.y

		# Arah dari mobil menuju benda yang ditabrak
		var hit_direction = -collision_normal

		# Seberapa dekat benturan dengan arah depan mobil
		var front_hit = forward.dot(hit_direction)
		if front_hit > 0.9:
			get_tree().paused = true
			game_over.show_game_over()
