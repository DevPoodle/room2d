@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton("RoomManager", "res://addons/rooms-2d/room-manager.gd")
	
	create_project_setting("debug/shapes/rooms/snapping", Vector2i(32,32))
	create_project_setting("debug/shapes/rooms/primary_color", Color.BLACK)
	create_project_setting("debug/shapes/rooms/accent_color", Color.WHITE)

func _exit_tree() -> void:
	ProjectSettings.save()
	remove_autoload_singleton("RoomManager")

func create_project_setting(path : String, default : Variant) -> void:
	if ProjectSettings.has_setting(path):
		return

	ProjectSettings.set_setting(path, default)
	ProjectSettings.set_initial_value(path, default)

var room : Room
var anchors := PackedVector2Array()
var dragged_anchor := -1

func _handles(object: Object) -> bool:
	return (object is Room)

func _edit(object: Object) -> void:
	room = object
	update_overlays()

func _forward_canvas_draw_over_viewport(overlay: Control) -> void:
	if !room or !is_instance_valid(room):
		return
	
	var transform : Transform2D = room.get_viewport_transform() * room.get_canvas_transform()
	var handles := room.get_anchor_positions() as PackedVector2Array
	
	anchors = []
	for handle in handles:
		anchors.append(transform * handle)
	
	var primary_color = ProjectSettings.get_setting("debug/shapes/rooms/primary_color", Color.BLACK)
	var accent_color = ProjectSettings.get_setting("debug/shapes/rooms/accent_color", Color.WHITE)
	
	for anchor in anchors:
		overlay.draw_circle(anchor, 3.0, accent_color)
		overlay.draw_arc(anchor, 6.0, 0.0, TAU, 16, primary_color, 3.0, true)

func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if !room or !is_instance_valid(room) or !room.visible:
		return false
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if dragged_anchor == -1 and event.is_pressed():
			for anchor in anchors:
				if (anchor - event.position).length() > 10.0:
					continue
				dragged_anchor = anchors.find(anchor, 0)
				return true
		elif dragged_anchor != -1 and !event.is_pressed():
			room.drag_anchor(dragged_anchor)
			dragged_anchor = -1
			return true
	elif event is InputEventMouseMotion and dragged_anchor != -1:
		room.drag_anchor(dragged_anchor)
		update_overlays()
		return true
	
	return false
