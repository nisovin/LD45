extends StaticBody2D

onready var bullet_spawn = $Barrel/Position2D

var attack_range = 800
var bullet_speed = 800
var cooldown = 1000

var health = 100
var last_attack = 0

func _process(delta):
	if Game.game_state == Game.STATE_LAUNCHED:
		var ship_pos = Game.ship.ship_controller.global_position
		$Barrel.look_at(ship_pos)
		if last_attack < OS.get_ticks_msec() - cooldown:
			var v = ship_pos - global_position
			if v.length_squared() < attack_range * attack_range:
				shoot(v)
				last_attack = OS.get_ticks_msec()

func shoot(dir: Vector2):
	var bullet = Game.EnemyBullet.instance()
	get_parent().get_parent().add_child(bullet)
	bullet.global_position = bullet_spawn.global_position
	dir = dir.normalized().rotated(randf() * .2 - .1)
	bullet.apply_central_impulse(dir * bullet_speed)
