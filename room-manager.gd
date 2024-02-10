extends Node

var rooms : Array[Room] = []
var cameras : Array[RoomCamera2D] = []

func _physics_process(delta: float) -> void:
	for camera in cameras:
		if camera == null or !camera.enabled:
			continue
		
		var is_camera_in_room := false
		for room in rooms:
			if room.is_point_in_room(camera.focus.position):
				camera.move_towards(room.get_next_camera_position(camera.position, Vector2(camera.get_viewport().size) / camera.zoom, camera.focus.position), delta)
				is_camera_in_room = true
				break
		if !is_camera_in_room:
			camera.handle_position_manually()
