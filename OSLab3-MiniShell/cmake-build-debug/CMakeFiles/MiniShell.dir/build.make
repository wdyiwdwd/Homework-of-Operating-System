# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.8

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /home/gongyansong/下载/intelliJIDEA/clion-2017.2.3/bin/cmake/bin/cmake

# The command to remove a file.
RM = /home/gongyansong/下载/intelliJIDEA/clion-2017.2.3/bin/cmake/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/gongyansong/CLionProjects/MiniShell

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/gongyansong/CLionProjects/MiniShell/cmake-build-debug

# Include any dependencies generated for this target.
include CMakeFiles/MiniShell.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/MiniShell.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/MiniShell.dir/flags.make

CMakeFiles/MiniShell.dir/main.c.o: CMakeFiles/MiniShell.dir/flags.make
CMakeFiles/MiniShell.dir/main.c.o: ../main.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/gongyansong/CLionProjects/MiniShell/cmake-build-debug/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object CMakeFiles/MiniShell.dir/main.c.o"
	/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/MiniShell.dir/main.c.o   -c /home/gongyansong/CLionProjects/MiniShell/main.c

CMakeFiles/MiniShell.dir/main.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/MiniShell.dir/main.c.i"
	/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/gongyansong/CLionProjects/MiniShell/main.c > CMakeFiles/MiniShell.dir/main.c.i

CMakeFiles/MiniShell.dir/main.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/MiniShell.dir/main.c.s"
	/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/gongyansong/CLionProjects/MiniShell/main.c -o CMakeFiles/MiniShell.dir/main.c.s

CMakeFiles/MiniShell.dir/main.c.o.requires:

.PHONY : CMakeFiles/MiniShell.dir/main.c.o.requires

CMakeFiles/MiniShell.dir/main.c.o.provides: CMakeFiles/MiniShell.dir/main.c.o.requires
	$(MAKE) -f CMakeFiles/MiniShell.dir/build.make CMakeFiles/MiniShell.dir/main.c.o.provides.build
.PHONY : CMakeFiles/MiniShell.dir/main.c.o.provides

CMakeFiles/MiniShell.dir/main.c.o.provides.build: CMakeFiles/MiniShell.dir/main.c.o


# Object files for target MiniShell
MiniShell_OBJECTS = \
"CMakeFiles/MiniShell.dir/main.c.o"

# External object files for target MiniShell
MiniShell_EXTERNAL_OBJECTS =

MiniShell: CMakeFiles/MiniShell.dir/main.c.o
MiniShell: CMakeFiles/MiniShell.dir/build.make
MiniShell: CMakeFiles/MiniShell.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/gongyansong/CLionProjects/MiniShell/cmake-build-debug/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking C executable MiniShell"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/MiniShell.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/MiniShell.dir/build: MiniShell

.PHONY : CMakeFiles/MiniShell.dir/build

CMakeFiles/MiniShell.dir/requires: CMakeFiles/MiniShell.dir/main.c.o.requires

.PHONY : CMakeFiles/MiniShell.dir/requires

CMakeFiles/MiniShell.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/MiniShell.dir/cmake_clean.cmake
.PHONY : CMakeFiles/MiniShell.dir/clean

CMakeFiles/MiniShell.dir/depend:
	cd /home/gongyansong/CLionProjects/MiniShell/cmake-build-debug && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/gongyansong/CLionProjects/MiniShell /home/gongyansong/CLionProjects/MiniShell /home/gongyansong/CLionProjects/MiniShell/cmake-build-debug /home/gongyansong/CLionProjects/MiniShell/cmake-build-debug /home/gongyansong/CLionProjects/MiniShell/cmake-build-debug/CMakeFiles/MiniShell.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/MiniShell.dir/depend

