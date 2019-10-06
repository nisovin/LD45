extends Node

const Sounds = {
	"part_appear": preload("res://sounds/part_appear.ogg"),
	"part_release": preload("res://sounds/part_release.ogg"),
	"part_attach": preload("res://sounds/part_attach.ogg"),
	"part_dies": preload("res://sounds/part_dies.ogg"),
	"ship_done": preload("res://sounds/ship_done.ogg"),
	"shoot": preload("res://sounds/shoot.ogg"),
	"hit": preload("res://sounds/hit.ogg")
}

onready var sfx = $SFX
onready var thrusters = $Thrusters

func play_sound(sound):
	for player in sfx.get_children():
		if !player.playing:
			player.stream = Sounds[sound]
			player.play()
			return
	print("no player available")

func play_thrusters(on):
	if on:
		if !thrusters.playing:
			thrusters.play()
	else:
		thrusters.stop()
