extends CharacterBody2D

var speed = 200.0

func _physics_process(delta):
	print(global_position)
	var direction := Input.get_vector(
		"left",
		"right",
		"up",
		"down"
	)
	if direction != Vector2.ZERO:
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
	move_and_slide()
