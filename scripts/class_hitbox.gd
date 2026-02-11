extends Area2D
class_name Hitbox


var time
var damage := 1
var knockback := Vector2.ZERO
var hit : Array = []
func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(d):
	time -= d
	if time < 0: queue_free()
	for area in get_overlapping_areas():
		
		if  area == self: continue
	
		if area is Hurtbox and not hit.has(area.get_parent()) and not area == get_parent().myhurtbox:
			area.get_parent().apply_damage(1)
			hit.append(area.get_parent())
			get_parent().myparent.hit_confirmed()
			
			
	
