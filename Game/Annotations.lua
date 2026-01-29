---@class Engine
---Global access to the engine API.
Engine = {}

-- =============================================================
-- WINDOW & SYSTEM
-- =============================================================

---Set the window title.
---@param title string
function Engine.SetTitle(title) end

---Set the internal render width.
---@param width number
function Engine.SetWidth(width) end

---Set the internal render height.
---@param height number
function Engine.SetHeight(height) end

---Limit the game to a target FPS.
---@param fps number
function Engine.SetFrameRate(fps) end

---Close the application.
function Engine.Quit() end

-- =============================================================
-- INPUT
-- =============================================================

---Define which keys the engine should track (e.g. "WASD").
---@param keys string
function Engine.SetKeyList(keys) end

---Check if a key is currently held down.
---@param key number ASCII key code (e.g. 65 = 'A')
---@return boolean
function Engine.IsKeyDown(key) end

-- =============================================================
-- DRAWING
-- =============================================================

---Draw a rectangle outline.
---@param x number Top-left X
---@param y number Top-left Y
---@param w number Width
---@param h number Height
function Engine.DrawRect(x, y, w, h) end

---Draw a filled rectangle.
---@param x number Top-left X
---@param y number Top-left Y
---@param w number Width
---@param h number Height
function Engine.FillRect(x, y, w, h) end

---Draw a filled rectangle with transparency.
---@param x number Top-left X
---@param y number Top-left Y
---@param w number Width
---@param h number Height
---@param alpha number 0 = transparent, 255 = solid
function Engine.FillRectAlpha(x, y, w, h, alpha) end

---Set the current draw color.
---@param r number 0–255
---@param g number 0–255
---@param b number 0–255
function Engine.SetColor(r, g, b) end

---Set the font used for text drawing.
---@param font Font
function Engine.SetFont(font) end

---Draw text on screen.
---@param text string
---@param x number
---@param y number
function Engine.DrawString(text, x, y) end

---Draw an image at its original size.
---@param bitmap Bitmap
---@param x number
---@param y number
function Engine.DrawBitmap(bitmap, x, y) end

---Draw part of an image, scaled to a destination size.
---@param bitmap Bitmap
---@param x number Screen X
---@param y number Screen Y
---@param srcX number Source X
---@param srcY number Source Y
---@param srcW number Source width
---@param srcH number Source height
---@param destW number Output width
---@param destH number Output height
function Engine.DrawBitmapRect(bitmap, x, y, srcX, srcY, srcW, srcH, destW, destH) end

-- =============================================================
-- FONT
-- =============================================================

---@class Font
---@field new fun(name:string, bold:boolean, italic:boolean, underline:boolean, size:number): Font
Font = {}

---Load a .ttf font file so it can be used by name.
---@param filepath string
function Font.LoadFile(filepath) end

-- =============================================================
-- BITMAP
-- =============================================================

---@class Bitmap
Bitmap = {}

---Load an image from disk.
---@param filename string
---@return Bitmap
function Bitmap.new(filename) end

---Get image width in pixels.
---@return number
function Bitmap:GetWidth() end

---Get image height in pixels.
---@return number
function Bitmap:GetHeight() end

---Set image opacity (if supported).
---@param opacity number
function Bitmap:SetOpacity(opacity) end

---Get current image opacity.
---@return number
function Bitmap:GetOpacity() end

-- =============================================================
-- AUDIO
-- =============================================================

---@class Audio
Audio = {}

---Load an audio file.
---@param filename string
---@return Audio
function Audio.new(filename) end

---Play the audio from the start.
function Audio:Play() end

---Play a specific section of the audio.
---@param start number
---@param stop number
function Audio:PlayRange(start, stop) end

---Stop playback.
function Audio:Stop() end

---Pause playback.
function Audio:Pause() end

---Set volume (0–100).
---@param volume number
function Audio:SetVolume(volume) end

---Enable or disable looping.
---@param repeat boolean
function Audio:SetRepeat(shouldRepeat) end

---Check if the audio is currently playing.
---@return boolean
function Audio:IsPlaying() end

---Check if the file loaded correctly.
---@return boolean
function Audio:Exists() end

---Update audio state (call every frame).
function Audio:Tick() end
