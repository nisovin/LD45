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

func _ready():
	randomize()
	randomize()

func _input(event):
	if event.is_action_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		
