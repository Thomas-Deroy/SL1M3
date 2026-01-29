//-----------------------------------------------------------------
// Main Game File
// C++ Source - Game.cpp
//-----------------------------------------------------------------

#include "Game.h"
#include <iostream>

//-----------------------------------------------------------------
// Game Member Functions																				
//-----------------------------------------------------------------

Game::Game()
{
}

Game::~Game()
{
}

void Game::Initialize()
{
	// Enable debug console for Lua prints 
	// AllocConsole(); 
	// FILE* fp; freopen_s(&fp, "CONOUT$", "w", stdout);
	// freopen_s(&fp, "CONOUT$", "w", stderr); 
	// std::cout << "[C++] Console ready" << std::endl;

	// Setup Lua standard libraries
	m_Lua.open_libraries(
		sol::lib::base,
		sol::lib::math,
		sol::lib::string,
		sol::lib::table,
		sol::lib::package,
		sol::lib::io,
		sol::lib::os
	);

	// Expose engine API to Lua
	auto engine = m_Lua.create_named_table("Engine");

	// Window control
	engine.set_function("SetTitle", [&](std::string title) {
		std::wstring wTitle(title.begin(), title.end());
		GAME_ENGINE->SetTitle(wTitle.c_str());
		});
	engine.set_function("SetWidth", [&](int w) { GAME_ENGINE->SetWidth(w); });
	engine.set_function("SetHeight", [&](int h) { GAME_ENGINE->SetHeight(h); });
	engine.set_function("SetFrameRate", [&](int fps) { GAME_ENGINE->SetFrameRate(fps); });

	// Input
	engine.set_function("SetKeyList", [&](std::string keys) {
		std::wstring wKeys(keys.begin(), keys.end());
		GAME_ENGINE->SetKeyList(wKeys.c_str());
		});
	engine.set_function("IsKeyDown", [&](int key) {
		return GAME_ENGINE->IsKeyDown(key);
		});

	// Basic drawing
	engine.set_function("DrawRect", [&](int x, int y, int w, int h) {
		GAME_ENGINE->DrawRect(x, y, x + w, y + h);
		});
	engine.set_function("FillRect", [&](int x, int y, int w, int h) {
		GAME_ENGINE->FillRect(x, y, x + w, y + h);
		});
	engine.set_function("FillRectAlpha", [&](int x, int y, int w, int h, int alpha) {
		GAME_ENGINE->FillRect(x, y, x + w, y + h, alpha);
		});
	engine.set_function("SetColor", [&](int r, int g, int b) {
		GAME_ENGINE->SetColor(RGB(r, g, b));
		});

	// Font binding
	m_Lua.new_usertype<Font>(
		"Font",
		sol::factories([](std::string name, bool bold, bool italic, bool underline, int size) {
			std::wstring wName(name.begin(), name.end());
			return new Font(wName, bold, italic, underline, size);
			}),
		"LoadFile", &Font::LoadFile
	);

	engine.set_function("SetFont", [&](Font* font) {
		if (font) GAME_ENGINE->SetFont(font);
		});
	engine.set_function("DrawString", [&](std::string text, int x, int y) {
		std::wstring wText(text.begin(), text.end());
		GAME_ENGINE->DrawString(wText, x, y);
		});

	// Bitmap binding
	m_Lua.new_usertype<Bitmap>(
		"Bitmap",
		sol::factories([](std::string filename) -> Bitmap* {
			std::wstring wFile;
			if (!filename.empty())
			{
				int size = MultiByteToWideChar(CP_UTF8, 0, filename.data(),
					(int)filename.size(), nullptr, 0);
				wFile.resize(size);
				MultiByteToWideChar(CP_UTF8, 0, filename.data(),
					(int)filename.size(), &wFile[0], size);
			}
			try { return new Bitmap(wFile, true); }
			catch (...) { return nullptr; }
			}),
		"GetWidth", &Bitmap::GetWidth,
		"GetHeight", &Bitmap::GetHeight,
		"SetOpacity", &Bitmap::SetOpacity,
		"GetOpacity", &Bitmap::GetOpacity
	);

	// Bitmap drawing
	engine.set_function("DrawBitmap", [&](Bitmap* bmp, int x, int y) {
		if (bmp) GAME_ENGINE->DrawBitmap(bmp, x, y);
		});
	engine.set_function(
		"DrawBitmapRect",
		[&](Bitmap* bmp, int x, int y, int srcX, int srcY, int srcW, int srcH, int destW, int destH)
		{
			if (!bmp) return;
			RECT src{ srcX, srcY, srcX + srcW, srcY + srcH };
			GAME_ENGINE->DrawBitmap(bmp, x, y, src, destW, destH);
		}
	);

	// Audio binding
	m_Lua.new_usertype<Audio>(
		"Audio",
		sol::factories([](std::string filename) -> Audio* {
			std::wstring wFile;
			if (!filename.empty())
			{
				int size = MultiByteToWideChar(CP_UTF8, 0, filename.data(),
					(int)filename.size(), nullptr, 0);
				wFile.resize(size);
				MultiByteToWideChar(CP_UTF8, 0, filename.data(),
					(int)filename.size(), &wFile[0], size);
			}

			try { return new Audio(wFile); }
			catch (...) { return nullptr; }
			}),
		"Play", [](Audio& a) { a.Play(0, -1); },
		"PlayRange", &Audio::Play,
		"Stop", &Audio::Stop,
		"Pause", &Audio::Pause,
		"SetVolume", &Audio::SetVolume,
		"SetRepeat", &Audio::SetRepeat,
		"IsPlaying", &Audio::IsPlaying,
		"Exists", &Audio::Exists,
		"Tick", &Audio::Tick
	);

	engine.set_function("Quit", [&]() {
		GAME_ENGINE->Quit();
		});

	// Pick script (drag & drop or default)
	std::string scriptFile = "game_SL1M3.lua";
	int nArgs{};
	LPWSTR* args = CommandLineToArgvW(GetCommandLineW(), &nArgs);

	if (args && nArgs > 1)
	{
		std::wstring wPath = args[1];
		int size = WideCharToMultiByte(CP_UTF8, 0, wPath.data(), (int)wPath.size(), nullptr, 0, nullptr, nullptr);
		scriptFile.resize(size);
		WideCharToMultiByte(CP_UTF8, 0, wPath.data(), (int)wPath.size(), scriptFile.data(), size, nullptr, nullptr);
	}

	if (args) LocalFree(args);

	// Load Lua script
	try
	{
		auto result = m_Lua.script_file(scriptFile);
		if (!result.valid())
		{
			sol::error err = result;
			MessageBoxA(nullptr, err.what(), "Lua Script Error", MB_ICONERROR);
		}
	}
	catch (const sol::error& e)
	{
		MessageBoxA(nullptr, e.what(), "Lua Exception", MB_ICONERROR);
	}

	// Call Lua Initialize()
	sol::protected_function luaInit = m_Lua["Initialize"];
	if (luaInit.valid())
		luaInit();
}

void Game::Start()
{
	sol::protected_function fn = m_Lua["GameStart"];
	if (fn.valid()) fn();
}

void Game::End()
{
	sol::protected_function fn = m_Lua["GameEnd"];
	if (fn.valid()) fn();
}

void Game::Paint(RECT rect) const
{
	sol::protected_function fn = m_Lua["Paint"];
	if (fn.valid()) fn();
}

void Game::Tick()
{
	// Calculate delta time
	static ULONGLONG lastTime = GetTickCount64();
	ULONGLONG currentTime = GetTickCount64();

	float deltaTime = (currentTime - lastTime) / 1000.0f;
	lastTime = currentTime;

	if (deltaTime > 0.1f) deltaTime = 0.1f;

	// Update Lua
	sol::protected_function fn = m_Lua["Tick"];
	if (fn.valid()) {
		auto result = fn(deltaTime);
		if (!result.valid()) {
			sol::error err = result;
			std::cout << "[Lua Tick Error] " << err.what() << std::endl;
		}
	}
}

void Game::MouseButtonAction(bool isLeft, bool isDown, int x, int y, WPARAM wParam)
{
	sol::protected_function fn = m_Lua["OnMouseButton"];
	if (fn.valid()) fn(isLeft, isDown, x, y);
}

void Game::MouseWheelAction(int x, int y, int distance, WPARAM wParam)
{
	sol::protected_function fn = m_Lua["OnMouseWheel"];
	if (fn.valid()) fn(x, y, distance);
}

void Game::MouseMove(int x, int y, WPARAM wParam)
{
	sol::protected_function fn = m_Lua["OnMouseMove"];
	if (fn.valid()) fn(x, y);
}

void Game::CheckKeyboard()
{
	sol::protected_function fn = m_Lua["CheckKeyboard"];
	if (fn.valid()) fn();
}

void Game::KeyPressed(TCHAR key)
{
	sol::protected_function fn = m_Lua["OnKeyPressed"];
	if (fn.valid()) fn((int)key);
}

void Game::CallAction(Caller* callerPtr)
{
}
