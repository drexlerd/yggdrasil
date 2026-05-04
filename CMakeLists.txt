cmake_minimum_required(VERSION 3.21)

file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/pyproject.toml" YGGDRASIL_PROJECT_VERSION_LINE REGEX "^version[ \t]*=" LIMIT_COUNT 1)
if(NOT YGGDRASIL_PROJECT_VERSION_LINE)
    message(FATAL_ERROR "Could not read project version from pyproject.toml")
endif()
string(REGEX REPLACE "^version[ \t]*=[ \t]*\"([^\"]+)\".*$" "\\1" YGGDRASIL_PROJECT_VERSION "${YGGDRASIL_PROJECT_VERSION_LINE}")

project(yggdrasil VERSION "${YGGDRASIL_PROJECT_VERSION}")

include(GNUInstallDirs)

set(YGGDRASIL_NATIVE_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/dependencies-install" CACHE PATH "Native dependency prefix to package.")

if(NOT EXISTS "${YGGDRASIL_NATIVE_PREFIX}")
    message(FATAL_ERROR "Native prefix does not exist: ${YGGDRASIL_NATIVE_PREFIX}")
endif()

install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/python/src/pyyggdrasil/__init__.py"
        DESTINATION "pyyggdrasil"
        COMPONENT pyyggdrasil)

foreach(native_dir IN ITEMS include lib lib64 bin nanobind)
    if(EXISTS "${YGGDRASIL_NATIVE_PREFIX}/${native_dir}")
        install(DIRECTORY "${YGGDRASIL_NATIVE_PREFIX}/${native_dir}"
                DESTINATION "pyyggdrasil"
                COMPONENT pyyggdrasil)
    endif()
endforeach()

if(APPLE)
    install(CODE [[
        set(native_lib_dir "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/pyyggdrasil/lib")
        if(EXISTS "${native_lib_dir}")
            find_program(INSTALL_NAME_TOOL_EXECUTABLE install_name_tool)
            if(INSTALL_NAME_TOOL_EXECUTABLE)
                file(GLOB_RECURSE native_libraries LIST_DIRECTORIES false
                    "${native_lib_dir}/*.dylib"
                    "${native_lib_dir}/*.dylib.*")
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
            else()
                message(WARNING "install_name_tool not found; pyyggdrasil native libraries keep their original runtime paths")
            endif()
        endif()
    ]] COMPONENT pyyggdrasil)
elseif(UNIX)
    install(CODE [[
        set(native_lib_dir "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/pyyggdrasil/lib")
        if(EXISTS "${native_lib_dir}")
            find_program(PATCHELF_EXECUTABLE patchelf)
            if(PATCHELF_EXECUTABLE)
                file(GLOB_RECURSE native_libraries LIST_DIRECTORIES false
                    "${native_lib_dir}/*.so"
                    "${native_lib_dir}/*.so.*")
                foreach(native_library IN LISTS native_libraries)
                    execute_process(
                        COMMAND "${PATCHELF_EXECUTABLE}" --set-rpath "$ORIGIN" "${native_library}"
                        RESULT_VARIABLE rpath_result
                        ERROR_VARIABLE rpath_error)
                    if(NOT rpath_result EQUAL 0)
                        message(WARNING "Could not set $ORIGIN rpath on ${native_library}: ${rpath_error}")
                    endif()
                endforeach()
            else()
                message(WARNING "patchelf not found; pyyggdrasil native libraries keep their original runtime paths")
            endif()
        endif()
    ]] COMPONENT pyyggdrasil)
endif()

add_custom_target(pyyggdrasil_wheel)
