extends Node2D
var fruit_id := ""

@onready var icon: Sprite2D = $Icon

func set_texture(tex: Texture2D) -> void:
	icon.texture = tex

func _process(_delta: float) -> void:
	var p = get_viewport().get_mouse_position()
	p.x = clamp(p.x, 0.0, 720.0)
	p.y = clamp(p.y, 620.0, 900.0)
	global_position = p

func _ready() -> void:
	$Icon.scale = Vector2(0.4, 0.4)
