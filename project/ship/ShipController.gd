extends Node2D

const Bullet = preload("res://ship/Bullet.tscn")

var ship : RigidBody2D

var thrust_per_thruster = 2000

var last_fired = 0
var center := Vector2.ZERO

func init():
	ship = get_parent()
	ship.ship_controller = self
	calculate_center()
	position = center
	
func calculate_center():
	var total = Vector2.ZERO
	for child in ship.get_children():
		if (child is CollisionShape2D or child is CollisionPolygon2D) and !child.has_meta("freed"):
			total += child.position
	center = total / (ship.get_child_count() - 1)
	print("center ", center)
	
func _process(delta):
	if Input.is_action_just_released("thrust"):
		for thruster in get_tree().get_nodes_in_group("thrusters"):
			thruster.stop()
	
	if Input.is_action_pressed("fire"):
		if last_fired < OS.get_ticks_msec() - 250:
			last_fired = OS.get_ticks_msec()
			for turret in get_tree().get_nodes_in_group("turrets"):
				print(turret)
				var bullet = Bullet.instance()
				get_parent().get_parent().add_child(bullet)
				bullet.linear_velocity = ship.linear_velocity
				turret.shoot_bullet(bullet)
	
func _physics_process(delta):
	if Input.is_action_pressed("thrust"):
		var thrust = Vector2.ZERO
		for thruster in get_tree().get_nodes_in_group("thrusters"):
			thrust += thruster.fire()
		print(thrust)
		ship.applied_force = thrust * thrust_per_thruster
	
	elif Input.is_action_pressed("brake"):
		ship.applied_force = -ship.linear_velocity * 100
		
	else:
		ship.applied_force = Vector2.ZERO
