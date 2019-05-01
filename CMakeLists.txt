cmake_minimum_required(VERSION 3.0)

set(CMAKE_VERBOSE_MAKEFILE ON)

project(pchtest CXX)
set(CMAKE_VERBOSE_MAKEFILE ON)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

add_executable(${PROJECT_NAME} "main.cpp" "pch.cpp" "pch.h" "pch_dummy.cpp")
add_compile_options(${PROJECT_NAME} PUBLIC -Wall -Werror -Winvalid-pch)

set_source_files_properties(pch.cpp PROPERTIES COMPILE_OPTIONS "-x;c++-header" OBJECT_DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/pchtest.dir/pch_dummy.cpp.o)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/pch.h.gch
    COMMAND ${CMAKE_COMMAND} -E rename ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/pchtest.dir/pch.cpp.o ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/pch.h.gch
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/pchtest.dir/pch_dummy.cpp.o ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/pchtest.dir/pch.cpp.o
    COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/pch.h.gch

    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/pchtest.dir/pch.cpp.o
    COMMENT "Copy PCH"
)

set_source_files_properties(main.cpp PROPERTIES OBJECT_DEPENDS ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/pch.h.gch COMPILE_OPTIONS "-include;${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/pch.h")
