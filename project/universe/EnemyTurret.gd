extends RigidBody2D

onready var bullet_spawn = $Barrel/Position2D

var bullet_speed = 1000
var cooldown = 1000

var max_health = 5
var health = 5
var last_attack = 0
var in_range = false
var dead = false

func _ready():
	connect("body_shape_entered", self, "_on_collision")

func _process(delta):
	if Game.game_state == Game.STATE_LAUNCHED and in_range and !dead:
		var ship_pos = Game.ship.ship_controller.global_position
		$Barrel.look_at(ship_pos)
		if last_attack < OS.get_ticks_msec() - cooldown:
			shoot(ship_pos - global_position)
			last_attack = OS.get_ticks_msec()

func shoot(dir: Vector2):
	var bullet = Game.EnemyBullet.instance()
	get_parent().get_parent().add_child(bullet)
	bullet.global_position = bullet_spawn.global_position
	dir = dir.normalized().rotated(randf() * .2 - .1)
	bullet.apply_central_impulse(dir * bullet_speed)
	AudioManager.play_sound("enemy_shoot")

func _on_collision(body_id, body, body_shape, local_shape):
	if !dead:
		if body.is_in_group("player_bullets"):
			health -= 1
			body.queue_free()
		elif body.is_in_group("parts"):
			health -= 10
		if health <= 0:
			dead = true
			collision_layer = 0
			collision_mask = 0
			$CollisionShape2D.queue_free()
			Game.emit_signal("enemy_killed", self)
			AudioManager.play_sound("enemy_die")
			$Base.visible = false
			$Barrel.visible = false
			$Particles2D.emitting = true
			yield(get_tree().create_timer(2), "timeout")
			queue_free()
		else:
			modulate.g = float(health) / max_health
			modulate.b = float(health) / max_health
