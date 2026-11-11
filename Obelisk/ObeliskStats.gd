extends Node

export(float) var maxHearts2 = 10 setget set_max_hearts2
var hearts2 = maxHearts2 setget set_hearts2
signal health_changed2(value2)
signal no_health2
signal max_health_changed2(value2)

func set_hearts2(value2):
	hearts2 = value2
	emit_signal("health_changed2", hearts2)
	if hearts2 <= 0:
		emit_signal("no_health2")

func set_max_hearts2(value2):
	maxHearts2 = value2
	self.hearts2 = min(hearts2, maxHearts2)
	emit_signal("max_health_changed2")

func _ready():
	self.hearts2 = maxHearts2
