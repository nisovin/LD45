extends Node

const Shipyard = preload("res://shipyard/Shipyard.tscn")
const Hull = preload("res://parts/Hull.tscn")
const Thruster = preload("res://parts/Thruster.tscn")
const Turret = preload("res://parts/Turret.tscn")
const ShipController = preload("res://ship/ShipController.tscn")
const Bullet = preload("res://ship/Bullet.tscn")
const EnemyTurret = preload("res://universe/EnemyTurret.tscn")
const EnemyBullet = preload("res://universe/EnemyBullet.tscn")

enum { STATE_MENU, STATE_BUILDING, STATE_LAUNCHED, STATE_DEAD }

signal enemy_killed(enemy)

var game_state = STATE_MENU
var ship = null
var score = 0
var high_score = 0

func _ready():
	randomize()
	randomize()
	load_high_score()

func _input(event):
	if event.is_action_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		
func load_high_score():
	var file := File.new()
	if file.file_exists("user://highscore.dat"):
		var err = file.open("user://highscore.dat", File.READ)
		if err == OK:
			high_score = file.get_32()
			file.close()

func save_high_score():
	var file = File.new()
	var err = file.open("user://highscore.dat", File.WRITE)
	if err == OK:
		file.store_32(high_score)
		file.close()
	
