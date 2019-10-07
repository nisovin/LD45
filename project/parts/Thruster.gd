extends "res://parts/PartType.gd"

const max_angle = 60

onready var thruster = $Thruster
onready var clearance = $Thruster/ClearanceRayCast
onready var particles = $Thruster/Particles2D

var ok_to_fire = false
var last_fired = 0

func _process(delta):
	if Game.game_state == Game.STATE_LAUNCHED:
		thruster.look_at(get_global_mouse_position())
		if thruster.rotation_degrees > max_angle:
			thruster.rotation_degrees = max_angle
			ok_to_fire = false
		elif thruster.rotation_degrees < -max_angle:
			thruster.rotation_degrees = -max_angle
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
	
