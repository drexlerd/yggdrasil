cmake_minimum_required(VERSION 3.21)
project(InstallNauty)

include(ExternalProject)

set(YGGDRASIL_NAUTY_GIT_TAG cb44c50bd4fa543b977df6a4b70ec88e67020646 CACHE STRING "Git tag used to build nauty.")

message(STATUS "Dependency \"nauty\"...")

find_package(Nauty QUIET PATHS ${CMAKE_INSTALL_PREFIX} NO_DEFAULT_PATH)

if(NOT Nauty_FOUND)
    message(STATUS "Preparing external project \"nauty\".")

    # We need to build nauty for cmake support
    ExternalProject_Add(
        nauty
        GIT_REPOSITORY https://github.com/drexlerd/nauty.git
        GIT_TAG ${YGGDRASIL_NAUTY_GIT_TAG}
        PREFIX ${CMAKE_BINARY_DIR}/nauty
        STAMP_DIR ${CMAKE_BINARY_DIR}/nauty/stamp/${YGGDRASIL_NAUTY_GIT_TAG}
        UPDATE_COMMAND ""
        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./configure --prefix=<INSTALL_DIR> CFLAGS=-fPIC --enable-tls --disable-shared
        BUILD_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> make
        INSTALL_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> make install
        INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    )

    ExternalProject_Add_Step(
        nauty install-cmake-package
        COMMAND ${CMAKE_COMMAND}
                -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
                -DCMAKE_INSTALL_LIBDIR=${CMAKE_INSTALL_LIBDIR}
                -S ${CMAKE_CURRENT_LIST_DIR}/package
                -B ${CMAKE_BINARY_DIR}/nauty-package
        COMMAND ${CMAKE_COMMAND}
                --install ${CMAKE_BINARY_DIR}/nauty-package
        DEPENDEES install
    )
else()
    message(STATUS "nauty is already installed.")
endif()
