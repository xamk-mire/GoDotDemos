Totta kai! Alla on **opiskelijaystävällinen, Godot 4.5 -yhteensopiva** step-by-step-ohje äänien lisäämiseen: **taustamusiikki (BGM)** ja **ääniefektit (SFX)**. Mukana myös mikseri (Audio Buses), äänenvoimakkuuden hallinta ja esimerkkikoodi kolikon/ hypyn/maalin ääniin.

---

# 🎵 0) Äänitiedostojen tuonti (Import)

**Suositus:**

- **SFX:** `.wav` (pakkaamaton, pieni latenssi)
- **BGM:** `.ogg` (pakattu, pieni koko), silmukointiin OK

**Kun viet tiedoston projektiin:**

1. Valitse tiedosto **FileSystem → Import**-välilehti
2. **BGM** (OGG): `Loop` ✅ jos haluat taustamusiikin kiertävän
3. Paina **Reimport**

> Huom: Jos sinulla on tarkat loop-pisteet, käytä OGG:ia loop-flagilla tai tee saumaton tiedosto.

---

# 🔊 1) Audiobussit (mikseri)

Avaa **Project → Project Settings → Audio → Bus Layout…**

- Pidä **Master**
- Lisää **Music**-bussi (Parent: Master)
- Lisää **SFX**-bussi (Parent: Master)

Voit säätää bussien volumea (dB) erikseen ja lisätä efektejä (Compressor, Reverb…).

> **Vinkki:** Jos haluat “ducking”-efektin (musiikki hiljenee, kun SFX soi), lisää **Sidechain Compressor** Music-bussiin ja syötä sidechainiksi **SFX**.

---

# 🎼 2) Taustamusiikki: yksinkertaisin tapa (AudioStreamPlayer)

## A) Main.tscn:iin soitin

1. Lisää **AudioStreamPlayer** (nimeä: `MusicPlayer`)

2. Inspector:

   - **Stream:** valitse musiikki tiedosto esim: `art/audio/music/title_theme.ogg`
   - **Autoplay:** ✅ (soi heti pelin käynnistyessä)
   - **Bus:** `Music`
   - **Volume dB:** esim. `-6 dB` (ettei klippaa)
   - **Loop:** (hoituu import-asetuksista tai Stream-resurssista)

3. (Valinn.) Jos haluat vaihtaa biisejä tasojen välillä, luo **autoload**.

## B) Autoload “MusicManager” (suositus pidempään projektiin)

**File:** `autoload/MusicManager.gd`

```gdscript
extends Node

var player: AudioStreamPlayer

func _ready() -> void:
	player = AudioStreamPlayer.new()
	player.bus = "Music"
	add_child(player)

func play(stream: AudioStream, volume_db: float = -6.0, loop: bool = true) -> void:
	player.stream = stream
	player.volume_db = volume_db
	if player.stream is AudioStreamOggVorbis:
		(player.stream as AudioStreamOggVorbis).loop = loop
	player.play()

func stop(fade_time := 0.5) -> void:
	if fade_time <= 0.0:
		player.stop()
		return
	var t := create_tween()
	t.tween_property(player, "volume_db", -60.0, fade_time)
	await t.finished
	player.stop()
	player.volume_db = -6.0
```

**Project Settings → Autoload:** lisää `MusicManager.gd` nimellä **MusicManager**.

**Käyttö:**

```gdscript
var stream := load("res://art/audio/music/level_theme.ogg")
MusicManager.play(stream, -6.0, true)
```

---

# 🧨 3) Ääniefektit (SFX): paikallinen vai globaali?

- **AudioStreamPlayer2D** (SFX, jotka kuulostavat tulevan maailmasta: kolikko, vihollinen, hyppy, ovet).
  → Vaikuttaa sijainti, etäisyys, stereo.
- **AudioStreamPlayer** (UI-klik, menunappien äänet).
  → Ei paikallisuutta, suoraan “korviin”.

## A) SFX suoraan kohtaukseen (esim. Coin.tscn)

**Coin.tscn**

```
Coin (Area2D)
├─ Sprite2D
├─ CollisionShape2D
└─ AudioStreamPlayer2D (name: Sfx)
```

**AudioStreamPlayer2D asetukset:**

- **Stream:** `art/audio/sfx/coin.wav`
- **Bus:** `SFX`
- **Volume dB:** esim. `-4 dB`
- **Attenuation**: `-6 dB` (tai sopiva)
- **Max Distance:** 1000 (riippuu pelin mittakaavasta)

**Coin.gd**

```gdscript
extends Area2D
@onready var sfx: AudioStreamPlayer2D = $Sfx

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		if sfx: sfx.play()
		Game.add_coin(1)
		# odota lyhyt aika, ettei ääni leikkaannu:
		await get_tree().create_timer(0.05).timeout
		queue_free()
```

> **Vinkki:** Jos ääni leikkautuu pois `queue_free()`-kutsun takia, soita ääni erillisellä node:lla (esim. MusicManager/SFXManager) tai tee `sfx.reparent(get_tree().current_scene)` ennen poistamista.

## B) Pelaajan SFX (hyppy, potku)

**Player.tscn**

```
Player (CharacterBody2D)
├─ Sprite2D
├─ CollisionShape2D
├─ SfxJump (AudioStreamPlayer)
└─ SfxHurt (AudioStreamPlayer)
```

**Player.gd**

```gdscript
@onready var sfx_jump: AudioStreamPlayer = $SfxJump
@onready var sfx_hurt: AudioStreamPlayer = $SfxHurt

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force
		if sfx_jump: sfx_jump.play()

func take_damage() -> void:
	# ... elämien vähennys
	if sfx_hurt: sfx_hurt.play()
```

> UI-SFX: aseta **Bus = SFX**, ei tarvetta 2D-paikannukselle.

---

# 🎚️ 4) Äänenvoimakkuus ja asetukset (Master / Music / SFX)

## A) Perustasot (esim. asetukset valikossa)

```gdscript
# HUD tai Settings.gd (slider range esim. -30..0 dB)
func set_music_volume(db: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)

func set_sfx_volume(db: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)
```

## B) Mykistys (mute)

```gdscript
func set_music_mute(mute: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), mute)
```

---

# 🔁 5) Musiikin vaihto tasojen välillä

**Goal.gd** (kun taso päättyy):

```gdscript
func _on_enter(body: Node) -> void:
	if body.name == "Player":
		print("Level complete!")
		# crossfade: hiljennä vanha ja käynnistä uusi
		MusicManager.stop(0.5)
		await get_tree().create_timer(0.5).timeout
		var next := load("res://art/audio/music/level02_theme.ogg")
		MusicManager.play(next, -6.0, true)
		# Vaihda taso:
		# get_tree().change_scene_to_file("res://levels/Level02.tscn")
```

---

# 🧪 6) Pikadiagnostiikka (jos ääni ei kuulu)

- **Stream tyhjä?** Aseta AudioStream tiedostoon (Inspector).
- **Autoplay?** Taustamusiikki: Autoplay ✅ tai soitto koodista.
- **Bus oikein?** Onhan soittimen **Bus** `Music` tai `SFX` eikä hiljennetty?
- **Volume dB liian matala?** `-60 dB` on käytännössä mykistys.
- **Parentin mykistys?** Master bussissa mute/volume?
- **2D-SFX ei kuulu?** Pelaajan/kameran etäisyys & **Max Distance**/Attenuation.
- **Exportissa hiljaista?** Tarkista, ettei “Audio Driver” tai sample rate aiheuta ongelmia laitekohtaisesti.

---

# 🧰 7) Laajennus: SFX-manageri (pool) päällekkäisiin ääniin

Jos sama ääni voi soida monta kertaa päällekkäin (esim. kolikot nopeasti), tee **SFXManager** joka luo useita player-instansseja:

```gdscript
# autoload/SFXManager.gd
extends Node

const POOL_SIZE := 8
var pool: Array[AudioStreamPlayer] = []
var index := 0

func _ready() -> void:
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		pool.append(p)

func play(stream: AudioStream, volume_db := -4.0) -> void:
	var p := pool[index]
	index = (index + 1) % POOL_SIZE
	p.stop()
	p.stream = stream
	p.volume_db = volume_db
	p.play()
```

**Käyttö:**

```gdscript
SFXManager.play(load("res://art/audio/sfx/coin.wav"))
```

---

# 🎛️ 8) Pieni “hyvältä kuulostaa heti” -preset

- **Music bus:** Volume `-6 dB`, **Limiter** (Ceiling `-0.3 dB`), (valinn.) **Sidechain Compressor** SFX:stä `−8 dB` ducking
- **SFX bus:** Volume `-4 dB`, (valinn.) **High-pass** < 80 Hz mudan siistimiseen
- **Master:** Limiter (varovainen), Peak alle 0 dB

---

# ✅ 9) Pika-checklist

- [ ] BGM: AudioStreamPlayer (tai MusicManager), Bus = Music, Autoplay/Loop OK
- [ ] SFX: AudioStreamPlayer2D/AudioStreamPlayer kohtauksissa, Bus = SFX
- [ ] Bus-rakenne: Master → (Music, SFX)
- [ ] Tomintakutsu koodissa: `player.play()` / `SFXManager.play(stream)`
- [ ] Volume ja mute toimivat Settings/HUD:sta
- [ ] SFX ei katkea, vaikka node poistuu (soita managerista tai reparentoi)
- [ ] Exportissa kuuluu (testaa käyttöjärjestelmäkohtaisesti)
