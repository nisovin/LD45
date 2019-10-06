extends CanvasLayer

onready var tween = $Tween
onready var hint_panel = $Control/HintPanel
onready var hint_label = $Control/HintPanel/Label

onready var hull_count = $Control/HBoxContainer/HullPanel/MarginContainer/Count
onready var thruster_count = $Control/HBoxContainer/ThrusterPanel/MarginContainer/Count
onready var turret_count = $Control/HBoxContainer/TurretPanel/MarginContainer/Count

func set_hull_count(count):
	hull_count.text = str(count)
	
func set_thruster_count(count):
	thruster_count.text = str(count)
	
func set_turret_count(count):
	turret_count.text = str(count)

func show_release_hint():
	hint_label.text = "Click to release part"
	tween_hint()
	
func show_move_hint():
	hint_label.text = "WASD to move"
	tween_hint()
	
func show_switch_hint():
	hint_label.text = "1/2/3 to switch parts"
	tween_hint()
	
func show_launch_hint():
	hint_label.text = "Press L to launch"
	tween_hint()

func tween_hint():
	tween.interpolate_property(hint_panel, "modulate:a", 0.0, 0.8, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(hint_panel, "modulate:a", 0.8, 0.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 1.5)
	tween.start()

func fade_out():
	tween.interpolate_property($Control, "modulate:a", 1.0, 0.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
