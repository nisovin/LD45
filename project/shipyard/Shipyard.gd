extends Node2D

signal ship_ready(node)

const Parts = [
	preload("res://parts/Hull.tscn"),
	preload("res://parts/Thruster.tscn"),
	preload("res://parts/Turret.tscn")
]
const ShipController = preload("res://ship/ShipController.tscn")

onready var constructor_path_legth = $Path2D.curve.get_baked_length()
onready var constructor_pather = $Path2D/PathFollow2D
onready var constructor = $Path2D/PathFollow2D/Constructor

var constructor_speed = 500
var part_launch_speed = 3000

var current_part = 0
var movement_dir = 0

func _ready():
	randomize()
	
	yield(get_tree(), "idle_frame")
	prepare_next_part()

func prepare_next_part():
	var obj = Parts[current_part].instance()
	obj.init()
	obj.set_static()
	constructor.set_spawn_object(obj)

func launch_part(obj):
	var pos = obj.global_position
	var rot = obj.global_rotation
	obj.get_parent().remove_child(obj)
	$BuildArea.add_child(obj)
	obj.global_position = pos
	obj.global_rotation = rot
	obj.set_rigid()
	obj.apply_central_impulse(constructor.get_launch_direction() * part_launch_speed)
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
		var ship_controller = ShipController.instance()
		most_massive.add_child(ship_controller)
		ship_controller.init()
		$Cage.queue_free()
		$Path2D.queue_free()
		most_massive.linear_velocity = Vector2.ZERO
		most_massive.angular_damp = -1
		most_massive.linear_damp = -1
		set_process(false)
		Game.ship_launched = true
		Game.ship = most_massive
		most_massive.update()
	
func destroy_shipyard():
	pass

func _process(delta):
	if Input.is_action_just_pressed("fire") or Input.is_action_just_pressed("thrust"):
		print("fire!")
		var obj = constructor.get_spawn_object()
		if obj != null:
			launch_part(obj)
		
	if Input.is_action_just_pressed("launch_ship"):
		call_deferred("launch_ship")
		
	if Input.is_action_just_pressed("part_hull"):
		current_part = 0
		prepare_next_part()
	if Input.is_action_just_pressed("part_thruster"):
		current_part = 1
		prepare_next_part()
	if Input.is_action_just_pressed("part_turret"):
		current_part = 2
		prepare_next_part()
	
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
		if side == "top":
			movement_dir = -1
		else:
			movement_dir = 1
	if Input.is_action_just_pressed("move_left"):
		if side == "top":
			movement_dir = 1
		else:
			movement_dir = -1
	if Input.is_action_just_pressed("move_up"):
		if side == "left":
			movement_dir = -1
		else:
			movement_dir = 1
	if Input.is_action_just_pressed("move_down"):
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
