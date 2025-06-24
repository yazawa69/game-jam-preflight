class_name PlayerCharacter
extends CharacterBody3D
@onready var _state_machine = %StateMachine # state machine node inside the player
@onready var player_camera: Camera3D = %PlayerCam
@onready var char_visual: Node3D = %VisualAppearance

var _camera_forward: Vector3
var _camera_right: Vector3

func _ready() -> void:
	# Initialize the state machine, passing a reference of the player to the states,
	# that way they can move and react accordingly
	_state_machine.init(self)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	

func _unhandled_input(event: InputEvent) -> void:
	_state_machine.process_input(event)
	if Input.is_action_just_pressed("test"): 
		pass

func _physics_process(delta: float) -> void:
	_state_machine.process_physics(delta)

func _process(delta: float) -> void:
	_state_machine.process_frame(delta)

func _get_cam_rotation() -> void:
	# get camera transform in world space
	_camera_forward = player_camera.global_basis.z
	_camera_right = player_camera.global_basis.x
	# we dont want the y components
	_camera_forward.y = 0.0
	_camera_right.y = 0.0
	# normalize to retrieve direction vectors
	_camera_forward.normalized()
	_camera_right.normalized()
