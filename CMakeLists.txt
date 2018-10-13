cmake_minimum_required (VERSION 3.1)
project(my_project VERSION 1.0.0)

if(NOT EXISTS "${CMAKE_BINARY_DIR}/inac.cmake")
	if (NOT EXISTS "${CMAKE_SOURCE_DIR}/inac.cmake")
		message(STATUS "Downloading inac.cmake from https://github.com/inaos/inac-cmake")
		file(DOWNLOAD "https://raw.githubusercontent.com/inaos/inac-cmake/0.1.0/inac.cmake"
			"${CMAKE_BINARY_DIR}/inac.cmake" STATUS DS)
		if(NOT "${DS}"  MATCHES "0;")
			file(REMOVE "${CMAKE_BINARY_DIR}/inac.cmake")
			message(FATAL_ERROR "Failed to download inac.cmake")
		endif()
	else()
		message(STATUS "Use local inac.cmake")
		configure_file("${CMAKE_SOURCE_DIR}/inac.cmake" "${CMAKE_BINARY_DIR}/inac.cmake" COPYONLY)
	endif()
endif()
include("${CMAKE_BINARY_DIR}/inac.cmake")

#add here your library/binary

# uncomment to build tests
#inac_add_tests()
# unccomment to build benchmarks
#inac_add_benchmarks()
# uncomment to build tools
#inac_add_tools()
# uncomment to build examples
#inac_add_examples()
