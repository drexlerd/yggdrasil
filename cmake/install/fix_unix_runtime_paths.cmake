file(GLOB native_lib_dirs LIST_DIRECTORIES true
    "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/pyyggdrasil/lib*")
if(NOT native_lib_dirs)
    return()
endif()

find_program(PATCHELF_EXECUTABLE patchelf)
if(NOT PATCHELF_EXECUTABLE)
    message(WARNING "patchelf not found; pyyggdrasil native libraries keep their original runtime paths")
    return()
endif()

foreach(native_lib_dir IN LISTS native_lib_dirs)
    file(GLOB_RECURSE native_dir_libraries LIST_DIRECTORIES false
        "${native_lib_dir}/*.so"
        "${native_lib_dir}/*.so.*")
    list(APPEND native_libraries ${native_dir_libraries})
endforeach()

foreach(native_library IN LISTS native_libraries)
    execute_process(
        COMMAND "${PATCHELF_EXECUTABLE}" --set-rpath "$ORIGIN" "${native_library}"
        RESULT_VARIABLE rpath_result
        ERROR_VARIABLE rpath_error)
    if(NOT rpath_result EQUAL 0)
        message(WARNING "Could not set $ORIGIN rpath on ${native_library}: ${rpath_error}")
    endif()
endforeach()
