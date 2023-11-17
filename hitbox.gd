extends Area2D

@onready var enemy = $".."

func takeDamage():
	enemy.takeDamage()
