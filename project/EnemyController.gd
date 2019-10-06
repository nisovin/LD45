extends Node2D

const min_spawn_distance = 1200
const max_spawn_distance = 2000
const despawn_distance_sq = 2200 * 2200
const max_turrets = 100

const min_spacing_initial = 300
const min_spacing_min = 100
const min_spacing_interval = 25

const enemy_health_initial = 5
const enemy_health_interval = 5
const enemy_health_max = 50

onready var turrets = $Turrets

var min_spacing
var min_spacing_sq
var enemy_health

func _ready():
	$SpawnTimer.connect("timeout", self, "_on_spawn_timer")
	$DifficultyTimer.connect("timeout", self, "_on_difficulty_timer")

func reset():
	for turret in turrets.get_children():
		turret.queue_free()
	$SpawnTimer.stop()
	$DifficultyTimer.stop()

func start():
	min_spacing = min_spacing_initial
	min_spacing_sq = min_spacing * min_spacing
	enemy_health = enemy_health_initial
	$SpawnTimer.start()
	$DifficultyTimer.start()
	var count = 10
	var dir = Vector2.UP
	dir = dir.rotated(randf())
	for i in count:
		spawn_turret(dir)
		dir = dir.rotated(deg2rad(360 / count))

func spawn_turret(dir = null, force = false):
	if !force and Game.ship.linear_velocity == Vector2.ZERO:
		return false
	if dir == null:
		dir = Game.ship.linear_velocity.normalized()
		dir = dir.rotated(deg2rad(randf() * 160 - 80))
	var dist = ((max_spawn_distance - min_spawn_distance) * randf()) + min_spawn_distance
	var pos = Game.ship.ship_controller.global_position + (dir * dist)
	if !force:
		for turret in turrets.get_children():
			if turret.global_position.distance_squared_to(pos) < min_spacing_sq:
				return false
	var turret = Game.EnemyTurret.instance()
	turrets.add_child(turret)
	turret.global_position = pos
	turret.max_health = enemy_health
	turret.health = enemy_health
	return true

func _on_spawn_timer():
	if Game.game_state == Game.STATE_LAUNCHED:
		if turrets.get_child_count() < max_turrets:
			var attempts = 0
			var success = false
			while attempts < 3 and !success:
				success = spawn_turret()
				attempts += 1
		var pos = Game.ship.ship_controller.global_position
		for turret in turrets.get_children():
			if turret.global_position.distance_squared_to(pos) > despawn_distance_sq:
				turret.queue_free()

func _on_difficulty_timer():
	if Game.game_state == Game.STATE_LAUNCHED:
		min_spacing -= min_spacing_interval
		if min_spacing < min_spacing_min:
			min_spacing = min_spacing_min
		min_spacing_sq = min_spacing * min_spacing
		enemy_health += enemy_health_interval
		if enemy_health > enemy_health_max:
			enemy_health = enemy_health_max
