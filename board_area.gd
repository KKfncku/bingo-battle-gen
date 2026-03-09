extends Node2D

@export var fruit_unit_scene: PackedScene
@export var bullet_scene: PackedScene
@export var ghost_scene: PackedScene

@onready var slots := [
	$SlotsLine/Slot1, $SlotsLine/Slot2, $SlotsLine/Slot3, $SlotsLine/Slot4, $SlotsLine/Slot5
]

var slot_to_unit := {}  # Marker2D -> FruitUnit
var dragging_ghost = null
var dragging_fruit_id := ""

func _process(_delta: float) -> void:
	if dragging_ghost != null and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		end_drag()

func place_fruit(fruit_id: String) -> void:
	var slot := _find_nearest_empty_slot()
	if slot == null:
		print("No empty slot")
		return
	_spawn_to_specific_slot(slot, fruit_id)

func _find_nearest_empty_slot() -> Marker2D:
	for s in slots:
		if not slot_to_unit.has(s):
			return s
	return null

func begin_drag(fruit_id: String, icon_tex: Texture2D) -> void:
	cancel_drag()

	if ghost_scene == null:
		print("ghost_scene not set")
		return
	if fruit_unit_scene == null:
		print("fruit_unit_scene not set")
		return

	dragging_fruit_id = fruit_id
	dragging_ghost = ghost_scene.instantiate()
	add_child(dragging_ghost)
	dragging_ghost.fruit_id = fruit_id

	if icon_tex != null and dragging_ghost.has_method("set_texture"):
		dragging_ghost.set_texture(icon_tex)

func end_drag() -> void:
	if dragging_ghost == null:
		return

	var slot = _find_nearest_slot(dragging_ghost.global_position)

	if slot == null:
		cancel_drag()
		return

	var existing = slot_to_unit.get(slot, null)
	if existing == null:
		_spawn_to_specific_slot(slot, dragging_fruit_id)
	else:
		if existing.fruit_id == dragging_fruit_id:
			existing.level += 1
			if existing.has_method("set_state_attacking"):
				existing.set_state_attacking(true)

	cancel_drag()

func cancel_drag() -> void:
	if dragging_ghost:
		dragging_ghost.queue_free()
	dragging_ghost = null
	dragging_fruit_id = ""

func _find_nearest_slot(p: Vector2) -> Marker2D:
	var best: Marker2D = null
	var best_d := INF
	for s in slots:
		var d = s.global_position.distance_to(p)
		if d < best_d:
			best_d = d
			best = s
	return best

func _spawn_to_specific_slot(slot: Marker2D, fruit_id: String) -> void:
	if fruit_unit_scene == null or bullet_scene == null:
		return
	if slot_to_unit.has(slot):
		return

	var u: FruitUnit = fruit_unit_scene.instantiate()
	add_child(u)
	u.fruit_id = fruit_id
	u.bullet_scene = bullet_scene
	u.global_position = slot.global_position
	u.set_state_attacking(true)

	slot_to_unit[slot] = u
