cmake_minimum_required(VERSION 3.0)

set(CMAKE_VERBOSE_MAKEFILE ON)

function(pch_wrap res pch_header)
    if (ARGN)
        list(GET ARGN 0 langid)
    else()
        get_property(enabled_langs GLOBAL PROPERTY ENABLED_LANGUAGES)
        list(FIND enabled_langs CXX index)
        if(index STREQUAL -1)
            list(GET enabled_langs 0 langid)
        else()
            set(langid CXX)
        endif()
    endif()

    if(langid STREQUAL C)
        set(source_ext c)
    elseif(langid STREQUAL CXX)
        set(source_ext cpp)
    endif()
    get_filename_component(base_name ${pch_header} NAME_WE)

    set(files_dir "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}")
    set(support_dir "${files_dir}/pch_gen.dir")
    set(base_name "${support_dir}/${base_name}")

    file(MAKE_DIRECTORY ${support_dir})
    file(WRITE ${base_name}.${source_ext} "#include <${pch_header}>\n")
    file(WRITE ${base_name}_dummy.${source_ext} "/* dummy file */\n")

    set(pch_list "${pch_header};${base_name}.${source_ext};${base_name}_dummy.${source_ext}")
    set_source_files_properties(${pch_header} PROPERTIES PCH_LANGID ${langid})
    set_source_files_properties(${pch_list} PROPERTIES
        PCH_GENERATED TRUE
        SKIP_AUTOMOC TRUE
    )
    set_source_files_properties(${base_name}.${source_ext};${base_name}_dummy.${source_ext} PROPERTIES GENERATED TRUE)
    set("${res}" ${pch_list} PARENT_SCOPE)
endfunction()

function(pch_link_target target)
    # Force to check correct pch header
    target_compile_options(${target} PUBLIC "-Winvalid-pch")


    get_target_property(sources ${target} SOURCES)

    set(files_dir "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}")
    set(support_dir "${files_dir}/${CMAKE_PROJECT_NAME}.dir/${CMAKE_FILES_DIRECTORY}/pch_gen.dir")

    foreach(s ${sources})
        # Find pch header
        get_source_file_property(langid ${s} PCH_LANGID)
        if(langid STREQUAL C)
            set(lang_flag c-header)
            set(source_ext c)
        elseif(langid STREQUAL CXX)
            set(lang_flag c++-header)
            set(source_ext cpp)
        endif()

        if(langid)
            get_filename_component(base_name ${s} NAME_WE)

            set(pch_path "${support_dir}/${base_name}.h") # /../CMakeFiles/pchtest.dir/pch.h
            set(gch_path "${support_dir}/${base_name}.h.gch") # /../CMakeFiles/pchtest.dir/pch.h.gch
            set(src_path "${files_dir}/pch_gen.dir/${base_name}.${source_ext}") # /../CMakeFiles/pch_gen.dir/pch.cpp
            set(obj_path "${support_dir}/${base_name}.${source_ext}.o") # /../CMakeFiles/pchtest.dir/pch.cpp.o
            set(dummy_path "${files_dir}/pch_gen.dir/${base_name}_dummy.${source_ext}") # /../CMakeFiles/pch_gen/pch_dummy.cpp
            set(dummy_obj_path "${support_dir}/${base_name}_dummy.${source_ext}.o") # /../CMakeFiles/pchtest.dir/pch_dummy.cpp.o

            set(${langid}_depends "${gch_path}")


            if(${CMAKE_VERSION} VERSION_LESS "3.10.0")
                set(${langid}_include "-include ${pch_path}")
                set_source_files_properties(${src_path} PROPERTIES
                    COMPILE_FLAGS "-x ${lang_flag}"
                    OBJECT_DEPENDS ${dummy_obj_path}
                )
            else()
                set(${langid}_include "-include;${pch_path}")
                set_source_files_properties(${src_path} PROPERTIES
                    COMPILE_OPTIONS "-x;${lang_flag}"
                    OBJECT_DEPENDS ${dummy_obj_path}
                )
            endif()

            add_custom_command(OUTPUT "${gch_path}"
                COMMAND ${CMAKE_COMMAND} -E rename "${obj_path}" "${gch_path}"
                COMMAND ${CMAKE_COMMAND} -E copy "${dummy_obj_path}" "${obj_path}"
                COMMAND ${CMAKE_COMMAND} -E touch "${gch_path}"
                DEPENDS ${obj_path}
                COMMENT "Copy PCH"
            )
        endif()
    endforeach()

    foreach(s ${sources})
        get_source_file_property(langid ${s} LANGUAGE)
        get_source_file_property(pch_generated ${s} PCH_GENERATED)

        if(langid AND NOT pch_generated AND ${langid}_depends)

            if(${CMAKE_VERSION} VERSION_LESS "3.10.0")
                set_source_files_properties(${s} PROPERTIES
                    OBJECT_DEPENDS "${${langid}_depends}"
                    COMPILE_FLAGS "${${langid}_include}"
                )
            else()
                set_source_files_properties(${s} PROPERTIES
                    OBJECT_DEPENDS "${${langid}_depends}"
                    COMPILE_OPTIONS "${${langid}_include}"
                )
            endif()
        endif()
endforeach()
endfunction()

project(pchtest CXX)
set(CMAKE_VERBOSE_MAKEFILE ON)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
pch_wrap(PCH_SOURCES pch.h)

find_package(Qt5Widgets REQUIRED)
set(CMAKE_AUTOMOC ON)

add_executable(${PROJECT_NAME} "main.cpp" ${PCH_SOURCES})
add_compile_options(${PROJECT_NAME} PUBLIC -Wall -Werror)
target_link_libraries(${PROJECT_NAME} Qt5::Widgets)

pch_link_target(${PROJECT_NAME})

