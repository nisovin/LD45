extends Node

const Sounds = {
	"bump": preload("res://sounds/bump.ogg"),
	"part_appear": preload("res://sounds/part_appear.ogg"),
	"part_release": preload("res://sounds/part_release.ogg"),
	"part_attach": preload("res://sounds/part_attach.ogg"),
	"part_dies": preload("res://sounds/part_dies.ogg"),
	"ship_done": preload("res://sounds/ship_done.ogg"),
	"shoot": preload("res://sounds/shoot.ogg"),
	"hit": preload("res://sounds/hit.ogg"),
	"enemy_shoot": preload("res://sounds/enemy_shoot.ogg"),
	"enemy_die": preload("res://sounds/enemy_die.ogg")
}

onready var tween = $Tween
onready var main_music = $MainMusic
onready var fight_music = $FightMusic
onready var sfx = $SFX
onready var thrusters = $Thrusters

func fade_music(type, dir):
	var track: AudioStreamPlayer
	if type == "fight":
		track = fight_music
	else:
		track = main_music
	if dir == "in":
		track.volume_db = -80
		track.play()
		tween.interpolate_property(track, "volume_db", -60.0, 0.0, 5, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
	elif dir == "out" and track.playing:
		track.volume_db = 0
		tween.interpolate_property(track, "volume_db", 0.0, -80.0, 10, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
		yield(get_tree().create_timer(10), "timeout")
		track.stop()

func play_sound(sound):
	for player in sfx.get_children():
		if !player.playing:
			player.stream = Sounds[sound]
			player.play()
			return

func play_thrusters(on):
	if on:
		if !thrusters.playing:
			thrusters.play()
	else:
		thrusters.stop()
