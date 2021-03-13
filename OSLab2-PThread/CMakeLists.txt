cmake_minimum_required(VERSION 3.8)
project(Pthread)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -pthread")

set(SOURCE_FILES main.c)
add_executable(Pthread ${SOURCE_FILES})

find_package(Threads REQUIRED)
target_link_libraries(Pthread Threads::Threads)