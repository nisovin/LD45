extends Node2D

var max_hit_points = 10
var hit_points = 10

func hit(amt = 1):
	hit_points -= amt
	if hit_points <= 0:
		get_parent().queue_free()
		get_parent().set_meta("freed", true)
		AudioManager.play_sound("part_dies")
		Game.ship.ship_controller.calculate_center()
	return float(hit_points) / float(max_hit_points)
