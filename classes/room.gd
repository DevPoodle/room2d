@tool
extends Node2D
class_name Room

signal entered
signal exited

func _ready() -> void:
	if !Engine.is_editor_hint():
		RoomManager.rooms.append(self)

func _exit_tree() -> void:
	if !Engine.is_editor_hint():
		RoomManager.rooms.erase(self)

func is_point_in_room(point: Vector2) -> bool:
	return false

func get_next_camera_position(camera_position: Vector2, camera_size: Vector2, focus_position: Vector2) -> Vector2:
	return camera_position

func get_anchor_positions() -> PackedVector2Array:
	return PackedVector2Array()

func drag_anchor(anchor_index: int) -> void:
	pass
