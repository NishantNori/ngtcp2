# Copyright (C) Viktor Szakats
# SPDX-License-Identifier: BSD-3-Clause

# C++

include(CheckCCompilerFlag)

if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")

  # https://clang.llvm.org/docs/DiagnosticsReference.html
  # https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html

  # WPICKY_ENABLE = Options we want to enable as-is.
  # WPICKY_DETECT = Options we want to test first and enable if available.

  set(WPICKY_ENABLE "-Wall")

  # ----------------------------------
  # Add new options here, if in doubt:
  # ----------------------------------
  set(WPICKY_DETECT
  )

  # Assume these options always exist with both clang and gcc.
  # Require clang 3.0 / gcc 2.95 or later.
  list(APPEND WPICKY_ENABLE
  )

  # Always enable with clang, version dependent with gcc
  set(WPICKY_COMMON_OLD
    -Wformat-security                    # clang  3.0  gcc  4.1
  )

  set(WPICKY_COMMON
  )

  if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    list(APPEND WPICKY_ENABLE
      ${WPICKY_COMMON_OLD}
    )
    # Enable based on compiler version
    if((CMAKE_CXX_COMPILER_ID STREQUAL "Clang"      AND NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 3.6) OR
       (CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang" AND NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 6.3))
      list(APPEND WPICKY_ENABLE
        ${WPICKY_COMMON}
        -Wsometimes-uninitialized        # clang  3.2            appleclang  4.6
      )
    endif()
    if((CMAKE_CXX_COMPILER_ID STREQUAL "Clang"      AND NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 3.9) OR
       (CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang" AND NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 8.3))
      list(APPEND WPICKY_ENABLE
      )
    endif()
    if((CMAKE_CXX_COMPILER_ID STREQUAL "Clang"      AND NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 5.0) OR
       (CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang" AND NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 9.4))
      list(APPEND WPICKY_ENABLE
        # Disable noexcept-type warning of g++-7.  This is not harmful as
        # long as all source files are compiled with the same compiler.
        -Wno-noexcept-type               # clang  5.0  gcc  7.0  appleclang  9.4
      )
    endif()
    if((CMAKE_CXX_COMPILER_ID STREQUAL "Clang"      AND NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 7.0) OR
       (CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang" AND NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 10.3))
      list(APPEND WPICKY_ENABLE
      )
    endif()
  else()  # gcc
    list(APPEND WPICKY_DETECT
      ${WPICKY_COMMON}
    )
    # Enable based on compiler version
    if(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.3)
      list(APPEND WPICKY_ENABLE
        ${WPICKY_COMMON_OLD}
      )
    endif()
    if(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 7.0)
      list(APPEND WPICKY_ENABLE
        # Disable noexcept-type warning of g++-7.  This is not harmful as
        # long as all source files are compiled with the same compiler.
        -Wno-noexcept-type               # clang  5.0  gcc  7.0  appleclang  9.4
      )
    endif()
  endif()

  #

  unset(_wpicky)

  foreach(_CCOPT IN LISTS WPICKY_ENABLE)
    set(_wpicky "${_wpicky} ${_CCOPT}")
  endforeach()

  foreach(_CCOPT IN LISTS WPICKY_DETECT)
    # surprisingly, CHECK_CXX_COMPILER_FLAG needs a new variable to store each new
    # test result in.
    string(MAKE_C_IDENTIFIER "OPT${_CCOPT}" _optvarname)
    # GCC only warns about unknown -Wno- options if there are also other diagnostic messages,
    # so test for the positive form instead
    string(REPLACE "-Wno-" "-W" _CCOPT_ON "${_CCOPT}")
    check_cxx_compiler_flag(${_CCOPT_ON} ${_optvarname})
    if(${_optvarname})
      set(_wpicky "${_wpicky} ${_CCOPT}")
    endif()
  endforeach()

  set(WARNCXXFLAGS "${WARNCXXFLAGS} ${_wpicky}")
endif()
