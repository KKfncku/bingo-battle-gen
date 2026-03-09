extends Button

@export var fruit_id := "strawberry"
@export var icon_texture: Texture2D
@export var board_area_path: NodePath = ^"../../../../World/BoardArea"
@export var icon_path: NodePath = ^"Icon"

var board: Node = null
@onready var icon_node: TextureRect = get_node_or_null(icon_path) as TextureRect

func _ready() -> void:
	if icon_node == null:
		push_warning("FruitButton: icon node not found: " + str(icon_path))
	else:
		icon_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if icon_texture != null:
			icon_node.texture = icon_texture
		elif icon_node.texture != null:
			icon_texture = icon_node.texture

	if board_area_path == NodePath(""):
		push_warning("FruitButton: board_area_path is empty")
		return

	board = get_node_or_null(board_area_path)
	if board == null:
		push_warning("FruitButton: board node not found: " + str(board_area_path))
		return

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if board and board.has_method("begin_drag"):
				board.begin_drag(fruit_id, icon_texture)
			accept_event()
		else:
			if board and board.has_method("end_drag"):
				board.end_drag()
			accept_event()
