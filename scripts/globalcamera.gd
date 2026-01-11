extends Camera2D

var target: Vector2
var speed: float = 1
func _physics_process(_delta):
	position = target

func teleport(pos: Vector2):
	position = pos
