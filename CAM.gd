extends Camera2D

@export var camSpeed: float = 5.0
@export var maxOffset: Vector2 = Vector2(500, 500)
@export var player: CharacterBody2D

func _ready():
	if player:
		position = Vector2.ZERO  # Ensuring the initial position is reset to zero

func _process(delta):
	if player:
		var targetPos = Vector2.ZERO  # Start with Vector2.ZERO as your base

		if Input.is_action_pressed("camtoggle"):
			var mouseOffset = get_global_mouse_position() - player.position
			mouseOffset.x = clamp(mouseOffset.x, -maxOffset.x, maxOffset.x)
			mouseOffset.y = clamp(mouseOffset.y, -maxOffset.y, maxOffset.y)

		position = position.lerp(targetPos, camSpeed * delta)
