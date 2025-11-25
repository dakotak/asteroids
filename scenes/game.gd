extends Node2D


@onready var hud: Control = $UI/HUD
@onready var player: CharacterBody2D = $Player
@onready var game_over_screen: Control = $UI/GameOverScreen

@export var starting_lives := 3
var lives : int :
	set(val):
		lives = val
		if lives == 0:
			_game_over()
		# Update the hud
		hud.lives = val

func _ready() -> void:
	lives = starting_lives


func start_game() -> void:
	game_over_screen.hide()
	lives = starting_lives
	# Show the ship

func _ship_killed() -> void:
	lives -= 1
	

func _game_over() -> void:
	game_over_screen.show()
	player.hide()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
