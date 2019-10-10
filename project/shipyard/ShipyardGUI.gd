extends CanvasLayer

onready var tween = $Tween
onready var hull_count = $Control/HBoxContainer/HullButton/MarginContainer/Count
onready var thruster_count = $Control/HBoxContainer/ThrusterButton/MarginContainer/Count
onready var turret_count = $Control/HBoxContainer/TurretButton/MarginContainer/Count

func _ready():
	$Control/LaunchButton.visible = false
	$Control/HBoxContainer/HullButton.connect("pressed", self, "button_pressed", ["part_hull"])
	$Control/HBoxContainer/ThrusterButton.connect("pressed", self, "button_pressed", ["part_thruster"])
	$Control/HBoxContainer/TurretButton.connect("pressed", self, "button_pressed", ["part_turret"])
	$Control/LaunchButton.connect("pressed", self, "button_pressed", ["launch_ship"])

func set_hull_count(count):
	hull_count.text = str(count)
	
func set_thruster_count(count):
	thruster_count.text = str(count)
	
func set_turret_count(count):
	turret_count.text = str(count)

func show_launch_button():
	$Control/LaunchButton.visible = true

func button_pressed(action):
	var key = InputEventAction.new()
	key.action = action
	key.pressed = true
	Input.parse_input_event(key)

func fade_out():
	tween.interpolate_property($Control, "modulate:a", 1.0, 0.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
