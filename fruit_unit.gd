extends Node2D
class_name FruitUnit

@export var fruit_id := "strawberry"
@export var level := 1
@export var bullet_scene: PackedScene
@export var fire_interval := 0.35
@export var bullet_speed := 900.0

# 不同水果的动画资源：在 FruitUnit.tscn 根节点手动绑定
@export var strawberry_frames: SpriteFrames
@export var apple_frames: SpriteFrames
@export var lemon_frames: SpriteFrames
@export var tomato_frames: SpriteFrames
@export var banana_frames: SpriteFrames
@export var pineapple_frames: SpriteFrames
@export var pomegranate_frames: SpriteFrames
@export var durian_frames: SpriteFrames

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var strawberry_idle: AnimatedSprite2D = $StrawberryIdle
@onready var strawberry_attack: AnimatedSprite2D = $StrawberryAttack
@onready var muzzle: Marker2D = $Muzzle

var _t := 0.0
var _attacking := true


func _ready() -> void:
	_apply_frames_by_fruit_id()
	_update_visual_state()


func set_state_attacking(on: bool) -> void:
	_attacking = on
	_update_visual_state()


func _process(delta: float) -> void:
	if not _attacking:
		return

	_t += delta
	if _t >= fire_interval:
		_t = 0.0
		fire()


func _apply_frames_by_fruit_id() -> void:
	match fruit_id:
		"strawberry":
			if strawberry_frames != null:
				sprite.sprite_frames = strawberry_frames
		"apple":
			if apple_frames != null:
				sprite.sprite_frames = apple_frames
		"lemon":
			if lemon_frames != null:
				sprite.sprite_frames = lemon_frames
		"tomato":
			if tomato_frames != null:
				sprite.sprite_frames = tomato_frames
		"banana":
			if banana_frames != null:
				sprite.sprite_frames = banana_frames
		"pineapple":
			if pineapple_frames != null:
				sprite.sprite_frames = pineapple_frames
		"pomegranate":
			if pomegranate_frames != null:
				sprite.sprite_frames = pomegranate_frames
		"durian":
			if durian_frames != null:
				sprite.sprite_frames = durian_frames


func _update_visual_state() -> void:
	# 先全部隐藏草莓专用节点
	if strawberry_idle != null:
		strawberry_idle.visible = false
	if strawberry_attack != null:
		strawberry_attack.visible = false

	# 草莓：走专用显示
	if fruit_id == "strawberry":
		if sprite != null:
			sprite.visible = false

		if _attacking:
			if strawberry_attack != null:
				strawberry_attack.visible = true
				_play_if_exists_on(strawberry_attack, "attack", "default")
		else:
			if strawberry_idle != null:
				strawberry_idle.visible = true
				_play_if_exists_on(strawberry_idle, "idle", "default")
	else:
		# 其他水果仍然走原来的 Sprite
		if sprite != null:
			sprite.visible = true
			if _attacking:
				_play_if_exists("attack", "default")
			else:
				_play_if_exists("pickup", "default")


func _play_if_exists_on(target_sprite: AnimatedSprite2D, anim: String, fallback: String) -> void:
	if target_sprite == null:
		return
	if target_sprite.sprite_frames == null:
		return

	var sf = target_sprite.sprite_frames

	if sf.has_animation(anim):
		target_sprite.play(anim)
		return

	if sf.has_animation(fallback):
		target_sprite.play(fallback)
		return

	if sf.has_animation("default"):
		target_sprite.play("default")
		return

	var names := sf.get_animation_names()
	if names.size() > 0:
		target_sprite.play(names[0])


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


func fire_pomegranate() -> void:
	# 先临时用基础攻击占位
	fire_basic()


func fire_durian() -> void:
	# 先留空占位，后续接鼠标点选激光
	pass


func _play_if_exists(anim: String, fallback: String) -> void:
	if sprite == null:
		return
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
