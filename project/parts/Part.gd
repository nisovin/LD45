extends RigidBody2D

var dead = false
var ship_controller = null
var layer = 0
var mask = 0

func _ready():
	print("ready")
	connect("body_shape_entered", self, "_on_part_collision")

func init(type = null, color = null):
	var shape
	if get_child_count() > 0:
		if type == null:
			type = get_child(randi() % get_child_count()).name
		for child in get_children():
			if child.name == type:
				shape = child
			else:
				child.visible = false
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
	layer = collision_layer
	mask = collision_mask
	collision_layer = 0
	collision_mask = 0
	
func set_rigid():
	mode = RigidBody2D.MODE_RIGID
	contact_monitor = true
	collision_layer = layer
	collision_mask = mask
	
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
	update()
	print("ok")
	
func add_part(part, pos, rot):
	add_child(part)
	part.global_position = pos
	part.global_rotation = rot

func _on_part_collision(body_id, body, body_shape, local_shape):
	print("collide")
	if !Game.ship_launched:
		if body.is_in_group("parts") and !dead and !body.dead:
			if body.mass > mass:
				body.glob_onto(self)
			else:
				glob_onto(body)
	else:
		if body.is_in_group("enemy_bullets"):
			var owner_id = shape_find_owner(local_shape)
			var owner = shape_owner_get_owner(owner_id)
			body.queue_free()
			var part = owner.get_child(0)
			if part.has_method("hit"):
				part.hit()
			print("shot ", local_shape, " ", owner_id, " ", owner)

func _draw():
	for i in get_child_count():
		var a = get_child(i)
		if a is CollisionShape2D or a is CollisionPolygon2D:
			var j = i + 1
			while j < get_child_count():
				var b = get_child(j)
				if b is CollisionShape2D or b is CollisionPolygon2D:
					if a.position.distance_squared_to(b.position) < 15000:
						draw_line(a.position, b.position, Color(0.2, 0.2, 0.2, 0.7), 6, true)
				j += 1
			draw_circle(a.position, 10, Color(0.3, 0.3, 0.3, 0.9))
