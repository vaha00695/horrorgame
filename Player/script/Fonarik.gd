extends Node3D

@onready var spot_light_3d = $SpotLight3D
var fonar_offon = true
func _input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if Input.is_action_just_pressed("f"):
			if fonar_offon:
				spot_light_3d.hide()
				fonar_offon = false
			else:
				spot_light_3d.show()
				fonar_offon = true
