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
	if bullet_scene == null:
		return
	var b = bullet_scene.instantiate()
	get_parent().add_child(b)
	b.global_position = muzzle.global_position
	if b.has_method("set_velocity"):
		b.set_velocity(Vector2(0, -bullet_speed))

func _play_if_exists(anim: String, fallback: String) -> void:
	if sprite.sprite_frames == null:
		return

	var sf = sprite.sprite_frames

	# 1 先试目标动画
	if sf.has_animation(anim):
		sprite.play(anim)
		return

	# 2 再试 fallback
	if sf.has_animation(fallback):
		sprite.play(fallback)
		return

	# 3 再试 default
	if sf.has_animation("default"):
		sprite.play("default")
		return

	# 4 最后随便播第一个存在的动画，保证不报错
	var names := sf.get_animation_names()
	if names.size() > 0:
		sprite.play(names[0])
