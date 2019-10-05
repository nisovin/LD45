extends RigidBody2D

var dead = false

func _ready():
	print("ready")
	connect("body_entered", self, "_on_part_collision")

func init(type = null, color = null):
	var shape
	if get_child_count() > 0:
		if type == null:
			type = get_child(randi() % get_child_count()).name
		for child in get_children():
			if child.name == type:
				shape = child
			else:
				child.queue_free()
	else:
		shape = get_child(0)
	if color == null:
		color = Color.white.from_hsv(randf(), 0.9, 0.7)
	_recurse_color(shape, color)
	
func _recurse_color(node, color):
	if node is Sprite:
		node.modulate = color
	for child in node.get_children():
		_recurse_color(child, color)
	
func set_static():
	mode = RigidBody2D.MODE_STATIC
	contact_monitor = false
	collision_layer = 0
	collision_mask = 0
	
func set_rigid():
	mode = RigidBody2D.MODE_RIGID
	contact_monitor = true
	collision_layer = 1
	collision_mask = 1
	
func glob_onto(projectile):
	mass += projectile.mass
	var dir = projectile.linear_velocity.normalized() * 5
	dir += linear_velocity.normalized() * -2
	for child in projectile.get_children():
		var pos = child.global_position
		var rot = child.global_rotation
		var copy = child.duplicate()
		call_deferred("add_part", copy, pos + dir, rot)
	projectile.queue_free()
	projectile.dead = true
	print("ok")
	
func add_part(part, pos, rot):
	add_child(part)
	part.global_position = pos
	part.global_rotation = rot

func _on_part_collision(body):
	print("collide")
	if body.is_in_group("parts") and !dead and !body.dead:
		if body.mass > mass:
			body.glob_onto(self)
		else:
			glob_onto(body)
