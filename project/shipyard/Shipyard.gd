extends Node2D

signal ship_ready(node)

const constructor_speed = 800
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
var remaining_parts = [ 15, 10, 8 ]

var movement_dir = 0
var last_pressed = ""
var last_dir = 0

func _ready():
	gui.set_hull_count(remaining_parts[0])
	gui.set_thruster_count(remaining_parts[1])
	gui.set_turret_count(remaining_parts[2])
	yield(get_tree(), "idle_frame")
	prepare_next_part()
	start_hint_timers()
	
func start_hint_timers():
	yield(get_tree().create_timer(3), "timeout")
	if !released and Game.game_state == Game.STATE_BUILDING:
		GlobalGUI.show_hint("Click to release part")
	yield(get_tree().create_timer(8), "timeout")
	if !moved and Game.game_state == Game.STATE_BUILDING:
		GlobalGUI.show_hint("Use WASD to move around the shipyard")
	yield(get_tree().create_timer(8), "timeout")
	if !switched and Game.game_state == Game.STATE_BUILDING:
		GlobalGUI.show_hint("Press 1, 2, 3 to switch parts\n(or use buttons above)")
	yield(get_tree().create_timer(15), "timeout")
	if !launched and Game.game_state == Game.STATE_BUILDING:
		GlobalGUI.show_hint("Press L to launch")
	gui.show_launch_button()
	

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
	if Game.game_state == Game.STATE_BUILDING:
		var mass = 0
		var most_massive = null
		for child in $BuildArea.get_children():
			if child.mass > mass:
				mass = child.mass
				most_massive = child
		if most_massive != null:
			if most_massive.types["thruster"] == 0:
				GlobalGUI.show_error("Your ship needs at least one thruster")
			elif most_massive.types["turret"] == 0:
				GlobalGUI.show_error("Your ship needs at least one turret")
			else:
				for child in $BuildArea.get_children():
					if child != most_massive:
						child.queue_free()
				emit_signal("ship_ready", most_massive)
	
func destroy():
	# remove stuff
	gui.fade_out()
	$Cage.queue_free()
	# animate rails
	var tween = $Tween
	var top = $Rails/Top
	var bottom = $Rails/Bottom
	var left = $Rails/Left
	var right = $Rails/Right
	tween.interpolate_property(top, "rect_position:y", top.rect_position.y, top.rect_position.y - 200, 10, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(bottom, "rect_position:y", bottom.rect_position.y, bottom.rect_position.y + 200, 10, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(left, "rect_position:x", left.rect_position.x, left.rect_position.x - 200, 10, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(right, "rect_position:x", right.rect_position.x, right.rect_position.x + 200, 10, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(top, "modulate:a", 1.0, 0.0, 3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(bottom, "modulate:a", 1.0, 0.0, 3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(left, "modulate:a", 1.0, 0.0, 3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(right, "modulate:a", 1.0, 0.0, 3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(constructor, "modulate:a", 1.0, 0.0, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	# remove
	yield(get_tree().create_timer(3.2), "timeout")
	queue_free()
	
func _unhandled_input(event):
	if Game.game_state == Game.STATE_BUILDING:
		_process_input_actions(event)
		_process_input_movement(event)
	
func _process_input_actions(event):
	if event.is_action_pressed("fire") or event.is_action_pressed("thrust"):
		released = true
		var obj = constructor.get_spawn_object()
		if obj != null:
			launch_part(obj)
		
	elif event.is_action_pressed("launch_ship"):
		launched = true
		call_deferred("launch_ship")
		
	elif event.is_action_pressed("part_hull"):
		switched = true
		current_part = 0
		prepare_next_part()
	elif event.is_action_pressed("part_thruster"):
		switched = true
		current_part = 1
		prepare_next_part()
	elif event.is_action_pressed("part_turret"):
		switched = true
		current_part = 2
		prepare_next_part()
	elif event.is_action_pressed("color_plus"):
		var o = constructor.get_spawn_object()
		if o:
			o.cycle_color(1)
	elif event.is_action_pressed("color_minus"):
		var o = constructor.get_spawn_object()
		if o:
			o.cycle_color(-1)
		
func _process_input_movement(event):
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
		
	if event.is_action_pressed("move_right"):
		moved = true
		if side == "top":
			movement_dir = -1
		elif side == "bottom":
			movement_dir = 1
		elif last_pressed == "right":
			movement_dir = last_dir
		else:
			movement_dir = -last_dir
		last_pressed = "right"
	elif event.is_action_pressed("move_left"):
		moved = true
		if side == "top":
			movement_dir = 1
		elif side == "bottom":
			movement_dir = -1
		elif last_pressed == "left":
			movement_dir = last_dir
		else:
			movement_dir = -last_dir
		last_pressed = "left"
	elif event.is_action_pressed("move_up"):
		moved = true
		if side == "left":
			movement_dir = -1
		elif side == "right":
			movement_dir = 1
		elif last_pressed == "up":
			movement_dir = last_dir
		else:
			movement_dir = -last_dir
		last_pressed = "up"
	elif event.is_action_pressed("move_down"):
		moved = true
		if side == "left":
			movement_dir = 1
		elif side == "right":
			movement_dir = -1
		elif last_pressed == "down":
			movement_dir = last_dir
		else:
			movement_dir = -last_dir
		last_pressed = "down"
			
	elif event.is_action_released("move_right"):
		if !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_down") and !Input.is_action_pressed("move_up"):
			movement_dir = 0
	elif event.is_action_released("move_left"):
		if !Input.is_action_pressed("move_right") and !Input.is_action_pressed("move_down") and !Input.is_action_pressed("move_up"):
			movement_dir = 0
	elif event.is_action_released("move_up"):
		if !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_down") and !Input.is_action_pressed("move_right"):
			movement_dir = 0
	elif event.is_action_released("move_down"):
		if !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right") and !Input.is_action_pressed("move_up"):
			movement_dir = 0
			
	if movement_dir != 0:
		last_dir = movement_dir

func _process(delta):
	if movement_dir != 0:
		constructor_pather.offset += movement_dir * constructor_speed * delta
