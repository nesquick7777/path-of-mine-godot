extends CanvasModulate

const NIGHT_COLOR = Color("#091d3a")
const DAY_COLOR = Color("#ffffff")
const TIME_SCALE = 0.05

var dayCounter = 1
var time = 0

onready var nightTime = false



func _ready():
	Global.traderPause = false
	Global.stringDay = "Day " + str(dayCounter)
	Global.dayCount = Global.stringDay

func _process(delta:float) -> void:
	if !Global.traderPause:
		self.time += delta * TIME_SCALE
		self.color = DAY_COLOR
#		.linear_interpolate(NIGHT_COLOR, abs(sin(time)))
	
	if color.r < 0.6 and nightTime:
		nightTime = false
		Global.traderPause = true
		dayCounter += 1
		Global.dayCount = "Day " + str(dayCounter)
		if !Global.spawnerRate <= 1:
			Global.spawnerRate -= 1
	elif color.r > 0.6 and !nightTime:
		nightTime = true
		Global.traderPause = false
		Global.canSpawn = true
		if dayCounter > 3:
			Global.spawnGolem = true

