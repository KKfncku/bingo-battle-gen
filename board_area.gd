extends Node2D

@export var fruit_unit_scene: PackedScene
@export var bullet_scene: PackedScene
@export var ghost_scene: PackedScene

@onready var slots := [
	$SlotsLine/Slot1,
	$SlotsLine/Slot2,
	$SlotsLine/Slot3,
	$SlotsLine/Slot4,
	$SlotsLine/Slot5
]

# 当前坑位里放着什么水果
var slot_to_unit := {}  # Marker2D -> FruitUnit

# 拖拽状态
var dragging_ghost = null
var dragging_fruit_id := ""

# 拖拽来源：button / board
var drag_source := ""
var drag_from_slot: Marker2D = null
var drag_from_unit: FruitUnit = null

# 合成表
var merge_map := {
	"strawberry": "banana",
	"apple": "pomegranate",
	"lemon": "pineapple",
	"banana": "durian"
}

# 棋盘上点选水果的判定半径
var pick_radius := 48.0


func _process(_delta: float) -> void:
	# 只要正在拖拽，并且左键松开，就自动结算
	if dragging_ghost != null and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		end_drag()


func _unhandled_input(event: InputEvent) -> void:
	# 点击棋盘上的已有水果，开始二次拖动
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# 如果当前已经在拖，不处理
			if dragging_ghost != null:
				return

			var mouse_pos = get_viewport().get_mouse_position()
			var picked = _find_unit_under_mouse(mouse_pos)
			if picked != null:
				var picked_slot: Marker2D = picked["slot"]
				var picked_unit: FruitUnit = picked["unit"]
				begin_drag_from_board(picked_slot, picked_unit)
				get_viewport().set_input_as_handled()


func place_fruit(fruit_id: String) -> void:
	var slot := _find_first_empty_slot()
	if slot == null:
		print("No empty slot")
		return
	_spawn_to_specific_slot(slot, fruit_id)


func begin_drag(fruit_id: String, icon_tex: Texture2D) -> void:
	# 兼容你现在 FruitButton.gd 里调用的入口
	begin_drag_from_button(fruit_id, icon_tex)


func begin_drag_from_button(fruit_id: String, icon_tex: Texture2D) -> void:
	cancel_drag()

	if ghost_scene == null:
		print("ghost_scene not set")
		return

	drag_source = "button"
	dragging_fruit_id = fruit_id
	drag_from_slot = null
	drag_from_unit = null

	dragging_ghost = ghost_scene.instantiate()
	add_child(dragging_ghost)

	# FruitGhost.gd 里已经有 fruit_id 的话就赋值
	dragging_ghost.fruit_id = fruit_id

	if icon_tex != null and dragging_ghost.has_method("set_texture"):
		dragging_ghost.set_texture(icon_tex)


func begin_drag_from_board(slot: Marker2D, unit: FruitUnit) -> void:
	cancel_drag()

	if ghost_scene == null:
		print("ghost_scene not set")
		return

	drag_source = "board"
	dragging_fruit_id = unit.fruit_id
	drag_from_slot = slot
	drag_from_unit = unit

	# 原水果先停火并隐藏，坑位先腾空
	unit.set_state_attacking(false)
	unit.visible = false
	slot_to_unit.erase(slot)

	dragging_ghost = ghost_scene.instantiate()
	add_child(dragging_ghost)
	dragging_ghost.fruit_id = dragging_fruit_id

	# 如果 FruitGhost 能接贴图，尽量把原水果帧贴进去
	if dragging_ghost.has_method("set_texture"):
		var tex = _get_unit_current_texture(unit)
		if tex != null:
			dragging_ghost.set_texture(tex)


func end_drag() -> void:
	if dragging_ghost == null:
		return

	var slot = _find_nearest_slot(dragging_ghost.global_position)
	if slot == null:
		_restore_or_discard()
		cancel_drag()
		return

	var existing = slot_to_unit.get(slot, null)

	# 目标空位
	if existing == null:
		if drag_source == "button":
			_spawn_to_specific_slot(slot, dragging_fruit_id)
		elif drag_source == "board":
			_move_existing_unit_to_slot(drag_from_unit, slot)
		cancel_drag()
		return

	# 目标有水果
	if drag_source == "board" and existing == drag_from_unit:
		# 理论上不会进这里，但防一手
		_move_existing_unit_to_slot(drag_from_unit, drag_from_slot)
		cancel_drag()
		return

	if _can_merge(existing.fruit_id, dragging_fruit_id):
		var result_id = merge_map[dragging_fruit_id]

		# 删掉目标坑位里的水果
		existing.queue_free()
		slot_to_unit.erase(slot)

		# 如果是从棋盘拖来的，原水果也删掉
		if drag_source == "board" and drag_from_unit != null:
			drag_from_unit.queue_free()
			drag_from_unit = null
			drag_from_slot = null

		# 生成合成结果
		_spawn_to_specific_slot(slot, result_id)

		cancel_drag()
		return

	# 不可合成
	_restore_or_discard()
	cancel_drag()


func cancel_drag() -> void:
	if dragging_ghost:
		dragging_ghost.queue_free()

	dragging_ghost = null
	dragging_fruit_id = ""
	drag_source = ""
	drag_from_slot = null
	drag_from_unit = null


func _restore_or_discard() -> void:
	# 从按钮拖出来：直接丢弃
	if drag_source == "button":
		return

	# 从棋盘拖出来：回原坑位
	if drag_source == "board" and drag_from_unit != null and drag_from_slot != null:
		drag_from_unit.global_position = drag_from_slot.global_position
		drag_from_unit.visible = true
		drag_from_unit.set_state_attacking(true)
		slot_to_unit[drag_from_slot] = drag_from_unit


func _move_existing_unit_to_slot(unit: FruitUnit, slot: Marker2D) -> void:
	if unit == null:
		return

	unit.global_position = slot.global_position
	unit.visible = true
	unit.set_state_attacking(true)
	slot_to_unit[slot] = unit


func _spawn_to_specific_slot(slot: Marker2D, fruit_id: String) -> void:
	if fruit_unit_scene == null or bullet_scene == null:
		return
	if slot_to_unit.has(slot):
		return

	var u: FruitUnit = fruit_unit_scene.instantiate()

	u.fruit_id = fruit_id
	u.bullet_scene = bullet_scene

	add_child(u)

	u.global_position = slot.global_position
	u.set_state_attacking(true)
	u.refresh_from_fruit_id()

	slot_to_unit[slot] = u


func _find_first_empty_slot() -> Marker2D:
	for s in slots:
		if not slot_to_unit.has(s):
			return s
	return null


func _find_nearest_slot(p: Vector2) -> Marker2D:
	var best: Marker2D = null
	var best_d := INF

	for s in slots:
		var d = s.global_position.distance_to(p)
		if d < best_d:
			best_d = d
			best = s

	return best


func _find_unit_under_mouse(mouse_pos: Vector2) -> Dictionary:
	var best_slot: Marker2D = null
	var best_unit: FruitUnit = null
	var best_d := INF

	for s in slots:
		if not slot_to_unit.has(s):
			continue

		var u: FruitUnit = slot_to_unit[s]
		if u == null:
			continue
		if not u.visible:
			continue

		var d = u.global_position.distance_to(mouse_pos)
		if d <= pick_radius and d < best_d:
			best_d = d
			best_slot = s
			best_unit = u

	if best_unit == null:
		return {}

	return {
		"slot": best_slot,
		"unit": best_unit
	}


func _can_merge(target_id: String, dragged_id: String) -> bool:
	# 只有同种拖到同种上，且这类水果存在配方，才能合成
	if target_id != dragged_id:
		return false
	return merge_map.has(dragged_id)


func _get_unit_current_texture(unit: FruitUnit) -> Texture2D:
	if unit == null:
		return null
	if unit.sprite == null:
		return null
	if unit.sprite.sprite_frames == null:
		return null

	var anim = unit.sprite.animation
	if anim == "":
		return null

	var frame = unit.sprite.frame
	return unit.sprite.sprite_frames.get_frame_texture(anim, frame)
