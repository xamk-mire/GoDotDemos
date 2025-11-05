# AI-kuvien (assettien) luominen 2D-peleihin

## ✅ AI-työkalujen käyttö pelispritejen ja grafiikan luomiseen

Tämä ohje auttaa sinua tekemään pelihahmoja, taustoja ja esineitä AI-kuvageneraattoreilla (kuten DALL·E, Midjourney, Stable Diffusion, Leonardo.ai).

---

## ✅ Vaihe 1: Määrittele pelisi tyyli (laajennettu)

Ennen kuin luot kuvia, päätä **pelisi visuaalinen tyyli**. Se tekee grafiikasta yhtenäisen.

### 🎨 A. Taidetyylit

| Tyyli                  | Esimerkkejä                       |
| ---------------------- | --------------------------------- |
| **Pikseligrafiikka**   | retro, 8-bit, 16-bit, SNES        |
| **Sarjakuvamainen**    | paksut ääriviivat, kirkkaat värit |
| **Minimalistinen**     | yksinkertaiset muodot             |
| **Käsin piirretty**    | luonnos tai vesiväri              |
| **Fantasia**           | ritarit, loitsut, lohikäärmeet    |
| **Sci-fi / kyberpunk** | neon, metalli, hologrammit        |
| **Söpö / chibi**       | isot päät, pienet kehot           |
| **Realistinen 2D**     | maalattu tyyli                    |

---

### 👁️ B. Kuvakulma

| Kuvakulma                 | Esimerkkipeli     | Käyttö                        |
| ------------------------- | ----------------- | ----------------------------- |
| **Sivusta (tasohyppely)** | Mario             | Toiminta                      |
| **Ylhäältä**              | Stardew, Pokémon  | RPG                           |
| **Isometrinen**           | Hades             | Strategia / toimintaroolipeli |
| **Edestä**                | Visual Novels     | Hahmopotretit                 |
| **Takaa**                 | Pokémon-kaupungit | Seikkailu                     |

---

### 🎚️ C. Tyylipäätökset

| Asettelu            | Vaihtoehtoja                  |
| ------------------- | ----------------------------- |
| **Sprite-koko**     | 16×16, 32×32, 64×64           |
| **Väripaletti**     | kirkas, pastelli, tumma       |
| **Ääriviivat**      | paksut, ohuet, ei lainkaan    |
| **Varjostus**       | tasainen, cel-shading, pehmeä |
| **Animaation taso** | perusliike / sujuva           |

> ✅ Kirjoita tyylivalinnat muistiin.

Esimerkki:

> 16-bit pikselityyli, 32×32 hahmot, kirkkaat värit, paksut ääriviivat, sivukuva, 4 ruutua animaatioon

---

### 🎭 D. Referenssit

> Esim. Celeste, Stardew Valley värimaailma, Hollow Knightin selkeys

---

## ✅ Vaihe 2: AI-työkalujen käyttö pelispritejen ja grafiikan luomiseen

Tämä ohje auttaa sinua tekemään pelihahmoja, taustoja ja esineitä AI-kuvageneraattoreilla (kuten DALL·E, Midjourney, Stable Diffusion, Leonardo.ai).

Hahmojen generointi onnistuu myös esim. chatGTP:llä.

---

## 🎯 A. Päätä pelin visuaalinen tyyli

| Tyyli            | Esimerkki                         |
| ---------------- | --------------------------------- |
| Pikseligrafiikka | retro-tasohyppely                 |
| Sarjakuvamainen  | kirkkaat värit, paksut ääriviivat |
| Käsin piirretty  | luonnosmainen tyyli               |
| Ylhäältä päin    | RPG-pelit (Zelda-tyyli)           |
| Sivulta          | tasohyppely                       |

Valitse yksi tyyli ja pysy siinä.

---

## ✍️ B. Käytä selkeitä promptteja

1. Määrittele hahmon piirteet tarkasti

   - Esim. "A valiant knight with a silver sword and shield"

2. Määrittele tyyli

   - Esim. "8-bit pixel art style" tai "hand-drawn fantasy style"

3. Määrittele toiminto ja asento

   - Esim. "A knight walking to the right"

4. Määrittele värit ja detailit

   - Esim. "A knight wearing black armor with gold highlights"

5. Tarvittaessa tuo esiin pelimoottori tai alusta
   - Esim. "Sprite sheet for a retro platformer game"

> Mitä tarkemman kuvauksen annat, sitä todennäköisemmin tekoäly tuottaa halutun lopputuloksen.

### Perusmalli

> **[Tyyli] + [Kamera-kulma] + [Hahmo/esine] + [Toiminto] + [Lisätiedot] + läpinäkyvä tausta**

### Esimerkkejä

> 16-bit pikselihahmo, sivusta, seikkailija jolla on reppu selässä, idle-animaatio, kirkkaat värit, yksinkertainen muotoilu, läpinäkyvä tausta

> Cartoon-tyylinen aarrearkku, ylhäältä päin, paksut ääriviivat, kirkkaat värit, pelisprite

---

## 🎬 C. Animaatioiden teko

Pyydä kehys (frame) kerrallaan:

> pikselihahmo, idle-animaatio, kehys 1/4, pieni liike vain

Tai kokonaiseen sprite-sheetiin:

> 2D sprite sheet, kävelyanimaatio, 6 framea, sama hahmo ja mittasuhteet

---

## 🎀 D. Tyylin säilyttäminen

Uusissa promptteissa:

> sama hahmo kuin aiemmin, sama väripaletti ja mittasuhteet, yhtenäinen tyyli

Lataa edellinen kuva referenssiksi, jos mahdollista.

---

## 🧼 E. Siistiminen ja muokkaus

Suositellut ohjelmat:

| Työkalu           | Käyttö                                 |
| ----------------- | -------------------------------------- |
| Aseprite / Piskel | pikselispritejen muokkaus ja animaatio |
| GIMP / Krita      | siistiminen ja läpinäkyvyys            |
| Remove.bg         | taustan poisto                         |

Tarkista:

- ✅ läpinäkyvä tausta (.png)
- ✅ yhtenäinen koko (esim. 32px tai 64px)
- ✅ selkeät ääriviivat

---

## 📦 F. Vie oikeassa muodossa

| Formatti      | Käyttötarkoitus   |
| ------------- | ----------------- |
| PNG           | hahmot ja esineet |
| Sprite sheet  | animaatiot        |
| Eri kerrokset | parallax-taustat  |

---

## 🧠 G. Vinkkejä

- Aloita yksinkertaisilla hahmoilla
- Pysy yhdessä tyylissä
- Muokkaa AI-kuvia itse → parhaat tulokset
- Tallenna versioita

---

## ✅ Vaihe 3: Luo animaatioruudut (laajennettu)

### 🧩 A. Tavalliset animaatiot

| Animaatio     | Liike                         |
| ------------- | ----------------------------- |
| Idle          | hengitys, pieni liike         |
| Kävely        | käsien ja jalkojen vuoroliike |
| Juoksu        | nopeampi, voimakkaampi        |
| Hyppy         | kyykky → hyppy → lasku        |
| Hyökkäys      | lyönti, taika                 |
| Osuma         | reaktio                       |
| Kuolema       | kaatuminen                    |
| Esineen nosto | kumartuminen                  |

---

### 🎞️ B. Kuvaruutujen määrä

| Toiminto | Frameja |
| -------- | ------- |
| Idle     | 2–4     |
| Kävely   | 4–8     |
| Juoksu   | 6–10    |
| Hyppy    | 3–5     |
| Hyökkäys | 4–6     |

---

### ✏️ C. Kuinka käyttää AI:ta

Tee **pieni askel kerrallaan**:

1. Luo perusasento
2. Tee idle-ruudut
3. Tee kävelyruudut
4. Säädä manuaalisesti spritetyökalussa

Suositeltu prompt-muoto:

> pikselihahmo, idle-animaatio, ruutu 1/4, pieni liike vain, sama tyyli ja värit kuin edellisessä, 32×32 sprite, läpinäkyvä tausta

---

### 🧠 D. Vinkkejä

✅ Käytä edellistä ruutua referenssinä  
✅ Pidä liike pienenä pikselitaiteessa  
✅ Tarkista mittasuhteet ja koko  
✅ Muokkaa käsin lopuksi
