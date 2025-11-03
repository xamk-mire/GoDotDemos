# 1) UUSI PELAAJA – luonti alusta

### 1. Luo scene

1. **New → Scene → 2D Scene** (nimeä `Player`).
2. Vaihda root-tyypiksi **CharacterBody2D** (Scene-paneelin oikealla “Reparent…”).

Rakennetta:

```
Player (CharacterBody2D)
├─ Sprite2D                # hahmon kuva / spritet
├─ CollisionShape2D        # törmäysmuoto
├─ InteractZone (Area2D)   # valinnainen: E-toiminto
│  └─ CollisionShape2D
└─ HoldSocket (Node2D)     # valinnainen: kannettaville esineille
```

### 2. Lisää grafiikka

- Valitse **Sprite2D → Texture** ja osoita omaan kuvaan/sprite sheetiin.
- Pixel-art: kuvan Import-välilehti → **Filter: Disabled**, **Repeat: Disabled**.

### 3. Lisää törmäys

- Valitse **CollisionShape2D** → **Shape: Capsule/Rectangle**.  
   Aseta koko niin, että jalat osuvat laattoihin (ei peitä koko spriteä).

### 4. Layerit & maskit

- **Player (CharacterBody2D)**:
  - **Collision Layer = 2**
  - **Collision Mask = 1 | 3** (1=maa/seinät, 3=interaktio-objektit kuten pallo)
- Laatat/maasto **Layer 1** (maskia ei tarvita).

### 5. (Valinnainen) InteractZone & HoldSocket

- **InteractZone (Area2D)**: pieni ympyrä/rect hahmon edessä.  
   **Collision Mask** sisältää kerroksen **3** (pallo tms.).
- **HoldSocket (Node2D)**: aseta x ≈ +10, y ≈ −6 (käsien kohdalle).

### 6. Lisää skripti (Player.gd)

Liitä `Player.gd` juurisolmuun:

```gdscript
extends CharacterBody2D

@export var speed := 220.0
@export var jump_force := 420.0
@export var gravity := 1400.0
@export var invuln_time := 0.8

@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_zone: Area2D = $InteractZone
@onready var hold_socket: Node2D = $HoldSocket

var facing := 1       # 1 oikea, -1 vasen
var _invuln := false  # lyhyet i-framet vahingon jälkeen

func _physics_process(delta: float) -> void:
	var dir := Input.get_axis("move_left", "move_right")
	velocity.x = dir * speed

	# Flipataan vain sprite (ei koko nodea)
	if dir != 0:
		facing = sign(dir)
		sprite.flip_h = (facing < 0)

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force

	move_and_slide()

func take_damage() -> void:
	if _invuln: return
	_invuln = true
	Game.damage_player()           # autoload/Game.gd
	_flash_invuln()

func _flash_invuln() -> void:
	var t := create_tween().set_loops(6)
	t.tween_property(sprite, "modulate:a", 0.2, 0.06).from(1.0)
	t.tween_property(sprite, "modulate:a", 1.0, 0.06)
	await get_tree().create_timer(invuln_time).timeout
	_invuln = false
	sprite.modulate = Color(1,1,1,1)
```

> Jos sinulla ei ole `Game.gd`-autoloadia, jätä `Game.damage_player()` pois tai lisää autoload (Project Settings → Autoload → `res://autoload/Game.gd`, nimi **Game**).

### 7. Syöteasetukset (Input Map)

Project → Project Settings → **Input Map**:

- `move_left` = A / Left
- `move_right` = D / Right
- `jump` = Space / W / Up
- `interact` = E (jos käytät)

### 8. Kameran seuranta

- **Main.tscn**: lisää **Camera2D** ja tee siitä **Current = On**.
- Sijoita kameraa koodissa pelaajan kohdalle tai tee Camera2D:stä pelaajan lapsi.
- **Zoom** esim. `(0.8, 0.8)` lähemmäs näkymää.

### 9. Tallenna `Player.tscn` ja korvaa vanha

- Avaa **Main.tscn** → varmista että Mainissa on vain yksi Player-instanssi.
- Jos pelaaja instansoidaan koodista, älä lisää toista editorissa.

---

# 2) OLEMASSA OLEVAN PELAAJAN PÄIVITYS

### A) Vaihda hahmon kuva/animointi

- Avaa **Player.tscn** → **Sprite2D** → vaihda **Texture** uuteen.
- Jos käytät **AnimatedSprite2D/AnimationPlayer**, päivitä animaatioframet ja nimet (idle/run/jump).

### B) Säädä fysikaaliset arvot

- `speed`, `jump_force`, `gravity` export-arvoina Inspectorissa.  
   Aloitusarvot: speed 200–260, jump 380–460, gravity 1200–1600.

### C) Törmäysmuodon hienosäätö

- **CollisionShape2D** ei saa olla liian leveä; jalat hieman maan sisäpuolelle → varma lattiaosuma.

### D) Flip korjaukset

- Käytä **`sprite.flip_h = (facing < 0)`** (älä skaalaa koko Nodea).
- Varmista, että animaatio tai parent-node ei skaalaa (Transform → Scale = (1,1)).

### E) InteractZone & HoldSocket peilaus

Lisää peilaus samaan kohtaan, missä asetat `facing`-arvon (hahmon kulkusuunnan muutos):

```gdscript
if dir != 0:
	facing = sign(dir)
	sprite.flip_h = (facing < 0)
	if has_node("InteractZone"):
		$InteractZone.position.x = abs($InteractZone.position.x) * facing
	if has_node("HoldSocket"):
		$HoldSocket.position.x = abs($HoldSocket.position.x) * facing
```

---

# 3) Animaatiotila – yksinkertainen run/idle/jump

Jos käytät **AnimatedSprite2D**:

```
Player
└─ AnimatedSprite2D
```

Annan vain esimerkkilogiikan:

```gdscript
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# ... liike kuten aiemmin
	if not is_on_floor():
		anim.play("jump")
	elif abs(velocity.x) > 1:
		anim.play("run")
	else:
		anim.play("idle")

	anim.flip_h = (facing < 0)
```

---

# 4) Yhteensopivuus muun projektin kanssa

- **Layerit/maskit**: Player = Layer 2, Mask 1|3 (maasto & interaktio).
- **HUD**: jos näytät elämiä/kolikoita, HUD kuuntelee Game-signaaleja (`lives_changed`, `coins_changed`).
- **Vahinko & respawn**: `Enemy/Hazard` kutsuu `player.take_damage()` kun osuu.

---

# 5) Testilista (tee nämä joka kerta)

- Pelaaja syntyy **SpawnPoint**iin (Main.gd hakee sen Levelistä).
- Hyppy toimii ja hahmo **ei putoa** laattojen läpi (näytä Debug → Visible Collision Shapes).
- Flip vasen/oikea toimii eikä venytä spriteä.
- InteractZone osuu palloihin (maski 3).
- Kamera seuraa, zoom tuntuu hyvältä.
- Ei kahta Player-instanssia samaan aikaan (Remote-puu).

---

# 6) Yleiset sudenkuopat

- **Tuplapelaaja**: Player sekä editorissa että koodissa → poista toinen.
- **Sprite venyy**: käytät `sprite.scale.x = direction` kun `direction` on esim. 60; käytä `flip_h`.
- **Törmäys ei toimi**: väärät layerit/maskit; TileMapLayerin collision pois päältä; Cell Size ≠ tilesetin koko.
- **Liike kangertelee**: tee liike **`_physics_process` + `move_and_slide()`**.
