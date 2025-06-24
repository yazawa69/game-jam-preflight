## credits for this script go to theshaggydev
## https://github.com/theshaggydev/the-shaggy-dev-projects/blob/main/projects/godot-4/state-machines/src/state_machine/state.gd
## https://youtu.be/oqFbZoA2lnU and https://youtu.be/bNdFXooM1MQ

class_name State
extends Node

@export_group("Anim Transitioning")
@export var _blend_to_position: Vector2 # position inside the blendspace2D inside the anim tree
@export var transition_speed: float = 1.0 # animation transition speed
var _blend_from_position: Vector2

# for debuging to measure time
var start_time = 0.0
var elapsed_time = 0.0

var gravity: int = ProjectSettings.get_setting("physics/3d/default_gravity") # 9.81 m/s

# Hold a reference to the parent so that it can be controlled by the state
var parent: CharacterBody3D

func enter() -> void:
	### for debugging
	print(parent.name, ": ", self.name) # prints state name
	start_timer() # starts timer
	### ------------
	pass

func exit() -> void:
	### for debugging
	stop_timer() # stops timer and prints duration of state
	### -------------
	pass

func process_input(event: InputEvent) -> State:
	return null

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	return null

func start_timer():
	start_time = Time.get_ticks_msec()

func stop_timer():
	elapsed_time = (Time.get_ticks_msec() - start_time) / 1000.0
	print("elapsed time: ", elapsed_time)
