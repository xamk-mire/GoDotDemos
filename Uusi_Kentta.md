# 1) Luo Level02

**Vaihtoehto A – Duplaa Level01**

1. FileSystem → `levels/` → oikea klikkaus `Level01.tscn` → **Duplicate** → nimeä **Level02.tscn**.
2. Avaa `Level02.tscn` ja tyhjennä/siirrä elementtejä uutta rakennetta varten.

**Vaihtoehto B – Tyhjästä**

1. New → **2D Scene (Node2D)** → nimeä juureksi **Level02**.
2. Lisää vähintään:

   - **SpawnPoint** (Node2D)
   - **Ground** (**TileMapLayer**, collision ON)
   - **Goal** (Area2D)
   - **Coins** (Coin.tscn -instansseja)
   - **Enemies** (Enemy.tscn -instansseja)
   - (Valinn.) **Checkpoint** (Area2D)
   - (Valinn.) **Parallax2D**-tausta

> **HUOM:** Älä lisää Player/HUD/Camera2D Level02:een – ne ovat Mainissa.

---

# 2) Maan/seinien rakentaminen (TileMapLayer)

Suositeltu kerrosjako Godot 4.5:ssa:

```
Ground           (TileMapLayer, collision Enabled, Layer=1)
OneWayPlatforms  (TileMapLayer, one-way tiles, collision Enabled)
DecorBack        (TileMapLayer, collision Disabled, z_index < 0)
DecorFront       (TileMapLayer, collision Disabled, z_index > 0)
```

Tarkista:

- **Tile Set** viittaa oikeaan `.tres` / sprite sheetiin.
- **Collision Enabled** päällä kerroksilla, joilla pelaajan pitää pysähtyä.
- **Cell Size** = tilesetin ruutukoko (esim. 16×16 / 32×32).

---

# 3) SpawnPoint, Goal, Checkpoint

- **SpawnPoint**: Node2D hieman maan yläpuolella (ettei synny laattojen sisään).
- **Goal**: varmista että on **Area2D** + CollisionShape2D, ja että sen skripti reagoi:

  ```gdscript
  # Goal.gd (Area2D), Godot 4.5
  extends Area2D

  func _ready() -> void:
      body_entered.connect(_on_enter)

  func _on_enter(body: Node) -> void:
      if body.name == "Player":
          print("Level complete!")  # myöhemmin: tason vaihto / HUD-viesti
  ```

- **Checkpoint** (valinn.): Area2D joka kutsuu `Game.set_spawn(global_position)`.

---

# 4) Kolikot, viholliset ja hazardit

- **Coin.tscn**: instansoi reitille; Coin.gd kutsuu `Game.add_coin(value)`.
- **Enemy.tscn**: varmistettu kääntyminen – käytä **RayCast2D**-tarkistuksia.  
   Raycastien **Collision Mask** sisältää **Layer 1** (maa/seinät).
- **Hazard.tscn**: Area2D joka kutsuu `player.take_damage()`.

**Layers & Masks (kertaus):**

- Ground/seinät: **Layer 1**, Mask 0
- Player (CharacterBody2D): **Layer 2**, **Mask 1 | 3**
- Ball/interaktiot: **Layer 3**, **Mask 1 | 2**
- Enemy RayCast2D **Mask: 1** (vain maa/seinät)

---

# 5) Lisää taustakuva / background (Godot 4.5)

Esimerkiksi **Parallax2D + Sprite2D**:

```
Background (Node2d, z_index = -100)
 ├─ BackLayer  (Parallax2D, Scroll Scale=0,2)
 │   └─ Sprite2D (Texture->Repeat: Enabled, Centered: On)
 ├─ MidLayer   (Parallax2D, Scroll Scale=0,5)
 │   └─ Sprite2D
 └─ ForeLayer  (Parallax2D, Scroll Scale=0,4)
     └─ Sprite2D
```

Voit tarvittaessa lisätä useampia kerroksia tarpeen mukaan

- Muista huomioida scroll scale:n arvo

Liimaa tausta kameran lähtöpositioon (taso- tai Main-koodissa) ennen ensimmäistä framea:

```gdscript
func _ready() -> void:
    await get_tree().process_frame
    var cam := get_viewport().get_camera_2d()
    var par := $Parallax2D
    if cam and par:
        par.global_position = cam.global_position
```

> Jos taustatekstuuri on kapea, kasvata **Repeat Size** sekä/tai **Repeat Times** arvoja, tai vaihtoehtoisesti käytä leveämpää tekstuuria.

---

# 6) Kameran rajat (Camera2D limits) TileMapLayerista

Jos Main laskee rajat **kaikista** TileMapLayereistä:

```gdscript
# Main.gd, kun current_level on lisätty ja puu prosessoitu
var used := Rect2i()
var first := true

for c in current_level.get_children():
    if c is TileMapLayer:
        var r: Rect2i = c.get_used_rect()
        used = r if first else used.merge(r)
        first = false

if not first:
    var ts := (current_level.get_node("Ground") as TileMapLayer).tile_set.tile_size
    var px := Rect2(used.position * ts, used.size * ts)
    $Camera2D.limit_left   = int(px.position.x)
    $Camera2D.limit_top    = int(px.position.y)
    $Camera2D.limit_right  = int(px.position.x + px.size.x)
    $Camera2D.limit_bottom = int(px.position.y + px.size.y)
    $Camera2D.limit_smoothed = true
```

---

# 7) Kytke Level02 Mainiin

**A) Nopea testi** – vaihda polku:

```gdscript
const LEVEL_PATH := "res://levels/Level02.tscn"
var level_scene: PackedScene = load(LEVEL_PATH)
```

**B) Monitasoinen peli** – käytä taulukkoa:

```gdscript
@export var level_scenes: Array[PackedScene] = []  # lisää Level01 & Level02 Inspectorissa
var current_index := 0

func load_level(i: int) -> void:
    if i < 0 or i >= level_scenes.size(): return
    if current_level: current_level.queue_free()
    current_level = level_scenes[i].instantiate()
    current_level.name = "Level"
    add_child(current_level)
    await get_tree().process_frame

    var spawn := current_level.find_child("SpawnPoint", true, false) as Node2D
    var pos: Vector2 = spawn.global_position if spawn else Vector2.ZERO
    $Player.global_position = pos
    Game.reset_for_level(pos)

func _ready() -> void:
    Game.new_game()
    load_level(current_index)
```

> **GDScript 4.5 huomio:** käytä ehtolauseketta muodossa `A if cond else B` (ei `? :`).

---

# 8) Testilista (Godot 4.5)

- **Remote**-puussa vain **yksi** `Level` (ei kaksoisinstansointia).
- Player syntyy **SpawnPointiin** (nimi/osuma oikein).
- **Debug → Visible Collision Shapes** näyttää laattojen kollisiot.
- Enemy kääntyy seinässä → RayCast2D:t enable + maski **1** + `target_position` päivittyy suunnan mukaan.
- Coinit kerääntyvät; **Game.add_coin** löytyy ja HUD kuuntelee `coins_changed`.
- Goal reagoi `body_entered` → tulostus/HUD-viesti/ladon seuraava taso.
- Parallax ei vilahda ulos ruudusta startissa (liimaus + mirroring).
- Camera2D ei näytä tason ulkopuolelle (limits ok).

---

# 9) Yleisimmät virheet 4.5:ssä ja korjaus

- **Taso renderöityy kahdesti**: Level02 on sekä editorissa että koodissa → poista jompikumpi.
- **SpawnPoint ei löydy**: käytä `find_child("SpawnPoint", true, false)` tai oikea suhteellinen polku.
- **“Nonexistent function add_coin”**: lisää `add_coin()` takaisin `Game.gd`:hen ja emit `coins_changed`.
- **Enemy jää seinään**: muista päivittää `RayCast2D.target_position` kun suunta vaihtuu (ei vain siirtää nodea).
- **GDScript ternary -virhe**: käytä `B if A else C`, älä `A ? B : C`.
- **Parallax-virheet**: aseta arvot **ParallaxLayer2D**-solmulle (ei Sprite2D:lle), Texture → **Repeat: Enabled**.

---

# 10) Ideoita Level02:een

- Uusi mekaaninen elementti (liikkuva taso, trampoliini, liukas jää).
- Valinnainen bonusreitti vaikeammilla hyppyhaasteilla.
- Uusi vihollistyyppi / hazard (piikkiputki, liikkuva este).
- Teemallinen muutos (yö/luola/metsä), oma **Parallax2D**-tausta.
- Pieni puzzle (avain + ovi).
