extends Node
@onready var beep: AudioStreamPlayer = $Beep

var vol = -20.0
func _ready() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), vol)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("volume_up"):
		beep.play()
		vol = clamp(vol + 2.0, -80.0, 0.0)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), vol)
		print("Volume: " + str(vol) + " dB")

	if Input.is_action_just_pressed("volume_down"):
		beep.play()
		vol = clamp(vol - 2.0, -80.0, 0.0)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), vol)
		print("Volume: " + str(vol) + " dB")
