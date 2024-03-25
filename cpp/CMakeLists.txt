cmake_minimum_required(VERSION 3.21)

project(jbuff)


set (PROJECT_SOURCES
${CMAKE_SOURCE_DIR}/src/jbuff.cpp
)

set (PROJECT_INCLUDE_DIRS
${CMAKE_SOURCE_DIR}/include
/opt/homebrew/include
)
message(${PROJECT_SOURCES})
if(APPLE)
    enable_language(OBJC)
    enable_language(OBJCXX)
endif()

add_library(jbuff_shared SHARED
${PROJECT_SOURCES}
)

set_target_properties(jbuff_shared
PROPERTIES
OUTPUT_NAME "jbuff"
)

ADD_LIBRARY( jbuff_static STATIC
${PROJECT_SOURCES}
)

set_target_properties(jbuff_static
PROPERTIES
OUTPUT_NAME "jbuff"
)

if(WIN32)
    set(CMAKE_MSVC_RUNTIME_LIBRARY  "MultiThreadedDLL")
    set_target_properties(${jbuff_shared} PROPERTIES MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")
    set_target_properties(${jbuff_static} PROPERTIES MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")
endif()

set_property(TARGET jbuff_shared PROPERTY CXX_STANDARD 17)
set_property(TARGET jbuff_static PROPERTY CXX_STANDARD 17)

target_include_directories(jbuff_static
PRIVATE
${PROJECT_INCLUDE_DIRS}
)

target_include_directories(jbuff_shared
PRIVATE
${PROJECT_INCLUDE_DIRS}
)