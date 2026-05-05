file(GLOB native_lib_dirs LIST_DIRECTORIES true
    "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/pyyggdrasil/lib*")
if(NOT native_lib_dirs)
    return()
endif()

find_program(INSTALL_NAME_TOOL_EXECUTABLE install_name_tool)
if(NOT INSTALL_NAME_TOOL_EXECUTABLE)
    message(WARNING "install_name_tool not found; pyyggdrasil native libraries keep their original runtime paths")
    return()
endif()

foreach(native_lib_dir IN LISTS native_lib_dirs)
    file(GLOB_RECURSE native_dir_libraries LIST_DIRECTORIES false
        "${native_lib_dir}/*.dylib"
        "${native_lib_dir}/*.dylib.*")
    list(APPEND native_libraries ${native_dir_libraries})
endforeach()

foreach(native_library IN LISTS native_libraries)
    get_filename_component(native_library_name "${native_library}" NAME)

    execute_process(
        COMMAND "${INSTALL_NAME_TOOL_EXECUTABLE}" -id "@rpath/${native_library_name}" "${native_library}"
        RESULT_VARIABLE install_name_result
        ERROR_VARIABLE install_name_error)
    if(NOT install_name_result EQUAL 0)
        message(WARNING "Could not update install name of ${native_library}: ${install_name_error}")
    endif()

    execute_process(
        COMMAND "${INSTALL_NAME_TOOL_EXECUTABLE}" -delete_rpath "@loader_path" "${native_library}"
        OUTPUT_QUIET
        ERROR_QUIET)
    execute_process(
        COMMAND "${INSTALL_NAME_TOOL_EXECUTABLE}" -add_rpath "@loader_path" "${native_library}"
        RESULT_VARIABLE rpath_result
        ERROR_VARIABLE rpath_error)
    if(NOT rpath_result EQUAL 0)
        message(WARNING "Could not add @loader_path rpath to ${native_library}: ${rpath_error}")
    endif()
endforeach()
