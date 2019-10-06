extends Node

onready var universe = $Universe
onready var shipyard = $Universe/Shipyard

func _ready():
	shipyard.connect("ship_ready", self, "launch_ship")
	
func launch_ship(ship):
	# move ship
	var pos = ship.global_position
	var rot = ship.global_rotation
	ship.get_parent().remove_child(ship)
	universe.add_child(ship)
	ship.global_position = pos
	ship.global_rotation = rot
	
	# add controller
	var ship_controller = Game.ShipController.instance()
	ship.add_child(ship_controller)
	ship_controller.init()
	
	# prep ship
	ship.linear_velocity = Vector2.ZERO
	ship.angular_damp = -1
	ship.linear_damp = -1
	ship.update()
	
	# final settings
	AudioManager.play_sound("ship_done")
	Game.ship = ship
	Game.game_state = Game.STATE_LAUNCHED
	shipyard.destroy()
