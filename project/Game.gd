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

var game_state = STATE_MENU
var ship = null

func _ready():
	randomize()
	randomize()
