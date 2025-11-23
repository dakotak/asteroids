extends Area2D

var movement_vector := Vector2(0, -1)
@export var speed := 500.0
@export var damage_amount := 50

func _physics_process(delta: float) -> void:
	global_position += movement_vector.rotated(rotation) * speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("damage"):
		body.damage(damage_amount)
		queue_free()
