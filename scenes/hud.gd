extends Control

@onready var score: Label = $Score :
	set(val):
		score.text = "SCORE: " + str(val)
		
var ship_life_icon_scene := preload("res://scenes/lives_bar_icon.tscn")
@onready var lives_container: HBoxContainer = $VBoxContainer/LivesContainer

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
