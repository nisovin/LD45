extends Node

const Hull = preload("res://parts/Hull.tscn")
const Thruster = preload("res://parts/Thruster.tscn")
const Turret = preload("res://parts/Turret.tscn")
const ShipController = preload("res://ship/ShipController.tscn")
const EnemyTurret = preload("res://universe/EnemyTurret.tscn")
const EnemyBullet = preload("res://universe/EnemyBullet.tscn")

enum { STATE_MENU, STATE_BUILDING, STATE_LAUNCHED, STATE_DEAD }

var game_state = STATE_BUILDING
var ship = null

func _ready():
	randomize()
	randomize()
