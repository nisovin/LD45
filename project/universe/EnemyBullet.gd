extends RigidBody2D

var fired = 0

func _ready():
	fired = OS.get_ticks_msec()
	
func _process(delta):
	if fired < OS.get_ticks_msec() - 30000:
		queue_free()
	
