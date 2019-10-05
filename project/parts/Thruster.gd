extends Node2D

onready var thruster = $Thruster
onready var clearance = $Thruster/ClearanceRayCast
onready var particles = $Thruster/Particles2D

var ok_to_fire = false
var hit_points = 10

func _process(delta):
	if Game.ship_launched:
		thruster.look_at(get_global_mouse_position())
		if thruster.rotation_degrees > 45:
			thruster.rotation_degrees = 45
			ok_to_fire = false
		elif thruster.rotation_degrees < -45:
			thruster.rotation_degrees = -45
			ok_to_fire = false
		else:
			ok_to_fire = true

func fire():
	if ok_to_fire and !clearance.is_colliding():
		if !particles.emitting:
			particles.emitting = true
		return thruster.global_transform.x
	particles.emitting = false
	return Vector2.ZERO
		
func stop():
	particles.emitting = false
	
func hit():
	print("thruster hit")
	hit_points -= 1
	if hit_points <= 0:
		get_parent().queue_free()
		get_parent().set_meta("freed", true)
		Game.ship.ship_controller.calculate_center()
	
