extends Node2D

var hit_points = 10

func _process(delta):
	if Game.ship_launched:
		$Barrel.look_at(get_global_mouse_position())
	
func shoot_bullet(bullet):
	bullet.modulate = modulate
	bullet.global_position = $Barrel/Position2D.global_position
	bullet.apply_central_impulse($Barrel.global_transform.x * 500)

func hit():
	print("turret hit")
	hit_points -= 1
	if hit_points <= 0:
		get_parent().queue_free()
		get_parent().set_meta("freed", true)
		Game.ship.ship_controller.calculate_center()
