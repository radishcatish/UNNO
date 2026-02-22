extends Enemy
@onready var stun_time: Timer = $StunTime
@onready var sprite: AnimatedSprite2D = $Sprite
var actionable: bool = true
@onready var jump_radius: Area2D = $JumpRadius
@onready var detect_radius: Area2D = $DetectRadius
var movementwave :float = randf()
var up: float = randf()
@onready var bughiss: AudioStreamPlayer2D = $Bughiss
@onready var bughurt: AudioStreamPlayer2D = $Bughurt
@onready var hitboxes: Node2D = $Hitboxes

const COLORSHADER = preload("res://shaders/colorshader.gdshader")
func _ready():
	health = 20
	max_health = 20
	var mat := ShaderMaterial.new()
	mat.shader = COLORSHADER
	mat.set_shader_parameter("original_colors", [Color(1, 0, 0), Color(0, 1, 0)])
	if randf() < .1:
		mat.set_shader_parameter("replace_colors", [Color.from_hsv(randf_range(0, .1), randf_range(0, 0.1), 1), Color.DARK_RED])
	else:
		mat.set_shader_parameter("replace_colors", [Color.from_hsv(randf_range(.8, 1), randf_range(.5, .9), randf_range(.7, .9)), Color.DARK_SLATE_GRAY])
	
	sprite.material = mat

func _physics_process(_d):
	velocity.y += 20
	velocity.x *= 0.9 if stun_time.is_stopped() and is_on_floor() else 1.0
	
	if actionable:
		if is_on_floor():
			if abs(velocity.x) > 20:
				sprite.play("crouch")
			else:
				sprite.play("idle")
		else:
			sprite.play("jump")
	else:
		if health > 0:
			sprite.play("hurt")
		else:
			sprite.play("die")
			actionable = false
			stun_time.start(999)
			$CollisionShape2D.disabled = true
	
	
	if actionable:
		up += randf_range(0.05, 0.1)
		movementwave = sin(up)
		if movementwave < -0.9:
			for area in detect_radius.get_overlapping_areas():
				if area.get_parent() is Player and is_on_floor():
					velocity.x = randf_range(70, 150) * sign(area.get_parent().global_position.x - global_position.x)
					sprite.flip_h = false if sign(area.get_parent().global_position.x - global_position.x) == 1 else true
			
			for area in jump_radius.get_overlapping_areas():
				if area.get_parent() is Player and is_on_floor():
					velocity.y = randf_range(-350, -300)
					velocity.x = randf_range(250, 350) * sign(area.get_parent().global_position.x - global_position.x)
					bughiss.play()
					hitboxes.spawn("circle", 20, 0, 0, 0, 0.5, Vector2(0, 0), 1)

	if is_on_floor() and stun_time.is_stopped():
		actionable = true
		
		
	move_and_slide()


func _on_hurt(damage: Variant, dir: Variant) -> void:
	health -= damage
	velocity.y = dir.y * -300
	velocity.y -= 300
	velocity.x = dir.x * 300
	actionable = false
	stun_time.start(0.5)
	sprite.flip_h = false if dir.x == -1 else true
	bughurt.play()
	if health <= 0:
		bughiss.play()
		
