extends Control


@onready var score_label: Label = %ScoreLabel
@onready var lives_container: HBoxContainer = $VBoxContainer/LivesContainer
var ship_life_icon_scene := preload("res://scenes/lives_bar_icon.tscn")

var score : int :
	set(val):
		score_label.text = "SCORE: " + str(val)

var lives : int :
	set(val):
		lives = val
		_update_lives_bar()

func _update_lives_bar() -> void:
	# Clear out all children
	for c in lives_container.get_children():
		c.queue_free()
	
	for na in range(lives):
		var i = ship_life_icon_scene.instantiate()
		lives_container.add_child(i)
