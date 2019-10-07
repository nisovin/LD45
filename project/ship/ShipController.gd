extends Node2D

signal ship_dead

onready var score_label = $CanvasLayer/Control/PanelScore/Score

var ship : RigidBody2D

var thrust_per_thruster = 2500

var last_fired = 0
var last_action = 0
var center := Vector2.ZERO

var thrusted = false
var braked = false
var shot = false

var score = 0

func init():
	ship = get_parent()
	ship.ship_controller = self
	start_hint_timers()
	calculate_center()
	Game.connect("enemy_killed", self, "enemy_killed")
	
func start_hint_timers():
	yield(get_tree().create_timer(3), "timeout")
	if !thrusted:
		GlobalGUI.show_hint("Press Space Bar to fire thrusters")
	yield(get_tree().create_timer(6), "timeout")
	if !braked:
		GlobalGUI.show_hint("Press Shift to use inertial brakes")
	yield(get_tree().create_timer(6), "timeout")
	if !shot:
		GlobalGUI.show_hint("Click to fire weapons")
	
func calculate_center():
	last_action = OS.get_ticks_msec()
	var total = Vector2.ZERO
	var mass = 0
	var c = 0
	for child in ship.get_children():
		if (child is CollisionShape2D or child is CollisionPolygon2D) and !child.has_meta("freed"):
			total += child.position
			if child.has_meta("mass"):
				mass += child.get_meta("mass")
			c += 1
	if c > 0:
		center = total / c
		position = center
		ship.mass = mass
	else:
		emit_signal("ship_dead", score)
	
func enemy_killed(enemy):
	score += enemy.max_health
	score_label.text = str(score)
	last_action = OS.get_ticks_msec()
	
func _process(delta):
	if Input.is_action_just_released("thrust"):
		for thruster in get_tree().get_nodes_in_group("thrusters"):
			thruster.stop()
			AudioManager.play_thrusters(false)
	
	if Input.is_action_pressed("fire"):
		shot = true
		if last_fired < OS.get_ticks_msec() - 50:
			last_fired = OS.get_ticks_msec()
			for turret in get_tree().get_nodes_in_group("turrets"):
				var cd_until = turret.get_meta("cd_until") if turret.has_meta("cd_until") else 0
				if cd_until < OS.get_ticks_msec():
					turret.set_meta("cd_until", OS.get_ticks_msec() + 300 + (randi() % 100))
					var bullet = Game.Bullet.instance()
					get_parent().get_parent().add_child(bullet)
					bullet.linear_velocity = ship.linear_velocity
					turret.shoot_bullet(bullet)
					AudioManager.play_sound("shoot")
					break
					
	if last_action < OS.get_ticks_msec() - 60000:
		emit_signal("ship_dead", score)
	
func _physics_process(delta):
	if Input.is_action_pressed("thrust"):
		thrusted = true
		var thrust = Vector2.ZERO
		for thruster in get_tree().get_nodes_in_group("thrusters"):
			thrust += thruster.fire()
		if thrust != Vector2.ZERO:
			last_action = OS.get_ticks_msec()
		ship.applied_force = thrust * thrust_per_thruster
		AudioManager.play_thrusters(thrust != Vector2.ZERO)
	
	elif Input.is_action_pressed("brake"):
		braked = true
		ship.applied_force = -ship.linear_velocity * 100
		
	else:
		ship.applied_force = Vector2.ZERO
