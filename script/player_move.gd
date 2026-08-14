extends CharacterBody2D

var last_direction: Vector2 = Vector2.DOWN
var speed: float = 100.0
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	print(global_position)
	
func _physics_process(_delta: float) -> void:
	# 2. Fixed order: Left (Negative X), Right (Positive X), Up (Negative Y), Down (Positive Y)
	var direction := Input.get_vector("left", "right", "up", "down")
	
	# 3. Fixed Vector2.ZERO capitalization
	if direction != Vector2.ZERO:
		velocity = direction * speed
		if direction.y > 0:
			animated_sprite.play("IdleFront")
		elif direction.y < 0:
			animated_sprite.play("IdleBack")# TODO: Bikin animasi jalan.
		elif direction.x > 0: #kanan
			animated_sprite.play()
		elif direction.x < 0: #kiri
			animated_sprite.play()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		if abs(last_direction.x) > abs(last_direction.y):
			if last_direction.x > 0:
				animated_sprite.play("")#Kanan
			else:
				animated_sprite.play("")#Kiri
		else:
			if last_direction.y > 0:
				animated_sprite.play("IdleFront")
			else:
				animated_sprite.play("IdleBack")
	move_and_slide()
