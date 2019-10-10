extends CanvasLayer

onready var hint = $Control/HBoxContainer/Hint
onready var error = $Control/HBoxContainer2/Error
onready var tween = $Tween
onready var error_tween = $ErrorTween

func show_hint(text):
	hint.text = text
	tween.interpolate_property(hint, "modulate:a", 0.0, 0.8, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(hint, "modulate:a", 0.8, 0.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 3.5)
	tween.start()

func show_error(text):
	error.text = text
	error_tween.stop_all()
	error_tween.interpolate_property(error, "modulate:a", 0.0, 0.8, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	error_tween.interpolate_property(error, "modulate:a", 0.8, 0.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 3.5)
	error_tween.start()
