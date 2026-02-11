extends Actor
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hitboxes: Node2D = $Hitboxes

var last_on_floor := 10
var last_off_floor := 10
var last_on_wall := 10
var last_wall_normal := 0.0
enum PlayerState {GENERAL, ATTACKING}
var state := PlayerState.GENERAL
func _ready():
	health = 8
	sprite.frame_changed.connect(_frame_changed)
	sprite.animation_finished.connect(_anim_finished)
func _physics_process(_d):
	
	last_on_floor = 0 if is_on_floor() else last_on_floor + 1
	last_off_floor = 0 if not is_on_floor() else last_off_floor + 1
	last_on_wall = 0 if is_on_wall_only() else last_on_wall + 1
	last_wall_normal = get_wall_normal().x if get_wall_normal().x != 0 else last_wall_normal
	
	velocity.y += 30
	velocity.y = clamp(velocity.y, -INF, 200) if is_on_wall_only() else velocity.y
	velocity.y = 0 if I.last_z_release == 1 and velocity.y < 0 else velocity.y
	if I.last_z_press <= 5 and not state == PlayerState.ATTACKING:
		var success = false
		if last_on_floor < 5:
			last_on_floor = 6
			success = true
		if last_on_wall <= 5:
			last_on_wall = 6
			velocity.x = sign(last_wall_normal) * 700
			success = true
		if success:
			velocity.y = -700
			I.last_z_press = 6


	if I.shift_pressed:
		var target_speed = I.d.x * 600
		if abs(velocity.x) < abs(target_speed) or sign(velocity.x) != sign(target_speed):
			velocity.x = move_toward(velocity.x, target_speed, 80)
	else:
		velocity.x = move_toward(velocity.x, I.d.x * 300, 80)
	velocity.y = clamp(velocity.y, -INF, 1000)
	move_and_slide()
	
	if state == PlayerState.GENERAL and I.last_x_press < 5:
		if I.d.y == -1 and not is_on_floor():
			state = PlayerState.ATTACKING
			hitboxes.spawn("circle", 30, 0, 5, 45, 0.15)
		elif I.d.y == 1:
			state = PlayerState.ATTACKING
			hitboxes.spawn("circle", 35, 0, 0, -50, 0.15)
		else:
			state = PlayerState.ATTACKING
			hitboxes.spawn("circle", 35, 0, 55, 5, 0.15)
func _frame_changed():
	pass
func _anim_finished():
	if sprite.animation.contains("attack"):
		sprite.play("none")
		state = PlayerState.GENERAL
func hit_confirmed():
	if sprite.animation == "attackdown":
		velocity.y = -700
	await get_tree().create_timer(0.08).timeout
	sprite.slashsound()
func _on_hurt(damage: int) -> void:
	health -= damage
