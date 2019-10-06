extends CanvasLayer

onready var tween = $Tween
onready var hull_count = $Control/HBoxContainer/HullPanel/MarginContainer/Count
onready var thruster_count = $Control/HBoxContainer/ThrusterPanel/MarginContainer/Count
onready var turret_count = $Control/HBoxContainer/TurretPanel/MarginContainer/Count

func _ready():
	$Control/LaunchButton.visible = false
	$Control/LaunchButton.connect("pressed", self, "launch_button_pressed")

func set_hull_count(count):
	hull_count.text = str(count)
	
func set_thruster_count(count):
	thruster_count.text = str(count)
	
func set_turret_count(count):
	turret_count.text = str(count)

func show_launch_button():
	$Control/LaunchButton.visible = true

func launch_button_pressed():
	var key = InputEventAction.new()
	key.action = "launch_ship"
	key.pressed = true
	Input.parse_input_event(key)

func fade_out():
	tween.interpolate_property($Control, "modulate:a", 1.0, 0.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
