cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(fletcher_opae
  VERSION 0.2.1
  DESCRIPTION "Fletcher platform support for Open Programmable Acceleration Engine"
  HOMEPAGE_URL "https://github.com/teratide/fletcher-opae"
  LANGUAGES C
)

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
  GIT_TAG         0.0.19
)
if(NOT fletcher_POPULATED)
  FetchContent_Populate(fletcher)
  add_subdirectory(${fletcher_SOURCE_DIR}/common/c ${fletcher_BINARY_DIR} EXCLUDE_FROM_ALL)
endif()

FetchContent_Declare(opae-c
  GIT_REPOSITORY  https://github.com/opae/opae-libs.git
  GIT_TAG         release/2.0.1-2
)
if(NOT opae-c_POPULATED)
  FetchContent_Populate(opae-c)
  set(OPAE_BUILD_LIBOPAE_CXX OFF CACHE BOOL "")
  set(OPAE_BUILD_LIBOPAE_PY OFF CACHE BOOL "")
  set(OPAE_BUILD_SIM ON CACHE BOOL "")
  add_subdirectory(${opae-c_SOURCE_DIR} ${opae-c_BINARY_DIR} EXCLUDE_FROM_ALL)
endif()

include(CompileUnits)

add_compile_unit(
  NAME fletcher::opae
  TYPE SHARED
  COMPONENT library
  PRPS
    C_STANDARD 99
  SRCS
    src/fletcher_opae.c
  DEPS
    fletcher::c
    opae-c
)

add_compile_unit(
  OPT
  NAME fletcher::opae-ase
  TYPE SHARED
  COMPONENT ase
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

execute_process (
    COMMAND bash -c "awk -F= '/^ID=/{print $2}' /etc/os-release |tr -d '\n' | tr -d '\"'"
    OUTPUT_VARIABLE OS_NAME
)

execute_process (
    COMMAND bash -c "awk -F= '/^VERSION_ID=/{print $2}' /etc/os-release |tr -d '\n' | tr -d '\"'"
    OUTPUT_VARIABLE OS_VERSION
)

if(OS_NAME MATCHES "ubuntu")
  set(CPACK_DEBIAN_PACKAGE_RELEASE "ubuntu${OS_VERSION}")
  set(CPACK_GENERATOR "DEB")
elseif(OS_NAME MATCHES "centos")
  set(CPACK_RPM_PACKAGE_RELEASE_DIST "el${OS_VERSION}")
  if(OS_VERSION MATCHES "7")
    set(CPACK_GENERATOR "RPM;TGZ")
  else()
    set(CPACK_GENERATOR "RPM")
  endif()
endif()

if(BUILD_FLETCHER_OPAE-ASE)
  set(CPACK_COMPONENTS_ALL ase)
else()
  set(CPACK_COMPONENTS_ALL library)
  set(CPACK_RPM_MAIN_COMPONENT "library")
endif()

set(CPACK_PACKAGE_VENDOR "Teratide")
set(CPACK_PACKAGE_VERSION_MAJOR "${fletcher_opae_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${fletcher_opae_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${fletcher_opae_VERSION_PATCH}")
set(CPACK_PACKAGE_RELOCATABLE ON)

set(CPACK_DEB_COMPONENT_INSTALL ON)
set(CPACK_DEBIAN_LIBRARY_PACKAGE_NAME "${CMAKE_PROJECT_NAME}")
set(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT")
set(CPACK_DEBIAN_LIBRARY_PACKAGE_DEPENDS "fletcher (>= 0.0.19), opae-libs (>= 2.0.1)")
set(CPACK_DEBIAN_ASE_PACKAGE_DEPENDS "fletcher (>= 0.0.19), opae-ase (>= 2.0.1)")
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "${CPACK_PACKAGE_VENDOR}")

set(CPACK_RPM_COMPONENT_INSTALL ON)
set(CPACK_RPM_FILE_NAME "RPM-DEFAULT")
set(CPACK_RPM_PACKAGE_DESCRIPTION "${CPACK_PACKAGE_DESCRIPTION}")
set(CPACK_RPM_PACKAGE_LICENSE "ASL 2.0")
set(CPACK_RPM_LIBRARY_PACKAGE_REQUIRES "fletcher >= 0.0.19, opae-libs >= 2.0.1")
set(CPACK_RPM_ASE_PACKAGE_REQUIRES "fletcher >= 0.0.19, opae-ase >= 2.0.1")

set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
set(CPACK_ARCHIVE_LIBRARY_FILE_NAME "${CMAKE_PROJECT_NAME}-${fletcher_opae_VERSION}-${CMAKE_SYSTEM_NAME}")
set(CPACK_ARCHIVE_ASE_FILE_NAME "${CMAKE_PROJECT_NAME}-ase-${fletcher_opae_VERSION}-${CMAKE_SYSTEM_NAME}")

include(CPack)
