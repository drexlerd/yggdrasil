cmake_minimum_required(VERSION 3.21)

project(NautyPackage VERSION 2.8.9 LANGUAGES C)

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/NautyConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/NautyConfig.cmake"
    INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/Nauty")

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/NautyConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion)

install(
    FILES
        "${CMAKE_CURRENT_BINARY_DIR}/NautyConfig.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/NautyConfigVersion.cmake"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/Nauty")
