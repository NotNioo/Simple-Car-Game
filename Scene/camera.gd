extends Camera2D

@export var rotation_speed := 2.0
@export var position_speed := 7.0
@onready var player := $"../player"


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
