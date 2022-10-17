cmake_minimum_required (VERSION 3.8)

enable_language(ASM_NASM)

set(CMAKE_ASM_NASM_FLAGS_DEBUG "-g -F cv8")

set(CMAKE_ASM_NASM_LINK_EXECUTABLE "<CMAKE_LINKER> <CMAKE_ASM_NASM_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  /OUT:<TARGET> <LINK_LIBRARIES>")
set(CMAKE_ASM_NASM_LINK_FLAGS "/ENTRY:main")

add_executable (nasm_tutorial main.asm calc.asm)
