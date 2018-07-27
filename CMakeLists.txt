cmake_minimum_required (VERSION 3.1)
project (my_project)

if(NOT EXISTS "${CMAKE_BINARY_DIR}/inac.cmake")
	message(STATUS "Downloading inac.cmake from https://github.com/inaos/inac-cmake")
	file(DOWNLOAD "https://raw.githubusercontent.com/inaos/inac-cmake/0.1.0/inac.cmake"
			"${CMAKE_BINARY_DIR}/inac.cmake" STATUS DS)
	if(NOT "${DS}"  MATCHES "0;")
		file(REMOVE "${CMAKE_BINARY_DIR}/inac.cmake")
		message(FATAL_ERROR "Failed to download inac.cmake")
	endif()
endif()
include("${CMAKE_BINARY_DIR}/inac.cmake")

inac_enable_verbose()
inac_enable_aes()
inac_enable_sse4()
inac_enable_trace(Debug 1)
inac_enable_log(Debug 4)
inac_enable_log(RelWithDebInfo 3)

inac_platform_libs_for_win("Ws2_32.lib;Psapi.lib;Iphlpapi.lib;winmm.lib;DbgHelp.lib")
inac_platform_libs_for_linux("-lrt -ldl -lm")
inac_platform_libs_for_osx("-ldl -lm")

#add here your library/binary


inac_add_tests()
inac_add_benchmarks()
inac_add_tools()
