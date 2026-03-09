extends Node2D
class_name FruitUnit

@export var fruit_id := "strawberry"
@export var level := 1
@export var bullet_scene: PackedScene
@export var fire_interval := 0.35
@export var bullet_speed := 900.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var muzzle: Marker2D = $Muzzle

var _t := 0.0
var _attacking := true


func set_state_attacking(on: bool) -> void:
	_attacking = on
	if on:
		_play_if_exists("attack", "idle")
	else:
		_play_if_exists("pickup", "idle")


func _process(delta: float) -> void:
	if not _attacking:
		return

	_t += delta
	if _t >= fire_interval:
		_t = 0.0
		fire()


func fire() -> void:
	match fruit_id:
		"strawberry", "apple", "lemon", "tomato":
			fire_basic()
		"banana":
			fire_banana()
		"pineapple":
			fire_pineapple()
		"pomegranate":
			fire_pomegranate()
		"durian":
			fire_durian()
		_:
			fire_basic()


func fire_basic() -> void:
	if bullet_scene == null:
		return

	var b = bullet_scene.instantiate()
	get_parent().add_child(b)
	b.global_position = muzzle.global_position

	if b.has_method("set_velocity"):
		b.set_velocity(Vector2(0, -bullet_speed))


func fire_banana() -> void:
	if bullet_scene == null:
		return

	var dirs = [
		Vector2(-0.35, -1).normalized(),
		Vector2(0, -1),
		Vector2(0.35, -1).normalized()
	]

	for dir in dirs:
		var b = bullet_scene.instantiate()
		get_parent().add_child(b)
		b.global_position = muzzle.global_position

		if b.has_method("set_velocity"):
			b.set_velocity(dir * bullet_speed)


func fire_pineapple() -> void:
	if bullet_scene == null:
		return

	var b = bullet_scene.instantiate()
	get_parent().add_child(b)
	b.global_position = muzzle.global_position

	if b.has_method("set_velocity"):
		b.set_velocity(Vector2(0, -bullet_speed * 0.7))

	# 这里先留占位
	# 如果你的 Bullet.gd 之后支持 pierce_left，
	# 再把下面两行取消注释
	# if "pierce_left" in b:
	# 	b.pierce_left = 3


func fire_pomegranate() -> void:
	# 先临时用基础攻击占位
	fire_basic()


func fire_durian() -> void:
	# 先留空占位，后续接鼠标点选激光
	pass


func _play_if_exists(anim: String, fallback: String) -> void:
	if sprite.sprite_frames == null:
		return

	var sf = sprite.sprite_frames

	if sf.has_animation(anim):
		sprite.play(anim)
		return

	if sf.has_animation(fallback):
		sprite.play(fallback)
		return

	if sf.has_animation("default"):
		sprite.play("default")
		return

	var names := sf.get_animation_names()
	if names.size() > 0:
		sprite.play(names[0])
