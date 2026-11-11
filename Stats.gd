extends Node

func _ready():
	self.hearts = maxHealth

export(int) var maxHealth = 3 setget set_max_hearts
var hearts = maxHealth setget set_hearts
signal no_health
signal health_changed(value)
signal max_health_changed(value)
signal dash_speed_changed(value)
signal max_speed_changed(value)
signal acceleration_changed(value)
signal friction_changed(value)

var reset = maxHealth

var resetAcceleration = 500
var resetFriction = 400
var resetMax_speed = 90
var resetDash_speed = 130

var acceleration = 500 setget set_acceleration
var friction = 400 setget set_friction
var max_speed = 90 setget set_max_speed
var dash_speed = 130 setget set_dash_speed

func set_acceleration(value):
	acceleration = value
	emit_signal("acceleration_changed", acceleration)

func set_friction(value):
	friction = value
	emit_signal("friction_changed", friction)

func set_max_speed(value):
	max_speed = value
	emit_signal("max_speed_changed", max_speed)

func set_dash_speed(value):
	dash_speed = value
	emit_signal("dash_speed_changed", dash_speed)

func set_max_hearts(value):
	maxHealth = value
	self.hearts = min(hearts, maxHealth)
	emit_signal("max_health_changed", maxHealth)

func set_hearts(value):
	hearts = value
	emit_signal("health_changed", hearts)
	if hearts <= 0:
		emit_signal("no_health")
