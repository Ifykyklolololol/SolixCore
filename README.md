<!-- HEADER -->
<div align="center">

  <img src="https://github.com/Ifykyklolololol/images/blob/main/FullPreview.png?raw=true" width="150">

  <h1>Solix ESP Library</h1>

  <p>
    High-performance, fully customizable ESP system for Roblox exploits.<br>
    Built for the Solix Team.
  </p>

</div>

---

## 📚 Table of Contents
<details>
  <summary><strong>Expand</strong></summary>
  <ol>
    <li><a href="#boundingbox">BoundingBox</a></li>
    <li><a href="#bars">Bars</a></li>
    <li><a href="#distance">Distance</a></li>
    <li><a href="#name">Name</a></li>
    <li><a href="#weapon--tool">Weapon / Tool</a></li>
    <li><a href="#flags">Flags</a></li>
    <li><a href="#credits">Credits</a></li>
  </ol>
</details>

---

## Features

---

## 🔲 BoundingBox
<a id="boundingbox"></a>

<img src="https://github.com/Ifykyklolololol/images/blob/main/BoundingBoxPreview.png?raw=true" width="200">

```
Enabled -> true / false
DynamicBox -> true / false
IncludeAccessories -> true / false

Color -> { Color3, Color3 }
Transparency -> { number, number }
Rotation -> 0–360 degrees

Glow
Enabled -> true / false
Color -> { Color3, Color3 }
Transparency -> { number, number }
Rotation -> 0–360 degrees

Fill
Enabled -> true / false
Color -> { Color3, Color3 }
Transparency -> { number, number }
Rotation -> 0–360 degrees
```


<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 📊 Bars
<a id="bars"></a>

<img src="https://github.com/Ifykyklolololol/images/blob/main/BarsPreview.png?raw=true" width="150">

```
Enabled -> true / false
Position -> "Left" / "Right" / "Top" / "Bottom"

Color -> { Color3, Color3, Color3 }
(3-point gradient)

Type(Player) -> returns 0–1 (bar fill percentage)

Text
Enabled -> true / false
FollowBar -> true / false
Ending -> string ("", "%", etc)
Position -> "Left" / "Right" / "Top" / "Bottom"
(ignored if FollowBar = true)
Color -> Color3
Transparency -> number (0–1)

Type(Player)
    Returns:
        value      -> number shown
        visibility -> true/false
```


<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 📏 Distance
<a id="distance"></a>

<img src="https://github.com/Ifykyklolololol/images/blob/main/DistancePreview.png?raw=true" width="150">

```
Enabled -> true / false
Ending -> "st" / "m" / custom string
Position -> "Top" / "Bottom" / "Left" / "Right"

Color -> Color3
Transparency -> number (0–1)
```


<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🏷️ Name
<a id="name"></a>

<img src="https://github.com/Ifykyklolololol/images/blob/main/NamePreview.png?raw=true" width="150">

```
Enabled -> true / false
UseDisplay -> true / false
(DisplayName or Username)

Position -> "Top" / "Bottom" / "Left" / "Right"
Color -> Color3
Transparency -> number (0–1)
```


<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🔫 Weapon / Tool
<a id="weapon--tool"></a>

<img src="https://github.com/Ifykyklolololol/images/blob/main/ToolPreview.png?raw=true" width="150">

```
Enabled -> true / false
Position -> "Top" / "Bottom" / "Left" / "Right"

Color -> Color3
Transparency -> number (0–1)

Displays currently equipped tool
If none -> shows "none"
```


<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

<a id="model-esp"></a>

<img src="https://github.com/Ifykyklolololol/images/blob/main/ModelPreview.png?raw=true" width="150">

```

ESP.AddTarget(instance)

instance -> ANY BasePart or Model path
            Examples:
                workspace.Part
                workspace.Model
                workspace.NPC
                workspace.EnemyFolder.Enemy1

This enables ESP on:
    • Models
    • Parts
    • NPCs
    • Items
    • Objects
    • Literally ANYTHING with a position

```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🚩 Flags
<a id="flags"></a>

<img src="https://github.com/Ifykyklolololol/images/blob/main/FlagsPreview.png?raw=true" width="150">

```
Enabled -> true / false
Position -> "Left" / "Right"

Color -> Color3
Transparency -> number (0–1)

Type(Player)
Returns:
"moving" -> player is walking
"jumping" -> player is jumping
```


<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## ❤️ Credits
<a id="credits"></a>

**Developed by RelixEnd**  
For the **Solix Team**

<p align="right">(<a href="#readme-top">back to top</a>)</p>

