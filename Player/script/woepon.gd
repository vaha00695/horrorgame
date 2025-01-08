extends Node3D
@onready var woepon = $"."

var mous_mov
var sway_treshold = 10
var sway_lerp = 10
@export var sway_left : Vector3
@export var sway_right : Vector3
@export var sway_normal : Vector3
@export var sway_y : Vector3



func _input(event):
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			woepon.rotate_x(-event.relative.y/1000)
			woepon.rotation.x = clamp(woepon.rotation.x,deg_to_rad(-10), deg_to_rad(10))
		mous_mov = -event.relative.x
func _process(delta):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if mous_mov != null:
			if mous_mov > sway_treshold:
				rotation = lerp(rotation, sway_left, sway_lerp * delta)
			elif mous_mov < -sway_treshold:
				rotation = lerp(rotation, sway_right, sway_lerp * delta)
			else:
				rotation = lerp(rotation, sway_normal, sway_lerp * delta)
				
