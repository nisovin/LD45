extends Node2D

onready var spawn_obj_pos = $Base/Position2D

func set_spawn_object(node):
	if spawn_obj_pos.get_child_count() > 0:
		spawn_obj_pos.get_child(0).queue_free()
	spawn_obj_pos.add_child(node)

func get_spawn_object():
	if spawn_obj_pos.get_child_count() > 0:
		return spawn_obj_pos.get_child(0)
	else:
		return null
	
func get_launch_direction():
	return $Base.global_transform.x

func _process(delta):
	$Base.look_at(get_global_mouse_position())
	if $Base.rotation_degrees > 30:
		$Base.rotation_degrees = 30
	elif $Base.rotation_degrees < -30:
		$Base.rotation_degrees = -30
	
