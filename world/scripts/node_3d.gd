extends Node3D

var Set_Box = preload("res://world/scene/BoxInteractive.tscn")

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if Input.is_action_pressed("rclick"):
			var box = Set_Box.instantiate()
			get_parent().add_child(box)
			box.global_position = marker3.marker.global_position
