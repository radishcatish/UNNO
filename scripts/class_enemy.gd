extends CharacterBody2D
class_name Actor
var health: int = 10
var max_health: int = 10
signal hurt(damage, dir)

func apply_damage(damage: int, dir: Vector2) -> void:
	emit_signal("hurt", damage, dir)
