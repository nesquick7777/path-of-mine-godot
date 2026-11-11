extends Node

var zIndex = false
var dayCount = " "
var stringDay = " "
var spawnerRate = 9
var spawnGolem = false
var playerCoins = 0
var canChange = false
var canSpawn = false
var traderPause = true
var LOrbCanCast = false
var enginePause = false
var velocityAdjusting = false
var canStopTime = false

signal itemPickedUp
signal transformationOver

func emitSignalItem():
	emit_signal("itemPickedUp")

func instance_node_at_location(node: Object, parent: Object, location: Vector2) -> Object:
	var node_instance = node.instance_node(node, parent)
	node_instance.global_position = location
	return node_instance

func instance_node(node: Object, parent: Object) -> Object:
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance

