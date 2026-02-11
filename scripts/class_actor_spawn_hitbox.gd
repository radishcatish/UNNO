extends Node2D
#how to spawn a circle hitbox:
# hitboxes.spawn("circle", 1, 0, 1, 1, 1)
# type, radius, unused, xpos, ypos, time

@export var myparent : Node
@export var myhurtbox : Node
const HITBOX = preload("uid://d0qbv01611bi")

func spawn(type: String, xsize: float, ysize: float, xpos: float, ypos: float, time: float):
	var area = HITBOX.instantiate()
	area.position = Vector2(xpos, ypos)
	var col = CollisionShape2D.new()
	if type == "circle":
		var circle = CircleShape2D.new()
		circle.radius = xsize
		col.shape = circle
		

	self.add_child(area)
	area.add_child(col)
	await get_tree().create_timer(time).timeout
	area.queue_free()
