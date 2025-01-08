extends Node


var other_scene = preload("res://world/scene/rigid_body_3d.tscn")
var other_node = other_scene.instance()

func _ready():
	if other_node.has_method("get_my_variable"):
		var my_variable = other_node.get_my_variable()
	else:
		print("The other scene does not have 'my_variable'.")
