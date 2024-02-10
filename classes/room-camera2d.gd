extends Camera2D
class_name RoomCamera2D

enum interpolation_type {
	none, constant, linear
}

@export_node_path("Node2D") var focus_path : NodePath
@export_range(0.0, 8.0, 0.1) var focus_snap := 1.0
@export var interpolation := interpolation_type.linear
@export var interpolation_speed := 16.0

var current_room : Room

@onready var focus : Node2D = get_node(focus_path)

func _ready() -> void:
	position = focus.position
	RoomManager.cameras.append(self)

func _exit_tree() -> void:
	RoomManager.cameras.erase(self)

func move_towards(new_position: Vector2, delta: float) -> void:
	match interpolation:
		interpolation_type.none:
			position = new_position
		interpolation_type.constant:
			position += position.direction_to(new_position) * interpolation_speed * delta
			if position.distance_to(new_position) < focus_snap:
				position = new_position
		interpolation_type.linear:
			position = position.lerp(new_position, 1.0 - pow(1.0 / interpolation_speed, delta))
			if position.distance_to(new_position) < focus_snap:
				position = new_position

func handle_position_manually() -> void:
	position = focus.position
