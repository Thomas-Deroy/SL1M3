cmake_minimum_required(VERSION 3.14)
project(LuaGameEngine)

# Use C++20
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Windows: Unicode + avoid min/max macros
add_compile_definitions(UNICODE _UNICODE NOMINMAX)

# -----------------------------
# Lua & Sol2 setup
# -----------------------------

# Lua source location
set(LUA_DIR "${CMAKE_SOURCE_DIR}/resources/libraries/lua")

# Collect Lua sources (no executables)
file(GLOB LUA_C_SOURCES "${LUA_DIR}/*.c")
list(FILTER LUA_C_SOURCES EXCLUDE REGEX "lua\\.c$")
list(FILTER LUA_C_SOURCES EXCLUDE REGEX "luac\\.c$")

# Build Lua as static library
add_library(Lua STATIC ${LUA_C_SOURCES})
set_target_properties(Lua PROPERTIES LANGUAGE C)
target_include_directories(Lua PUBLIC ${LUA_DIR})

# Fetch Sol2 bindings
include(FetchContent)
FetchContent_Declare(
    sol2
    GIT_REPOSITORY https://github.com/ThePhD/sol2.git
    GIT_TAG v3.3.0
)
FetchContent_MakeAvailable(sol2)

# -----------------------------
# Project files
# -----------------------------
set(INC_DIR  "${CMAKE_SOURCE_DIR}/inc")
set(SRC_DIR  "${CMAKE_SOURCE_DIR}/src")
set(GAME_DIR "${CMAKE_SOURCE_DIR}/game")

file(GLOB SOURCES "${SRC_DIR}/*.cpp")
file(GLOB HEADERS "${INC_DIR}/*.h")
file(GLOB GAME_ASSETS "${GAME_DIR}/*.*")

# -----------------------------
# Executable
# -----------------------------

# WIN32
add_executable(${PROJECT_NAME} WIN32
    ${SOURCES}
    ${HEADERS}
    ${GAME_ASSETS}
)

target_include_directories(${PROJECT_NAME} PRIVATE ${INC_DIR} ${SRC_DIR})
target_link_libraries(${PROJECT_NAME} PRIVATE sol2::sol2 Lua)

# Required Windows libraries
if(WIN32)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        kernel32 user32 gdi32 winspool comdlg32
        advapi32 shell32 ole32 oleaut32 uuid odbc32 odbccp32
    )
endif()

# -----------------------------
# Assets & runtime
# -----------------------------

# Final executable directory
set(TARGET_OUTPUT_DIR $<TARGET_FILE_DIR:${PROJECT_NAME}>)

# Asset path for runtime use
target_compile_definitions(${PROJECT_NAME} PRIVATE ASSET_PATH="${TARGET_OUTPUT_DIR}")

# Copy assets after build
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${GAME_DIR} ${TARGET_OUTPUT_DIR}
    COMMENT "Copying assets"
)

# Debug from output folder (VS)
set_target_properties(${PROJECT_NAME} PROPERTIES
    VS_DEBUGGER_WORKING_DIRECTORY "${TARGET_OUTPUT_DIR}"
)
