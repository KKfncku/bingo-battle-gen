extends AnimatedSprite2D

@export var bullet_scene: PackedScene
@export var fire_interval := 0.35
@export var bullet_speed := 900.0

@onready var projectiles := get_parent().get_node_or_null("Projectiles")

var t := 0.0

func _process(delta: float) -> void:
	t += delta
	if t >= fire_interval:
		t = 0.0
		fire()

func fire() -> void:
	if bullet_scene == null:
		return

	var b = bullet_scene.instantiate()

	if projectiles != null:
		projectiles.add_child(b)
	else:
		get_parent().add_child(b)

	var muzzle := get_node_or_null("Muzzle")
	if muzzle:
		b.global_position = muzzle.global_position
	else:
		b.global_position = global_position

	if b.has_method("set_velocity"):
		b.set_velocity(Vector2(0, -bullet_speed))
