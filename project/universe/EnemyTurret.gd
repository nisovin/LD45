extends StaticBody2D

var attack_range = 800
var bullet_speed = 800
var cooldown = 1000

var health = 100
var last_attack = 0

func _process(delta):
	if Game.ship_launched:
		var ship_pos = Game.ship.global_position -                                   Game.ship.ship_controller.center
		$Barrel.look_at(ship_pos)
		if last_attack < OS.get_ticks_msec() - cooldown:
			var v = ship_pos - global_position
			if v.length_squared() < attack_range * attack_range:
				shoot(v)
				last_attack = OS.get_ticks_msec()

func shoot(dir):
	var bullet = Game.EnemyBullet.instance()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.apply_central_impulse(dir.normalized() * bullet_speed)
