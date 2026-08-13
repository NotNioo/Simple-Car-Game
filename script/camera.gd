extends Camera2D

@export var rotation_speed := 2.0
@export var position_speed := 9.0
@export var zoom_speed := 2.0
@export var zoom_wheel_speed := 0.25

@onready var player := $"../player"

func _ready() -> void:
	zoom = Vector2(2.0, 2.0)

func _process(delta: float) -> void:
	var rotation_dt := rotation_speed * delta
	var position_dt := position_speed * delta
	
	# The camera approaches the player position smoothly
	position = position.lerp(player.position, position_dt)
	# The camera rotation approaches the player rotation
	rotation = lerp_angle(
		rotation,
		player.rotation,
		rotation_dt
	)

	if Input.is_action_pressed("zoom_out"):
		zoom -= Vector2.ONE * zoom_speed * delta

	if Input.is_action_pressed("zoom_in"):
		zoom += Vector2.ONE * zoom_speed * delta
	
	if Input.is_action_just_pressed("zoom_wheel_out"):
		zoom -= Vector2.ONE * zoom_wheel_speed
		
	if Input.is_action_just_pressed("zoom_wheel_in"):
		zoom += Vector2.ONE * zoom_wheel_speed
	zoom = zoom.clamp(
		Vector2(1.0, 1.0),
		Vector2(2.5, 2.5)
	)
