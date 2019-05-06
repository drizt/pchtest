cmake_minimum_required(VERSION 3.0)

project(pchtest C CXX)
set(CMAKE_VERBOSE_MAKEFILE ON)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5Widgets REQUIRED)
set(CMAKE_AUTOMOC ON)

set(SOURCES main.cpp dialog.h dialog.cpp pch.h)

if(APPLE)
    list(APPEND SOURCES func.mm)
endif()

add_executable(${PROJECT_NAME} ${SOURCES})
add_compile_options(${PROJECT_NAME} PUBLIC -Wall -Werror)
target_link_libraries(${PROJECT_NAME} Qt5::Widgets)
if(APPLE)
    target_link_libraries(${PROJECT_NAME} "-framework Foundation")
endif()

include(${CMAKE_CURRENT_LIST_DIR}/PchLinkTarget.cmake)
pch_link_target(${PROJECT_NAME} pch.h)

