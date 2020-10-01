cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(fletcher_opae VERSION 0.0.0 LANGUAGES C)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "")
endif()

include(FetchContent)

FetchContent_Declare(cmake-modules
  GIT_REPOSITORY  https://github.com/abs-tudelft/cmake-modules.git
  GIT_TAG         master
)
FetchContent_MakeAvailable(cmake-modules)

FetchContent_Declare(fletcher
  GIT_REPOSITORY  https://github.com/abs-tudelft/fletcher.git
  GIT_TAG         0.0.12
)
if(NOT fletcher_POPULATED)
  FetchContent_Populate(fletcher)
  add_subdirectory(${fletcher_SOURCE_DIR}/common/c ${fletcher_BINARY_DIR} EXCLUDE_FROM_ALL)
endif()

FetchContent_Declare(opae-c
  GIT_REPOSITORY  https://github.com/opae/opae-libs.git
  GIT_TAG         release/2.0.0
)
if(NOT opae-c_POPULATED)
  FetchContent_Populate(opae-c)
  set(OPAE_BUILD_LIBOPAE_CXX OFF CACHE BOOL "")
  set(OPAE_BUILD_LIBOPAE_PY OFF CACHE BOOL "")
  add_subdirectory(${opae-c_SOURCE_DIR} ${opae-c_BINARY_DIR} EXCLUDE_FROM_ALL)
endif()

include(CompileUnits)

add_compile_unit(
  NAME fletcher::opae
  TYPE SHARED
  PRPS
    C_STANDARD 99
  SRCS
    src/fletcher_opae.c
  DEPS
    fletcher::c
    opae-c
)

add_compile_unit(
  NAME fletcher::opae-ase
  TYPE SHARED
  PRPS
    C_STANDARD 99
    COMPILE_DEFINITIONS ASE
  SRCS
    src/fletcher_opae.c
  DEPS
    fletcher::c
    opae-c-ase
)

compile_units()
