extends Node2D

signal ship_ready(node)

const constructor_speed = 500
const part_launch_speed = 3000
var parts = [
	Game.Hull,
	Game.Thruster,
	Game.Turret
]

onready var gui = $ShipyardGUI
onready var constructor_path_legth = $Path2D.curve.get_baked_length()
onready var constructor_pather = $Path2D/PathFollow2D
onready var constructor = $Path2D/PathFollow2D/Constructor

var released = false
var moved = false
var switched = false
var launched = false

var current_part = 0
var movement_dir = 0
var remaining_parts = [ 15, 10, 8 ]

func _ready():
	gui.set_hull_count(remaining_parts[0])
	gui.set_thruster_count(remaining_parts[1])
	gui.set_turret_count(remaining_parts[2])
	yield(get_tree(), "idle_frame")
	prepare_next_part()
	start_hint_timers()
	
func start_hint_timers():
	yield(get_tree().create_timer(3), "timeout")
	if !released:
		gui.show_release_hint()
	yield(get_tree().create_timer(6), "timeout")
	if !moved:
		gui.show_move_hint()
	yield(get_tree().create_timer(6), "timeout")
	if !switched:
		gui.show_switch_hint()
	yield(get_tree().create_timer(20), "timeout")
	if !launched:
		gui.show_launch_hint()
	

func prepare_next_part():
	if remaining_parts[current_part] > 0:
		var obj = parts[current_part].instance()
		obj.init()
		obj.set_static()
		constructor.set_spawn_object(obj)
		AudioManager.play_sound("part_appear")

func launch_part(obj):
	var pos = obj.global_position
	var rot = obj.global_rotation
	obj.get_parent().remove_child(obj)
	$BuildArea.add_child(obj)
	obj.global_position = pos
	obj.global_rotation = rot
	obj.set_rigid()
	obj.apply_central_impulse(constructor.get_launch_direction() * part_launch_speed)
	AudioManager.play_sound("part_release")
	remaining_parts[current_part] -= 1
	if current_part == 0:
		gui.set_hull_count(remaining_parts[current_part])
	elif current_part == 1:
		gui.set_thruster_count(remaining_parts[current_part])
	elif current_part == 2:
		gui.set_turret_count(remaining_parts[current_part])
	yield(get_tree().create_timer(0.5), "timeout")
	prepare_next_part()
	
func launch_ship():
	var mass = 0
	var most_massive = null
	for child in $BuildArea.get_children():
		if child.mass > mass:
			mass = child.mass
			most_massive = child
	for child in $BuildArea.get_children():
		if child != most_massive:
			child.queue_free()
	if most_massive != null:
		emit_signal("ship_ready", most_massive)
	
func destroy():
	set_process(false)
	$Cage.queue_free()
	$Path2D.queue_free()
	queue_free()

func _process(delta):
	_process_actions(delta)
	_process_movement(delta)
	
func _process_actions(delta):
	if Input.is_action_just_pressed("fire") or Input.is_action_just_pressed("thrust"):
		released = true
		var obj = constructor.get_spawn_object()
		if obj != null:
			launch_part(obj)
		
	if Input.is_action_just_pressed("launch_ship"):
		launched = true
		call_deferred("launch_ship")
		
	if Input.is_action_just_pressed("part_hull"):
		switched = true
		current_part = 0
		prepare_next_part()
	if Input.is_action_just_pressed("part_thruster"):
		switched = true
		current_part = 1
		prepare_next_part()
	if Input.is_action_just_pressed("part_turret"):
		switched = true
		current_part = 2
		prepare_next_part()
	
	
func _process_movement(delta):
	var facing = constructor.global_transform.x
	var side = "?"
	if facing.x > 0.9:
		side = "left"
	elif facing.x < -0.9:
		side = "right"
	elif facing.y > 0.9:
		side = "top"
	elif facing.y < -0.9:
		side = "bottom"
		
	if Input.is_action_just_pressed("move_right"):
		moved = true
		if side == "top":
			movement_dir = -1
		else:
			movement_dir = 1
	if Input.is_action_just_pressed("move_left"):
		moved = true
		if side == "top":
			movement_dir = 1
		else:
			movement_dir = -1
	if Input.is_action_just_pressed("move_up"):
		moved = true
		if side == "left":
			movement_dir = -1
		else:
			movement_dir = 1
	if Input.is_action_just_pressed("move_down"):
		moved = true
		if side == "left":
			movement_dir = 1
		else:
			movement_dir = -1
	if Input.is_action_just_released("move_right"):
		if !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_down") and !Input.is_action_pressed("move_up"):
			movement_dir = 0
	if Input.is_action_just_released("move_left"):
		if !Input.is_action_pressed("move_right") and !Input.is_action_pressed("move_down") and !Input.is_action_pressed("move_up"):
			movement_dir = 0
	if Input.is_action_just_released("move_up"):
		if !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_down") and !Input.is_action_pressed("move_right"):
			movement_dir = 0
	if Input.is_action_just_released("move_down"):
		if !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right") and !Input.is_action_pressed("move_up"):
			movement_dir = 0

	constructor_pather.offset += movement_dir * constructor_speed * delta
