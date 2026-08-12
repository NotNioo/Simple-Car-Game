extends Camera2D

@export var rotation_speed := 2.0
@export var position_speed := 6.0
@export var zoom_speed := 2.0

@onready var player := $"../player"

func _ready() -> void:
	zoom = Vector2(2.0, 2.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var rotation_dt := rotation_speed * delta
	var position_dt := position_speed * delta
	
	position = position.lerp(player.position, position_dt)
	rotation = lerp_angle(
		rotation,
		player.rotation,
		rotation_dt
	)
	
	if Input.is_action_pressed("zoom_out"):
		zoom -= Vector2.ONE * zoom_speed * delta

	if Input.is_action_pressed("zoom_in"):
		zoom += Vector2.ONE * zoom_speed * delta
	
	zoom = zoom.clamp(
		Vector2(1.0, 1.0),
		Vector2(2.5, 2.5)
	)
