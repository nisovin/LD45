extends KinematicBody2D

var acceleration = 100
var max_speed = 100

var velocity = Vector2()

func _physics_process(delta):	
	if Input.is_action_pressed("move_up"):
		velocity += Vector2.UP * acceleration * delta
	if Input.is_action_pressed("move_down"):
		velocity += Vector2.DOWN * acceleration * delta
	if Input.is_action_pressed("move_left"):
		velocity += Vector2.LEFT * acceleration * delta
	if Input.is_action_pressed("move_right"):
		velocity += Vector2.RIGHT * acceleration * delta
	if Input.is_action_pressed("brake"):
		velocity -= velocity.clamped(acceleration * 3) * delta
	velocity = velocity.clamped(max_speed)
	print(velocity)
	move_and_slide(velocity)
