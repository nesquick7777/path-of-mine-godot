extends AnimatedSprite

func _ready():
	connect("animation_finished", self, "on_animation_finished")
	play("Animate")
	$AudioStreamPlayer2D.play()

func on_animation_finished():
	queue_free()
