extends Area2D
class_name Hitbox

var enemy := false
var time := 0.1
var damage := 1
var dir := Vector2.ZERO
var hit : Array = []
func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(d):
	time -= d
	if time < 0: queue_free()
	for area in get_overlapping_areas():
		if area == self: continue
	
		if area is Hurtbox and not hit.has(area.get_parent()) and not area == get_parent().myhurtbox:
			if not (enemy and area.get_parent() is Enemy):
				area.get_parent().apply_damage(damage, dir)
				print(area)
				hit.append(area.get_parent())
				if get_parent().myparent.has_method("hit_confirmed"):
					get_parent().myparent.hit_confirmed()
			
			
	
