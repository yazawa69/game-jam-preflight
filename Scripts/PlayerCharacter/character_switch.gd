extends Node

@export var character_scenes: Array[PackedScene] = []
@export var spawn_position: Vector3 = Vector3.ZERO
@export var spawn_rotation: Vector3 = Vector3.ZERO

var current_index := 0
var current_character: PlayerCharacter = null

func _ready():
	if character_scenes.size() > 0:
		spawn_character(current_index)

func _input(event):
	if event.is_action_pressed("switch_character"):
		switch_character()

func spawn_character(index: int):
	var character_scene = character_scenes[index]
	var instance = character_scene.instantiate() as PlayerCharacter
	instance.set_position(spawn_position)
	instance.set_rotation(spawn_rotation)
	add_child(instance)
	current_character = instance

func switch_character():
	if character_scenes.size() == 0:
		return

	# Calculate next index
	var next_index = (current_index + 1) % character_scenes.size()

	# Save current position & rotation
	var pos = current_character.global_transform.origin
	var rot = current_character.global_transform.basis.get_euler()

	# Queue old character for deletion
	if current_character:
		current_character.call_deferred("queue_free")

	# Spawn new character at old transform
	var new_character = character_scenes[next_index].instantiate() as PlayerCharacter
	new_character.set_position(pos)
	new_character.set_rotation(rot)
	add_child(new_character)

	current_character = new_character
	current_index = next_index
