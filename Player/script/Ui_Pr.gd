extends Control
@onready var sprite_2d = $Sprite2D
# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	var screen_size = get_viewport_rect().size
	sprite_2d.position = Vector2(screen_size.x / 2, screen_size.y / 2)
	sprite_2d.scale = Vector2(0.0050,0.01)
