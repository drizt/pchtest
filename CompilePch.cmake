# Must be set:
# SOURCE_DIR
# BINARY_DIR
# TARGET
# PCH
# SOURCE_FILE

include(${CMAKE_CURRENT_LIST_DIR}/JSONParser.cmake)

if(NOT SOURCE_DIR)
  message(FATAL_ERROR "SOURCE_DIR is not set")
endif()

if(NOT SOURCE_FILE)
  message(FATAL_ERROR "SOURCE_FILE is not set")
endif()

file(READ ${BINARY_DIR}/compile_commands.json TEXT)

sbeParseJson(COMMANDS TEXT)

set(I 0)
while(COMMANDS_${I}.command)

  message(STATUS "${COMMANDS_${I}.file}")
  
  if(COMMANDS_${I}.file STREQUAL ${SOURCE_DIR}/${SOURCE_FILE})
    separate_arguments(ARGS NATIVE_COMMAND ${COMMANDS_${I}.command})
    list(FIND ARGS "-o" POS)
    if(POS STREQUAL -1)
      message(FATAL_ERROR "Wrong args:\n${ARGS}")
    endif()

    list(REMOVE_AT ARGS ${POS})
    list(REMOVE_AT ARGS ${POS})

    list(FIND ARGS "-c" POS)
    if(POS STREQUAL -1)
      message(FATAL_ERROR "Wrong args:\n${ARGS}")
    endif()
    list(REMOVE_AT ARGS ${POS})
    list(REMOVE_AT ARGS ${POS})

    get_filename_component(BASE ${PCH} NAME)
    
    string(REPLACE "-include;${BINARY_DIR}/CMakeFiles/${TARGET}_pch.dir/${BASE}" "" ARGS "${ARGS}")

    message(STATUS "${ARGS}")

    list(APPEND ARGS -x c++-header -c ${SOURCE_DIR}/${PCH} -o CMakeFiles/${TARGET}_pch.dir/${BASE}.gch)
    file(MAKE_DIRECTORY CMakeFiles/${TARGET}_pch.dir)
    execute_process(COMMAND ${ARGS} WORKING_DIRECTORY ${BINARY_DIR})
    set(WORKING_DIR ${COMMANDS_${I}.directory})
  endif()

  math(EXPR I "${I} + 1")
endwhile()


