@tool
extends RigidBody2D
class_name Asteroid

@export_group("Shape")
@export var seed: int = 0:
	set(v):
		seed = v
		_generate_in_editor()
@export var radius: float = 48.0:
	set(v):
		radius = max(8.0, v)
		_generate_in_editor()
@export_range(6, 64, 1) var vertices: int = 14:
	set(v):
		vertices = v
		_generate_in_editor()
@export var jaggedness: float = 0.35: # 0..~0.6 reasonable
	set(v):
		jaggedness = clampf(v, 0.0, 0.8)
		_generate_in_editor()
@export var noise_bias: float = 0.15: # adds smoothness
	set(v):
		noise_bias = clampf(v, 0.0, 1.0)
		_generate_in_editor()

@export_group("Movement")
@export var min_speed := 60.0
@export var max_speed := 140.0
@export var spin := 2.0

@onready var poly: Polygon2D = $Body
@onready var col: CollisionPolygon2D = $CollisionPolygon2D
@onready var outline: Line2D = $Outline

@export_group("Misc")
@export var max_health := 100
var health : int

signal destroyed(asteroid : Asteroid)

func damage(amount : int) -> void:
	health -= amount
	if health <= 0:
		_destroyed()

var asteroid_scene = preload("res://scenes/procedral_asteroid.tscn")

func _destroyed() -> void:
	print_debug("i am a dead asteroid")
	destroyed.emit(self)
	if radius > 20:
		split_into_children(asteroid_scene, radius/2)
	queue_free()
	
func _ready() -> void:
	health = max_health
	_generate(false)
	var dir := Vector2.RIGHT.rotated(randf() * TAU)
	linear_velocity = dir * randf_range(min_speed, max_speed)
	angular_velocity = randf_range(-spin, spin)
	# Connect the destroyed signal to the global game manger
	# This does feel hacky AF
	destroyed.connect(GameManager.asteroid_destroid)

func _physics_process(_delta: float) -> void:
	# Wrapp around the screen
	var screen_size = get_viewport_rect().size
	if global_position.y+radius < 0:
		global_position.y = screen_size.y+radius
	elif global_position.y-radius > screen_size.y:
		global_position.y = -radius
	if global_position.x+radius < 0:
		global_position.x = screen_size.x+radius
	elif global_position.x-radius > screen_size.x:
		global_position.x = -radius
	
func _generate_in_editor() -> void:
	if Engine.is_editor_hint() and is_inside_tree():
		_generate(true)

func _generate(from_editor: bool) -> void:
	var rng := RandomNumberGenerator.new()
	if seed != 0:
		rng.seed = seed
	else:
		rng.randomize()

	var pts: PackedVector2Array = []
	var base_r := radius
	var bias := noise_bias

	for i in vertices:
		var t := float(i) / float(vertices)
		var ang := t * TAU
		# two-layer jitter: smooth trend + local spike
		var smooth = lerp(-jaggedness, jaggedness, (sin(ang * 1.7 + rng.randf()*TAU) * 0.5 + 0.5))
		var local := (rng.randf() * 2.0 - 1.0) * jaggedness
		var j = lerp(local, smooth, bias)
		var r = base_r * (1.0 + j)
		r = clampf(r, base_r * (1.0 - jaggedness*1.1), base_r * (1.0 + jaggedness))
		pts.append(Vector2.RIGHT.rotated(ang) * r)
		
	# close the loop for Line2D
	#pts.append(pts[0])
	
	# ensure counter-clockwise (helps with area/mass)
	if _polygon_area(pts) < 0.0:
		pts.reverse()

	# Visuals
	if poly:
		poly.polygon = pts
		poly.color = Color(0.85, 0.85, 0.9, 1.0)
		poly.antialiased = true
		# simple panel seams
		#poly.outline_color = Color(0.2, 0.25, 0.35, 0.9)
		#poly.outline = 1.0
		
	if outline:
		outline.points = pts

	# Collision
	if col:
		col.build_mode = CollisionPolygon2D.BUILD_SOLIDS
		col.polygon = pts
		col.disabled = false
		#col.property_list_changed_notify() # refresh editor view
		notify_property_list_changed()

	# Optional: set mass ~ area for nicer inertia
	var a := absf(_polygon_area(pts))
	mass = max(1.0, a * 0.002)

	# Optional: tiny random spin
	if not Engine.is_editor_hint():
		angular_velocity = lerp(-2.0, 2.0, rng.randf())

func _polygon_area(p: PackedVector2Array) -> float:
	var area := 0.0
	var n := p.size()
	for i in n:
		var j := (i + 1) % n
		area += p[i].x * p[j].y - p[j].x * p[i].y
	return area * 0.5

func _on_body_entered(body: Node) -> void:
	if body is Player:
		var player = body as Player
		player.asteroid_collision(self)


# --- Public API ---

func regenerate(new_seed: int = 0) -> void:
	seed = new_seed
	_generate(false)


func split_into_children(scene_small: PackedScene, new_radius : float, count: int = 2) -> void:
	# example: call on death; spawns smaller asteroids inheriting velocity
	for i in count:
		var a := scene_small.instantiate() as RigidBody2D
		var dir := Vector2.RIGHT.rotated(randf() * TAU)
		a.global_position = global_position + dir * 6.0
		a.linear_velocity = linear_velocity + dir * 60.0
		a.radius = new_radius
		a.regenerate()
		get_parent().add_child(a)
