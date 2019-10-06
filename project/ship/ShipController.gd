extends Node2D

signal ship_dead

var ship : RigidBody2D

var thrust_per_thruster = 2000

var last_fired = 0
var center := Vector2.ZERO

var thrusted = false
var shot = false

func init():
	ship = get_parent()
	ship.ship_controller = self
	calculate_center()
	
func calculate_center():
	var total = Vector2.ZERO
	var c = 0
	for child in ship.get_children():
		if (child is CollisionShape2D or child is CollisionPolygon2D) and !child.has_meta("freed"):
			total += child.position
			c += 1
	if c > 0:
		center = total / c
		position = center
	else:
		emit_signal("ship_dead")
	
func _process(delta):
	if Input.is_action_just_released("thrust"):
		for thruster in get_tree().get_nodes_in_group("thrusters"):
			thruster.stop()
			AudioManager.play_thrusters(false)
	
	if Input.is_action_pressed("fire"):
		shot = true
		if last_fired < OS.get_ticks_msec() - 75:
			last_fired = OS.get_ticks_msec()
			for turret in get_tree().get_nodes_in_group("turrets"):
				var cd_until = turret.get_meta("cd_until")
				if cd_until == null or cd_until < OS.get_ticks_msec():
					turret.set_meta("cd_until", OS.get_ticks_msec() + 300 + (randi() % 100))
					var bullet = Game.Bullet.instance()
					get_parent().get_parent().add_child(bullet)
					bullet.linear_velocity = ship.linear_velocity
					turret.shoot_bullet(bullet)
					AudioManager.play_sound("shoot")
					break
	
func _physics_process(delta):
	if Input.is_action_pressed("thrust"):
		thrusted = true
		var thrust = Vector2.ZERO
		for thruster in get_tree().get_nodes_in_group("thrusters"):
			thrust += thruster.fire()
		ship.applied_force = thrust * thrust_per_thruster
		AudioManager.play_thrusters(thrust != Vector2.ZERO)
	
	elif Input.is_action_pressed("brake"):
		ship.applied_force = -ship.linear_velocity * 100
		
	else:
		ship.applied_force = Vector2.ZERO
