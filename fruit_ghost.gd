extends Node2D
var fruit_id := ""

@onready var icon: Sprite2D = $Icon

func set_texture(tex: Texture2D) -> void:
	icon.texture = tex

func _process(_delta: float) -> void:
	var viewport_size := get_viewport_rect().size
	var p = get_viewport().get_mouse_position()
	p.x = clamp(p.x, 0.0, viewport_size.x)
	p.y = clamp(p.y, viewport_size.y * (2.0 / 3.0), viewport_size.y)
	global_position = p

func _ready() -> void:
	$Icon.scale = Vector2(0.4, 0.4)
