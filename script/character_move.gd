extends CharacterBody2D

var speed = 200.0
var rotation_speed = 2.0

@onready var engine_sound = $EngineSound
@onready var game_over = $"../../../GameOver"

signal collided(collission)

func _ready() -> void:
	collided.connect(_on_car_collided)
	engine_sound.play()
	
func _physics_process(delta):

	# Up / Down = maju / mundur sesuai arah karakter
	var direction := Vector2.ZERO

	if Input.is_action_pressed("up"):
		direction = Vector2.UP.rotated(rotation)
		# A / Left = rotate kiri
		if Input.is_action_pressed("left"):
			rotation -= rotation_speed * delta

		# D / Right = rotate kanan
		if Input.is_action_pressed("right"):
			rotation += rotation_speed * delta
	elif Input.is_action_pressed("down"):
		direction = Vector2.DOWN.rotated(rotation)
			# A / Left = rotate kiri
		if Input.is_action_pressed("left"):
			rotation -= rotation_speed * delta

		# D / Right = rotate kanan
		if Input.is_action_pressed("right"):
			rotation += rotation_speed * delta

	if direction != Vector2.ZERO:
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)

	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		collided.emit(collision)
	
	# Pitch suara berdasarkan kecepatan
	var current_speed := velocity.length()
	engine_sound.pitch_scale = lerp(
		0.8,
		1.7,
		current_speed / speed
	)

func _on_car_collided(collision):
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
