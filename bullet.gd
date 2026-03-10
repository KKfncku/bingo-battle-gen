extends Area2D

var v := Vector2.ZERO
var life_time := 0.3
var t := 0.0

func set_velocity(vel: Vector2) -> void:
	v = vel

func _process(delta: float) -> void:
	position += v * delta

	t += delta
	if t >= life_time:
		queue_free()
