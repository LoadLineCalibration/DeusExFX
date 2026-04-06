# DeusExFX

# NOTE: WIP! No download yet!

For quite a long time, there has been a tool called **UnrealFX** for working with models in the Unreal `.3d` format. It allows editing polyflags.

However, there has never been a proper equivalent for the **Deus Ex `.3d` format**, which differs from the Unreal version by having higher precision.

Now, such a tool finally exists.
You can download it and use it to edit your models.

## Program interface
<p align="center"><img width="899" height="968" alt="Adam Jensen model from the DeusEx: Machine God mod" src="https://github.com/user-attachments/assets/e82c2ccd-1686-431f-bd29-6d40a3be7206" /></p>
<p align="center">Adam Jensen model from the DeusEx: Machine God mod</p>



---

## Polygon Properties

### Polygon Types

* **Normal** — regular polygon
* **Two Sided** — rendered from both sides
* **Translucent and Two Sided** — transparent and double-sided
* **Masked and Two Sided** — for textures with transparent areas (masked rendering)
* **Modulated and Two Sided** — modulated transparency + double-sided
* **Weapon Triangle** — special type used by the engine to attach weapons (typically for NPCs)

---

### Polygon Flags

* **Unlit** — ignores lighting and appears self-lit
  *(example: lamps on public terminals)*
* **Flat** — flat shading (exact behavior unclear)
* **Environment Mapped** — adds reflective shine; requires a valid texture assigned to the actor’s `Texture` field
* **No Smoothing** — disables texture filtering, resulting in a pixelated look

---

## Interface

The interface is inspired by UnrealFX, but all controls are combined into a single window.

> **Important:**
> Changes to **Type**, **Flags**, and **Material Num** are applied instantly only if **"Apply automatically"** is enabled.

### Viewport Options

* Toggle axis indicator
* Show/hide **Bounding Box / Bounding Sphere**
* Enable/disable backface culling (including proper handling of two-sided polygons)

---

## Shading Controls

* **ShadeDiffuse** and **ShadeAmbient** sliders are available only in:

  * *Flat Shaded*
  * *Smooth Shaded*

Shading modes can be switched via the viewport context menu.

---

## Controls

* **Right Mouse Button + Move** — rotate model
* **Left + Right Mouse Button + Move** — pan model
* **Mouse Wheel** — zoom in/out

---

## Polygon Selection

* **Left Mouse Button + Drag** — select multiple polygons within a region
* **Left Mouse Button** — select a single polygon
* **Left Mouse Button + Ctrl / Shift** — add to selection

---

