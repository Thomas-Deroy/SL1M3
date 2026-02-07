# SL1M3

<table width="100%">
  <tr>
    <td width="70%" align="left">
      <p><b>A 2D platformer where the game tries to delete you.</b></p>
      <p><i>Built with a Custom C++ Engine & Lua Scripting</i></p>
    </td>
    <td width="30%" align="right">
      <img src="Game/SL1M3/Assets/gifs/logo.png" width="200" alt="SL1M3 Logo" />
    </td>
  </tr>
</table>

---

## 📸 Media & Demo

<table align="center">
  <tr>
    <td align="center"><b>Main Menu</b></td>
    <td align="center"><b>Customization Shop</b></td>
    <td align="center"><b>Gameplay</b></td>
  </tr>
  <tr>
    <td><img src="Game/SL1M3/Assets/gifs/Menu_SL1M3.gif" width="250px" alt="Menu"/></td>
    <td><img src="Game/SL1M3/Assets/gifs/Shop_SL1M3.gif" width="250px" alt="Shop System"/></td>
    <td><img src="Game/SL1M3/Assets/gifs/Gameplay_SL1M3.gif" width="250px" alt="Gameplay"/></td>
  </tr>
</table>

---

## 🎮 The Concept

In **SL1M3**, survival is a race against time and data corruption. Players must navigate an endless sequence of increasingly difficult levels while a **constantly advancing laser** erases the world behind them. 

The catch? The game is trying to delete you as you progress. Move fast, or be erased.

---

## 🛠️ Technical Implementation

This project was developed for a Software Engineering course, focusing on the interface between low-level engine architecture and high-level gameplay scripting.

* **Custom C++ Engine:** Game Engine provided by DAE.
* **Lua-C++ Bindings:** I wrote the bridge between the engine and the script, allowing the C++ core to execute high-level Lua logic.
* **Gameplay Scripting:** 100% of the game logic—including player movement, level triggers, and the "deletion" mechanic—was written by me in Lua.
* **Systems Design:** Created a functional **Shop System** for purchasing skins and a modular hazard system (jump pads, teleporters, lasers).

---

## 🎨 Art & Assets
I served as the sole technical artist for this project, creating:
* Original 2D sprite work for the slime and environment.
* UI/UX design for the menu and shop interfaces.
* Visual effects (VFX) for mechanical interactions like teleporting.

---

## 🚀 How to Run
> **Note:** This project was built for Windows/OpenGL.  (Drag game_SL1M3.lua on the .exe to run)

   ```bash
   Game/LuaGameEngine.exe
