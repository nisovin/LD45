extends Node

onready var universe = $Universe
onready var camera = $Universe/Camera
onready var enemy_controller = $Universe/Enemy
onready var tween = $Tween
onready var overlay = $MainGUI/Overlay
onready var main_menu = $MainGUI/Control/MainMenu
onready var start_button = $MainGUI/Control/MainMenu/StartGameButton
onready var final_score = $MainGUI/Control/FinalScoreLabel
var shipyard = null

func _ready():
	start_button.connect("pressed", self, "start_game")
	$MainGUI/Control/MainMenu/CreditsButton.connect("pressed", self, "show_credits")
	$MainGUI/Control/CreditsPopup/VBoxContainer/HBoxContainer/MarginContainer/CloseButton.connect("pressed", self, "hide_credits")
	$MainGUI/Control/CreditsPopup/VBoxContainer/MarginContainer/CreditsText.connect("meta_clicked", self, "open_credits_link")
	$MainGUI/Control/MainMenu/QuitButton.connect("pressed", self, "quit_game")
	AudioManager.fade_music("main", "in")
	
func start_game():
	main_menu.visible = false
	tween.interpolate_property(overlay, "modulate:a", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(get_tree().create_timer(1.1), "timeout")
	camera.reset()
	shipyard = Game.Shipyard.instance()
	shipyard.connect("ship_ready", self, "launch_ship")
	universe.add_child(shipyard)
	Game.game_state = Game.STATE_BUILDING
	tween.interpolate_property(overlay, "modulate:a", 1, 0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	
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
	
	# music and sound
	AudioManager.fade_music("main", "out")
	AudioManager.fade_music("fight", "in")
	AudioManager.play_sound("ship_done")
	
	# final settings
	Game.ship = ship
	Game.game_state = Game.STATE_LAUNCHED
	shipyard.destroy()
	shipyard = null
	enemy_controller.start()

func end_game():
	if Game.game_state == Game.STATE_DEAD:
		return
	Game.game_state = Game.STATE_DEAD
	final_score.text = "Final Score: " + str(Game.ship.ship_controller.score)
	tween.interpolate_property(final_score, "modulate:a", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(get_tree().create_timer(3), "timeout")
	AudioManager.fade_music("fight", "out")
	tween.interpolate_property(overlay, "modulate:a", 0, 1, 3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(get_tree().create_timer(3.5), "timeout")
	final_score.modulate.a = 0
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
	Game.game_state = Game.STATE_MENU
	tween.interpolate_property(overlay, "modulate:a", 1, 0, 3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	AudioManager.fade_music("main", "in")
	yield(get_tree().create_timer(3.5), "timeout")
	main_menu.visible = true

func show_credits():
	$MainGUI/Control/CreditsPopup.popup_centered()
	
func open_credits_link(meta):
	OS.shell_open(meta)
	print(meta)
	
func hide_credits():
	$MainGUI/Control/CreditsPopup.hide()

func quit_game():
	get_tree().quit()
