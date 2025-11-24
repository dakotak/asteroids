extends Control

@onready var score: Label = $Score :
	set(val):
		score.text = "SCORE: " + str(val)

func _ready() -> void:
	pass
