extends Camera2D

func reset():
	position = Vector2(640, 360)
	zoom = Vector2(1, 1)

func _process(delta):
	if Game.game_state == Game.STATE_MENU:
		position += Vector2.UP * 50 * delta
	elif Game.game_state == Game.STATE_LAUNCHED:
		if zoom.x < 1.5:
			zoom.x += delta * 0.05
			zoom.y = zoom.x
		var offset = (Game.ship.linear_velocity * 5).clamped(200)
		var target = Game.ship.ship_controller.global_position + offset
		var dir = target - global_position
		var len_sq = dir.length_squared()
		if len_sq > 25 * 25:
			position += dir * delta
