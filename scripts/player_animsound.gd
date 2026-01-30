extends AnimatedSprite2D
@onready var main: CharacterBody2D = $".."
@onready var step_1: AudioStreamPlayer2D = $Step1
@onready var step_2: AudioStreamPlayer2D = $Step2
@onready var swish: AudioStreamPlayer2D = $Swish

@onready var jump: AudioStreamPlayer2D = $Jump

@onready var dir = I.d.x

func _ready() -> void:
	self.frame_changed.connect(_on_frame_changed)
	self.animation_changed.connect(_on_animation_changed)
func _process(_d):

	dir = I.d.x if I.d.x != 0 else dir

	flip_h = false if dir == 1 else true
	Camera.target = main.global_position
	if main.last_off_floor == 1:
		stepsound()
	if I.last_z_press <= 8:
		if main.last_on_floor == 8:
			jumpsound()
		if main.last_on_wall == 8:
			jumpsound()
			stepsound()
	match main.state:
		main.PlayerState.GENERAL:
			if main.is_on_floor():
				if ((dir == 1 and main.velocity.x < 0) or (dir == -1 and main.velocity.x > 0)) and I.shift_pressed:
					play("skidrun")
					
				elif abs(main.velocity.x) > 300:
					if animation != "run" and animation != "skidrun":
						play("startrun")
						await animation_finished
					play("run", abs(main.velocity.x) / 600)
				elif abs(main.velocity.x) > 10:
					if animation == "run":
						play("startrun")
						await animation_finished
					if not I.shift_pressed:
						play("walk")
				else:
					play("idle")
			else:
				if main.is_on_wall():
					play("onwall")
				else:
					play("midair")
				var t = clamp((-main.velocity.y + 300.0) / 500.0, 0.0, 1.0)
				frame = int(t * 4)
func _on_frame_changed():
	match animation:
		"walk":
			if frame==2:stepsound()
		"run":
			if frame==0:stepsound()
			if frame==3:stepsound()
			
func _on_animation_changed():
	match animation:
		"skid":
			stepsound()
			
	
	
func random_sfx(a, b):
	if randf() < .5:
		a.pitch_scale = randf_range(.9,1.1)
		a.play()
	else:
		b.pitch_scale = randf_range(.9,1.1)
		b.play()
func jumpsound():
	random_sfx(jump, jump)
func stepsound():
	random_sfx(step_1, step_2)
func swishsound():
	random_sfx(swish, swish)
