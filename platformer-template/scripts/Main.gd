extends Node2D

# =============================================================
# Main.gd toimii pelin "keskushermostona".
#
# Se vastaa:
#   • pelin aloituksesta ja resetoinnista
#   • tason lataamisesta ja uudelleenlataamisesta
#   • pelaajan sijoittamisesta spawn-pisteeseen
#   • reagoimisesta Game.gd:n game_over -signaaliin
#
# Yksinkertaistettuna:
#   Game.gd = säilöö pelitilan (kolikot, elämät, spawn)
#   Level.tscn = itse pelitaso
#   Main.gd = hallitsee kaikkien tasojen latausta ja pelin kulkua
#
# Tätä skriptiä voidaan myöhemmin laajentaa:
#   • useita tasoja ja tasonvaihto
#   • fade-efektit tason vaihdossa
#   • päävalikko ja pause-menu
# =============================================================

# Oletustaso, joka ladataan (voi vaihtaa myöhemmin dynaamiseksi)
const LEVEL_PATH := "res://levels/Level01.tscn"
var level_scene: PackedScene = load(LEVEL_PATH)

# Viittaus pelaajaan
@onready var player: CharacterBody2D = $Player

# Säilytetään viittaus aktiiviseen tasoon
var current_level: Node = null

# Estää usean yhtäaikaisen latauksen / resetin
var _loading: bool = false


func _ready() -> void:
	# Aloitetaan uusi peli
	Game.new_game()

	# Varmistetaan, ettei game_over signaalia yhdistetä kahdesti
	if not Game.game_over.is_connected(_on_game_over):
		Game.game_over.connect(_on_game_over)

	# Ladataan ensimmäinen taso
	_load_level()

	# Debug — näyttää nodepuun selkeästi konsolissa
	print_tree_pretty()


# -------------------------------------------------------------
# Lataa tason uudelleen turvallisesti
# -------------------------------------------------------------
func _load_level() -> void:
	# Estetään päällekkäinen lataus
	if _loading:
		return
	_loading = true

	# Poistetaan edellinen taso, jos löytyy
	for n in get_children():
		if n.name == "Level" or n.is_in_group("level_root"):
			n.queue_free()

	# Odotetaan yksi frame, että poistot ehtii suorittaa
	await get_tree().process_frame

	# Varmistus — jos tasoa ei ole asetettu
	if level_scene == null:
		push_error("Main.gd: 'level_scene' not assigned")
		_loading = false
		return

	# Instanssitaan taso
	current_level = level_scene.instantiate()
	current_level.name = "Level"
	current_level.add_to_group("level_root")
	add_child(current_level)

	# Odota frame, jotta level nodet ovat varmasti valmiit
	await get_tree().process_frame

	# Haetaan SpawnPoint tasosta
	var spawn := current_level.get_node_or_null("SpawnPoint") as Node2D
	var pos: Vector2 = spawn.global_position if spawn != null else Vector2.ZERO

	# Siirretään pelaaja spawn-pisteeseen
	$Player.global_position = pos

	# Ilmoitetaan Game.gd:lle taso alkaneeksi
	Game.reset_for_level(pos)

	_loading = false


# -------------------------------------------------------------
# Kun Game.gd ilmoittaa, että pelaaja kuoli ilman elämiä
# -------------------------------------------------------------
func _on_game_over() -> void:
	var hud := get_node_or_null("HUD")

	# Näytetään viesti, jos HUD löytyy
	if hud and hud.has_method("show_message"):
		hud.show_message("Game Over! Restarting...")

	# Lyhyt viive ennen restarttia
	await get_tree().create_timer(1.0).timeout

	# Resetoi pelin ja lataa tason uudelleen
	Game.new_game()
	_load_level()
