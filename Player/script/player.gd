class_name marker3 extends CharacterBody3D

static var marker

@onready var RayCastDown = $idlestat/RayCastDown
@onready var woepon = $neck/Camera3D/woepon
@onready var fonarik = $neck/Camera3D/woepon/Fonarik
@onready var ray_cast_intaractive = $neck/Camera3D/RayCastIntaractive
@onready var marker_3d = $neck/Camera3D/Marker3D
@onready var control = $Control
@onready var neck = $neck
@onready var camera_3d = $neck/Camera3D
@onready var ray_cast_check = $idlestat/RayCastCheck
@onready var idlestat = $idlestat
@onready var crouchstat = $crouchstat
@onready var label = $Label
@onready var rigid_body_3d1 = $"."

# Constants
const SPRINTING = 6.3
const JUMP_VELOCITY = 4.5
const shake_size = 2.5
const shake_position = 0.0200

# Variables
var glubina_crouch = 0.5
var is_crouching = false
var shake_cashe = 0.0
var SPEED = 5.0
var crouch_speed = 3.0
var direction = Vector3.ZERO
var Base_Fov = 80.0
var Fov_Plus = 0.5
var pull_power = 17.0
var picke_object: Object
var stop: Object
@export var interaction_distance: float = 3.0
# Gravity setting
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	marker = marker_3d

func picked_object():
	var collider = ray_cast_intaractive.get_collider()
	if collider != null and collider is RigidBody3D:
		picke_object = collider
		picke_object.collision_layer = 0  # Disable collision layer
		fonarik.hide()

func remove_object():
	if picke_object != null:
		picke_object.collision_layer = 1  # Restore collision layer
		picke_object = null
		fonarik.show()

func _process(delta):
	if Input.is_action_just_pressed("ui_interact"):
		interact_with_object()
	var new_col = ray_cast_intaractive.get_collider()
	label.text = ""
	if new_col != null:
		if new_col is RigidBody3D:
			label.text = new_col.name

	var input_dir = Input.get_vector("a", "d", "w", "s")
	direction = lerp(direction, (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * 10.0)

	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 3.0)

	handle_neck_rotation(input_dir, delta)

	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	handle_jump(delta)
	handle_sprinting(delta)
	handle_crouch(delta)

	shake_cashe += delta * velocity.length() * float(is_on_floor())
	camera_3d.transform.origin = shake_camera(shake_cashe)

	move_and_slide()

	if picke_object != null:
		var a = picke_object.global_transform.origin
		var b = marker_3d.global_transform.origin
		picke_object.set_linear_velocity((b - a) * pull_power)

@warning_ignore("unused_parameter")
func handle_neck_rotation(input_dir, delta):
	if input_dir.x > 0:
		neck.rotation.z = lerp_angle(neck.rotation.z, deg_to_rad(-2), 0.05)
	elif input_dir.x < 0:
		neck.rotation.z = lerp_angle(neck.rotation.z, deg_to_rad(2), 0.05)
	else:
		neck.rotation.z = lerp_angle(neck.rotation.z, deg_to_rad(0), 0.05)

	if input_dir.y > 0:
		neck.rotation.x = lerp_angle(neck.rotation.x, deg_to_rad(-2), 0.05)
	elif input_dir.y < 0:
		neck.rotation.x = lerp_angle(neck.rotation.x, deg_to_rad(2), 0.05)
	else:
		neck.rotation.x = lerp_angle(neck.rotation.x, deg_to_rad(0), 0.05)

func handle_jump(delta):
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and !ray_cast_check.is_colliding() and !is_crouching:
		velocity.y = JUMP_VELOCITY
		crouchstat.disabled = false
		neck.position.y = lerp(neck.position.y, 0.6, 5 * delta)

func handle_sprinting(delta):
	if Input.is_action_pressed("shift") and Input.is_action_pressed("w") and !is_crouching and !ray_cast_check.is_colliding():
		var velocity_clampedi = clamp(velocity.length_squared(), 0.1, SPRINTING * 1.2)
		var torget_fov = Base_Fov + Fov_Plus * velocity_clampedi
		camera_3d.fov = lerp(camera_3d.fov, torget_fov, delta * 5.0)
		SPEED = SPRINTING
	else:
		SPEED = 5.0
		var torget_fov = Base_Fov
		camera_3d.fov = lerp(camera_3d.fov, torget_fov, delta * 5.0)

func handle_crouch(delta):
	if Input.is_action_just_pressed("ctrl"):
		is_crouching = !is_crouching
	if is_crouching and is_on_floor():
		SPEED = crouch_speed
		idlestat.disabled = true
		crouchstat.disabled = false
		neck.position.y = lerp(neck.position.y, 0.6 - glubina_crouch, 5 * delta)
	elif !ray_cast_check.is_colliding():
		idlestat.disabled = false
		crouchstat.disabled = true
		neck.position.y = lerp(neck.position.y, 0.6, 5 * delta)
	else:
		crouchstat.disabled = false
		idlestat.disabled = true
		SPEED = crouch_speed

func shake_camera(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * shake_size) * shake_position
	pos.x = cos(time * shake_size / 2) * shake_position
	return pos

func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("lclick"):
		if picke_object == null:
			picked_object()
		elif picke_object != null:
			remove_object()

	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("esc"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x / 300)
			camera_3d.rotate_x(-event.relative.y / 300)
			camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-65), deg_to_rad(90))

func interact_with_object():
	if $neck/Camera3D/RayCastIntaractive.is_colliding():
		var collider = $neck/Camera3D/RayCastIntaractive.get_collider()
		if collider and collider.has_method("interact"):
			collider.interact(self)  # Взаимодействие с объектом
