extends Node

onready var universe = $Universe
onready var camera = $Universe/Camera
onready var enemy_controller = $Universe/Enemy
onready var tween = $Tween
var shipyard = null

func _ready():
	$MainGUI/Control/Button.connect("pressed", self, "start_game")
	
func start_game():
	$MainGUI/Control.visible = false
	camera.reset()
	shipyard = Game.Shipyard.instance()
	shipyard.connect("ship_ready", self, "launch_ship")
	universe.add_child(shipyard)
	Game.game_state = Game.STATE_BUILDING
	
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
	ship_controller.connect("ship_dead", self, "end_game")
	
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

func end_game():
	print("end game")
	if Game.game_state == Game.STATE_DEAD:
		print("already ended")
		return
	Game.game_state = Game.STATE_DEAD
	tween.interpolate_property(universe, "modulate:a", 1.0, 0.0, 3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(get_tree().create_timer(3.5), "timeout")
	camera.reset()
	enemy_controller.reset()
	if shipyard != null:
		shipyard.queue_free()
		shipyard = null
	if Game.ship != null:
		Game.ship.queue_free()
		Game.ship = null
	for bullet in get_tree().get_nodes_in_group("player_bullets"):
		bullet.queue_free()
	for bullet in get_tree().get_nodes_in_group("enemy_bullets"):
		bullet.queue_free()
	universe.modulate.a = 1.0
	Game.game_state = Game.STATE_MENU
