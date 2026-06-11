extends Node

var disease_progress: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Disease Stage : ", disease_progress)

func increment_prog(amount: int) -> void:
	disease_progress += amount
