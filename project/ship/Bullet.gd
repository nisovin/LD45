extends RigidBody2D

func _ready():
	connect("body_entered", self, "_on_hit")
	
func _on_hit(node):
	pass
