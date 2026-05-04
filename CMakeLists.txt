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

install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/python/src/yggdrasil/__init__.py"
        DESTINATION "yggdrasil"
        COMPONENT yggdrasil)

foreach(native_dir IN ITEMS include lib lib64 bin nanobind)
    if(EXISTS "${YGGDRASIL_NATIVE_PREFIX}/${native_dir}")
        install(DIRECTORY "${YGGDRASIL_NATIVE_PREFIX}/${native_dir}"
                DESTINATION "yggdrasil"
                COMPONENT yggdrasil)
    endif()
endforeach()

add_custom_target(yggdrasil_wheel)
