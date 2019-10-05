extends Node2D

func _process(delta):
	$Barrel.look_at(get_global_mouse_position())
	
func shoot_bullet(bullet):
	bullet.modulate = modulate
	bullet.global_position = $Barrel/Position2D.global_position
	bullet.apply_central_impulse($Barrel.global_transform.x * 500)
