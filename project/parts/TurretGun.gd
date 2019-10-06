extends Node2D

var max_hit_points = 10
var hit_points = max_hit_points

func _process(delta):
	if Game.game_state == Game.STATE_LAUNCHED:
		$Barrel.look_at(get_global_mouse_position())
	
func shoot_bullet(bullet):
	bullet.modulate = modulate
	bullet.global_position = $Barrel/Position2D.global_position
	bullet.apply_central_impulse($Barrel.global_transform.x * 500)

func hit():
	hit_points -= 1
	if hit_points <= 0:
		get_parent().queue_free()
		get_parent().set_meta("freed", true)
		Game.ship.ship_controller.calculate_center()
		AudioManager.play_sound("part_dies")
	return float(hit_points) / float(max_hit_points)
