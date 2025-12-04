extends AudioStreamPlayer

var loop_start = 7.467
var loop_end = 67.005

func _process(delta: float) -> void:
	if playing:
		var pos = get_playback_position()
		
		if pos >= loop_end:
			seek(loop_start)
