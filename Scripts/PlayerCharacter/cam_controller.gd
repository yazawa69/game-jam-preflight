extends Camera3D

@onready var cam_pivot: Marker3D = %CameraPivot

@export var mouse_sensitivity: float = .2

### for camera shake
@export var test_strength: float = 1.0
@export var shake_fade: float = 7.0
var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0
### ----------------

var cam_sensitivity: float = .25

var rotation_x: float = .0
var rotation_y: float = .0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # mouse is not visible on screen, and cant leave the window

func _input(event):
	#if Input.is_action_just_pressed("test"): shake_strength = test_strength 
	pass

func _process(delta):
	var mouse_movement = Input.get_last_mouse_velocity() # get mouse movement
	var joystick_movement = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)) # get right joystick movement
	if joystick_movement.length() <= .2 : joystick_movement = Vector2.ZERO # prevent camera from drifting
	
	# ternary operator: deciding between mouse input or joystick input
	var movement = joystick_movement * 1000.0 if mouse_movement.length() <= .1 else mouse_movement
	
	# set rotation
	rotation_x -= movement.y * cam_sensitivity * delta * mouse_sensitivity * .1
	rotation_y -= movement.x * cam_sensitivity * delta * mouse_sensitivity * .1
	
	# clamp vertical rotation
	rotation_x = clamp(rotation_x, deg_to_rad(-80), deg_to_rad(40))
	
	# apply rotation
	cam_pivot.rotation_degrees.x = rad_to_deg(rotation_x)
	cam_pivot.rotation_degrees.y = rad_to_deg(rotation_y)
	
	# camera shake
	if shake_strength > 0: camera_shake(delta)
	

func camera_shake(delta: float) -> void:
	var rando_offset = Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
	shake_strength = lerp(shake_strength, 0.0, shake_fade * delta)
	h_offset = rando_offset.x
	v_offset = rando_offset.y
