extends CharacterBody2D

@export var acceleration := 10.0
@export var max_speed := 350.0
@export var rotation_speed := 250.0
@export var fire_rate := 0.2

var shoot_enabled : bool = true

@onready var thruster: Node2D = $Thruster
@onready var thruster_particles: GPUParticles2D = $ThrusterParticles
@onready var muzzle: Node2D = $Muzzle
@onready var shoot_timer: Timer = $ShootTimer

var bullet_scene = preload("res://scenes/bullet.tscn")

signal bullet_shot(bullet)

func _process(delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		if shoot_enabled:
			shoot_enabled = false
			shoot_bullet()
			await get_tree().create_timer(fire_rate).timeout
			shoot_enabled = true

func _physics_process(delta: float) -> void:
	
	var input_vector := Vector2(0, Input.get_axis("forward", "backward"))
	velocity += input_vector.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)
	
	if Input.is_action_pressed("right"):
		rotate(deg_to_rad(rotation_speed*delta))
	if Input.is_action_pressed("left"):
		rotate(deg_to_rad(-rotation_speed*delta))
		
	# Friction
	if input_vector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, 3)
		thruster.hide()
		thruster_particles.emitting = false
	else:
		thruster.show()
		thruster_particles.emitting = true
		
	move_and_slide()

	var screen_size = get_viewport_rect().size
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0


func shoot_bullet() -> void:
	var b : Area2D = bullet_scene.instantiate()
	b.global_position = muzzle.global_position
	b.rotation = rotation
	bullet_shot.emit(b)
	get_parent().add_child(b)
