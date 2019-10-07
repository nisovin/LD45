extends CanvasLayer

onready var hint = $Control/HBoxContainer/Hint
onready var tween = $Tween

func show_hint(text):
	hint.text = text
	tween.interpolate_property(hint, "modulate:a", 0.0, 0.8, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(hint, "modulate:a", 0.8, 0.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 2.5)
	tween.start()
