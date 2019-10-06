extends "res://parts/PartType.gd"

func _process(delta):
	if Game.game_state == Game.STATE_LAUNCHED:
		$Barrel.look_at(get_global_mouse_position())
	
func shoot_bullet(bullet):
	bullet.modulate = modulate
	bullet.global_position = $Barrel/Position2D.global_position
	bullet.apply_central_impulse($Barrel.global_transform.x * 500)
