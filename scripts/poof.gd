extends Node
@export var time : float = 1
@onready var poof: AudioStreamPlayer2D = $Poof

func _ready() -> void:
	poof.play()
	self.emitting = true

func _process(delta: float) -> void:
	time -= delta
	if time <= 0:
		free()
