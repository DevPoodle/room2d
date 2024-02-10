@tool
extends Room
class_name RectangleRoom

enum anchor_type {
	top_left, bottom_left, top_right, bottom_right, center
}

@export var boundaries := Rect2(0.0, 0.0, 32.0, 32.0) : set = set_boundaries

func is_point_in_room(point: Vector2) -> bool:
	return boundaries.abs().has_point(point)

func get_next_camera_position(camera_position: Vector2, camera_size: Vector2, focus_position: Vector2) -> Vector2:
	var top_left := boundaries.position + camera_size / 2.0
	var top_right := boundaries.end - camera_size / 2.0
	return focus_position.clamp(top_left, top_right)

func get_anchor_positions() -> PackedVector2Array:
	return PackedVector2Array([
		boundaries.position,
		boundaries.position + Vector2(0.0, boundaries.size.y),
		boundaries.position + Vector2(boundaries.size.x, 0.0),
		boundaries.position + boundaries.size,
		boundaries.position + 0.5 * boundaries.size
	])

func drag_anchor(anchor_index: int) -> void:
	if anchor_index == -1:
		return
	
	var mouse_position := get_global_mouse_position()
	var snapping := ProjectSettings.get_setting("debug/shapes/rooms/snapping", Vector2i(32, 32))
	
	match anchor_index:
		anchor_type.top_left:
			boundaries.size -= (mouse_position - boundaries.position).snapped(snapping)
			boundaries.position = mouse_position.snapped(snapping)
		
		anchor_type.bottom_left:
			boundaries.size.x -= snappedi(mouse_position.x - boundaries.position.x, snapping.x)
			boundaries.size.y = snappedi(mouse_position.y - boundaries.position.y, snapping.y)
			boundaries.position.x = snappedi(mouse_position.x, snapping.x)
		
		anchor_type.top_right:
			boundaries.size.y -= snappedi(mouse_position.y - boundaries.position.y, snapping.y)
			boundaries.size.x = snappedi(mouse_position.x - boundaries.position.x, snapping.x)
			boundaries.position.y = snappedi(mouse_position.y, snapping.y)
		
		anchor_type.bottom_right:
			boundaries.size = (mouse_position - boundaries.position).snapped(snapping)
		
		anchor_type.center:
			boundaries.position = (mouse_position - boundaries.size * 0.5).snapped(snapping)

func set_boundaries(new_boundaries: Rect2) -> void:
	boundaries = new_boundaries
	queue_redraw()

func _draw() -> void:
	if Engine.is_editor_hint():
		var drawable_rect := Rect2(boundaries.position - global_position, boundaries.size)
		var color := ProjectSettings.get_setting("debug/shapes/rooms/primary_color", Color.BLACK)
		draw_rect(drawable_rect, color, false, -1.0)
