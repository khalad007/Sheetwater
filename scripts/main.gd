extends Control

func _ready() -> void:
	print("Hollow Creek booted")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		Sfx.play("test")
