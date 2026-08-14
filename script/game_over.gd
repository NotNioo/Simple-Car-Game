extends CanvasLayer

@onready var car = $"../NewMap/Player_car/car"

func _ready() -> void:
	visible = false

func show_game_over():
	visible = true
	get_tree().paused = true

func _on_map_boundary_body_exited(body: Node2D) -> void:
	if body == car:
		car.start_fall()
