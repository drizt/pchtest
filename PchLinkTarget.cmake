function(pch_link_target target pch_header)
    # Force to check correct pch header
    target_compile_options(${target} PUBLIC "-Winvalid-pch")

    # Write actual compile command to json file
    set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE PARENT_SCOPE)

    # Get lang
    if (ARGN)
        list(GET ARGN 0 pchlangid)
    else()
        get_property(enabled_langs GLOBAL PROPERTY ENABLED_LANGUAGES)
        list(FIND enabled_langs CXX index)
        if(index STREQUAL -1)
            list(GET enabled_langs 0 pchlangid)
        else()
            set(pchlangid CXX)
        endif()
    endif()

    set(compile_source "")
    set(gch_path ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${target}_pch.dir/${pch_header}.gch)
    get_target_property(sources ${target} SOURCES)
    foreach(s ${sources})
        get_source_file_property(langid ${s} LANGUAGE)
        if (langid AND (pchlangid STREQUAL langid))
            set(compile_source ${s})
            if(${CMAKE_VERSION} VERSION_LESS "3.10.0")
                set_source_files_properties(${s} PROPERTIES COMPILE_FLAGS "-include ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${target}_pch.dir/${pch_header}")
            else()
                set_source_files_properties(${s} PROPERTIES COMPILE_OPTIONS "-include;${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${target}_pch.dir/${pch_header}")
            endif()
        endif()
    endforeach()

    add_custom_target(${target}_pch
        ${CMAKE_COMMAND} -DSOURCE_FILE=${compile_source}
                         -DTARGET=${target}
                         -DSOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}
                         -DBINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}
                         -DPCH=${pch_header}
                         -P ${CMAKE_CURRENT_LIST_DIR}/CompilePch.cmake
    )
    add_dependencies(${target} ${target}_pch)
endfunction()
