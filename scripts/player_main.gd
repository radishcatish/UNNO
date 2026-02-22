extends Actor
class_name Player
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hitboxes: Node2D = $Hitboxes
@onready var stun_timer: Timer = $StunTime
@onready var inv_timer: Timer = $InvTime

var last_on_floor := 10
var last_off_floor := 10
var last_on_wall := 10
var last_wall_normal := 0.0

var invtime := 2.0
var stuntime := .3
var gravity := 30.0
var jump_strength := 600.0
var movement_speed := 600.0
var base_damage := 5
enum PlayerState {GENERAL, ATTACKING, OUCH}
var state := PlayerState.GENERAL
func _ready():
	health = 100
	max_health = 100
	
	sprite.frame_changed.connect(_frame_changed)
	sprite.animation_finished.connect(_anim_finished)
func _physics_process(_d):

	last_on_floor = 0 if is_on_floor() else last_on_floor + 1
	last_off_floor = 0 if not is_on_floor() else last_off_floor + 1
	last_on_wall = 0 if is_on_wall_only() else last_on_wall + 1
	last_wall_normal = get_wall_normal().x if get_wall_normal().x != 0 else last_wall_normal
	if not state == PlayerState.OUCH:
		velocity.y += gravity
		velocity.y = clamp(velocity.y, -INF, 200) if is_on_wall_only() else velocity.y
		velocity.y = 0.0 if I.last_z_release == 1 and velocity.y < 0 else velocity.y
		if I.last_z_press <= 5 and not state == PlayerState.ATTACKING:
			var success = false
			if last_on_floor < 5:
				last_on_floor = 6
				success = true
			if last_on_wall <= 5:
				last_on_wall = 6
				velocity.x = sign(last_wall_normal) * movement_speed
				success = true
			if success:
				sprite.jumpsound()
				velocity.y = -jump_strength - movement_speed / 5
				I.last_z_press = 6
				
		if I.shift_pressed:
			var target_speed = I.d.x * movement_speed
			if abs(velocity.x) < abs(target_speed) or sign(velocity.x) != sign(target_speed):
				velocity.x = move_toward(velocity.x, target_speed, 80)
		else:
			velocity.x = move_toward(velocity.x, I.d.x * movement_speed / 2, 80)
		velocity.y = clamp(velocity.y, -INF, 1000)
	else:
		velocity.y += gravity
		velocity.x = move_toward(velocity.x, 0, 30)
		if stun_timer.is_stopped():
			state = PlayerState.GENERAL
			velocity.x = 0
	move_and_slide()

	if state == PlayerState.GENERAL and not sprite.animation.contains("attack") and I.last_x_press < 5:
		if I.d.y == -1 and not is_on_floor():
			sprite.play("attackdown")
			state = PlayerState.ATTACKING
			hitboxes.spawn("circle", 30, 0, 5, 45, 0.2, Vector2(sprite.dir, -1), base_damage)
			velocity.x = movement_speed  * sprite.dir
			if velocity.y < movement_speed / 2:
				velocity.y = movement_speed / 2
			else:
				velocity.y += movement_speed / 2
		elif I.d.y == 1:
			sprite.play("attackup")
			velocity.y = 0.0 if velocity.y > 1.0 else velocity.y - movement_speed / 10.0
			
			state = PlayerState.ATTACKING
			hitboxes.spawn("circle", 35, 0, 0, -50, 0.15, Vector2(0, 1), base_damage)
		else:
			sprite.play("attackforward")
			state = PlayerState.ATTACKING
			hitboxes.spawn("circle", 35, 0, 55, 5, 0.15, Vector2(sprite.dir, 0), base_damage)

func _frame_changed():
	pass
func _anim_finished():
	if sprite.animation.contains("attack"):
		sprite.play("none")
		state = PlayerState.GENERAL
func hit_confirmed():
	if state == PlayerState.ATTACKING:
		sprite.slashsound()
		if sprite.animation == "attackdown":
			velocity.y = -jump_strength
		if sprite.animation == "attackup":
			velocity.y = 500
		if sprite.animation == "attackforward":
			velocity.x = sprite.dir * -600
func _on_hurt(damage: int, dir: Vector2) -> void:
	if not inv_timer.is_stopped(): return
	health -= damage
	stun_timer.start(stuntime)
	inv_timer.start(invtime)
	state = PlayerState.OUCH
	velocity.x = -400 * sprite.dir
	velocity.y = -300
	
	sprite.ouchsound()
