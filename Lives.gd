extends Node2D

func setLives(lives):
	$One.visible = lives > 0
	$Two.visible = lives > 1
	$Three.visible = lives > 2
	
