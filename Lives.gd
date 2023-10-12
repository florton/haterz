extends Node2D

func setLives(lives):
	$One.visible = lives > 1
	$Two.visible = lives > 2
	$Three.visible = lives > 3
	
