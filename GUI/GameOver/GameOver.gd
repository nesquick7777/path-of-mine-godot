extends Node2D

func _ready():
	$DaysSurvived.text = Global.dayCount
	$Menu/AudioStreamPlayer.stop()
	$AudioStreamPlayer2D.play(0.0)
	$Menu/SPACE.visible = false
	$Menu/Label.visible = false
	$Menu/TileMap.visible = false
