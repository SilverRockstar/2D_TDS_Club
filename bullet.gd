extends RigidBody2D

@export var decay_time = 2.0  # Time in seconds before the bullet disappears
var initial_velocity: Vector2

func _ready():
	var timer = Timer.new()
	timer.wait_time = decay_time
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))  # Use Callable for connect
	add_child(timer)
	timer.start()

	if initial_velocity:
		linear_velocity = initial_velocity  # Set the initial velocity

func _on_Timer_timeout():
	queue_free()  # This will remove the bullet instance from the scene
