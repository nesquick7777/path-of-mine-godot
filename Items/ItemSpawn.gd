extends AudioStreamPlayer2D

var number = 0

func _ready():
	randomize()
	number = randi() % 3
	if number == 0:
		self.pitch_scale = 0.5
	elif number == 1:
		self.pitch_scale = 0.6
	else:
		self.pitch_scale = 0.7

