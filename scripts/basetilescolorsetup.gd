extends TileMapLayer
const COLORSHADER = preload("res://shaders/colorshader.gdshader")


func _ready() -> void:
	var outline_color = Color.from_hsv(randf(), 0.2, randf_range(.9, 1))
	var head_color = Color.from_hsv(outline_color.h - 0.05, 0.4, randf_range(.1, .3))
	var bg_color = Color.from_hsv(head_color.h, 0.6, randf_range(0, .1))
	
	var mat := ShaderMaterial.new()
	mat.shader = COLORSHADER
	mat.set_shader_parameter("original_colors", [Color(1, 0, 0), Color(0, 1, 0)])
	mat.set_shader_parameter("replace_colors", [outline_color, head_color])
	RenderingServer.set_default_clear_color(bg_color)
	material = mat
