extends Node

signal score_changed(new_score : int)

var round_score : int :
	set(val):
		round_score = val
		score_changed.emit(round_score)

func asteroid_destroid(asteroid : Asteroid) -> void:
	print_debug("ASTEROID DESTROYED")
	round_score += asteroid.radius
