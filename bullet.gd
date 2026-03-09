extends Area2D

var v := Vector2.ZERO

func set_velocity(vel: Vector2) -> void:
	v = vel

func _process(delta: float) -> void:
	position += v * delta
	if position.y < -200:
		queue_free()
