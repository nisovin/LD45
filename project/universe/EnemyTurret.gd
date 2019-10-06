extends RigidBody2D

onready var bullet_spawn = $Barrel/Position2D

var attack_range = 1000
var bullet_speed = 1000
var cooldown = 1000

var max_health = 5
var health = 5
var last_attack = 0

func _ready():
	connect("body_shape_entered", self, "_on_collision")

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

func _on_collision(body_id, body, body_shape, local_shape):
	if !is_queued_for_deletion():
		if body.is_in_group("player_bullets"):
			health -= 1
			body.queue_free()
		elif body.is_in_group("parts"):
			health -= 10
		if health <= 0:
			Game.emit_signal("enemy_killed", self)
			queue_free()
		else:
			modulate.g = float(health) / max_health
			modulate.b = float(health) / max_health
