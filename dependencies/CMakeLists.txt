cmake_minimum_required(VERSION 3.21)

project(yggdrasil_dependencies)

include(GNUInstallDirs)

##############################################################
# Common Settings
##############################################################

# Option to set the build type (default to Release)
set(DEFAULT_BUILD_TYPE "Release")
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE ${DEFAULT_BUILD_TYPE} CACHE STRING "Choose the type of build, options are: Debug Release" FORCE)
endif()

# Pass the build type to subdirectories
set(BUILD_TYPE ${CMAKE_BUILD_TYPE})

option(YGGDRASIL_BUILD_SHARED_DEPENDENCIES "Build bundled dependencies as shared libraries." ON)
set(TYR_BUILD_SHARED_DEPENDENCIES ${YGGDRASIL_BUILD_SHARED_DEPENDENCIES})
set(LOKI_BUILD_SHARED_DEPENDENCIES ${YGGDRASIL_BUILD_SHARED_DEPENDENCIES})
message(STATUS "Build shared dependencies: ${YGGDRASIL_BUILD_SHARED_DEPENDENCIES}")

if(APPLE)
    set(TYR_DEPENDENCY_INSTALL_RPATH "@loader_path")
else()
    set(TYR_DEPENDENCY_INSTALL_RPATH "$ORIGIN")
endif()
set(LOKI_DEPENDENCY_INSTALL_RPATH ${TYR_DEPENDENCY_INSTALL_RPATH})

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -flto=auto")
endif ()


##############################################################
# Add subprojects
##############################################################

add_subdirectory(benchmark)
add_subdirectory(cista)
add_subdirectory(googletest)
add_subdirectory(loki)
add_subdirectory(nanobind)
add_subdirectory(oneTBB)
add_subdirectory(valla)
