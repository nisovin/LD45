extends Node2D

export var max_hit_points = 10
onready var hit_points = max_hit_points

func hit():
	hit_points -= 1
	if hit_points == 0:
		get_parent().queue_free()
		get_parent().set_meta("freed", true)
		AudioManager.play_sound("part_dies")
		Game.ship.ship_controller.calculate_center()
	return float(hit_points) / float(max_hit_points)
