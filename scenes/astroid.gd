extends RigidBody2D


@export var min_speed := 60.0
@export var max_speed := 140.0
@export var spin := 2.0

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	var dir := Vector2.RIGHT.rotated(randf() * TAU)
	linear_velocity = dir * randf_range(min_speed, max_speed)
	angular_velocity = randf_range(-spin, spin)

func _physics_process(_delta: float) -> void:
	var radius = collision_shape_2d.shape.radius
	var screen_size = get_viewport_rect().size
	if global_position.y+radius < 0:
		global_position.y = screen_size.y+radius
	elif global_position.y-radius > screen_size.y:
		global_position.y = -radius
	if global_position.x+radius < 0:
		global_position.x = screen_size.x+radius
	elif global_position.x-radius > screen_size.x:
		global_position.x = -radius
	
	#print_debug(linear_velocity.length())
