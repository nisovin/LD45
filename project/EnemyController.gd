extends Node2D

const min_spawn_distance = 2000
const max_spawn_distance = 3000
const despawn_distance_sq = 3500 * 3500
const max_turrets = 100

const min_spacing_initial = 300
const min_spacing_min = 100
const min_spacing_interval = 50

onready var turrets = $Turrets

var min_spacing
var min_spacing_sq

func _ready():
	min_spacing = min_spacing_initial
	min_spacing_sq = min_spacing * min_spacing
	$SpawnTimer.connect("timeout", self, "_on_spawn_timer")
	$SpawnTimer.start()
	$DifficultyTimer.connect("timeout", self, "_on_difficulty_timer")
	$DifficultyTimer.start()

func reset():
	pass

func spawn_turret():
	if Game.ship.linear_velocity == Vector2.ZERO:
		return false
	var dir = Game.ship.linear_velocity.normalized()
	dir = dir.rotated(deg2rad(randf() * 160 - 80))
	var dist = ((max_spawn_distance - min_spawn_distance) * randf()) + min_spawn_distance
	var pos = Game.ship.ship_controller.global_position + (dir * dist)
	for turret in turrets.get_children():
		if turret.global_position.distance_squared_to(pos) < min_spacing_sq:
			return false
	var turret = Game.EnemyTurret.instance()
	turrets.add_child(turret)
	turret.global_position = pos
	print("spawn", turrets.get_child_count())
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
				print("delete", turrets.get_child_count())

func _on_difficulty_timer():
	print("diff")
	min_spacing -= min_spacing_interval
	if min_spacing < min_spacing_min:
		min_spacing = min_spacing_min
	min_spacing_sq = min_spacing * min_spacing
