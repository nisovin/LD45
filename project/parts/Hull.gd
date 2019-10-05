extends Node2D

export var hit_points = 10

func hit():
	print("hull hit")
	hit_points -= 1
	if hit_points <= 0:
		get_parent().queue_free()
		get_parent().set_meta("freed", true)
		Game.ship.ship_controller.calculate_center()
