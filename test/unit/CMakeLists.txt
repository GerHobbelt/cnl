enable_testing()

# source files containing tests of the correctness of CNL;
# ideally compiles with every warning that CNL user might choose
set(test_sources
        scaled_int/elastic/to_chars_static.cpp
)

# source files containing demos and examples of CNL;
# do not necessarily need to fail the strictest warnings
set(sample_sources
        # showing off
        index.cpp
        papers/p0037.cpp
        papers/p0381.cpp
        papers/p0675.cpp
        papers/p0828.cpp
        papers/p0554.cpp
        papers/p1050.cpp
        presentations/cppcon2017.cpp
        presentations/cppdub2018.cpp
        presentations/cppnow2017.cpp
        zero_cost_square.cpp
        zero_cost_free_functions.cpp
        snippets.cpp
        zero_cost_average.cpp
)

######################################################################
# pull in external dependencies

find_package(Boost 1.71.0)

######################################################################
# add_gtest_dependency

function(add_gtest_dependency target)
    target_link_libraries("${target}" ${CNL_GTEST_MAIN_TARGET})
endfunction(add_gtest_dependency)

######################################################################
# add test-unit target

add_custom_target(test-unit)
add_dependencies(test-all test-unit)

######################################################################
# test plain - the all.cpp project with *no* tests of compiler flags

add_executable(test-unit-plain all.cpp)
target_link_libraries(test-unit-plain Cnl)
add_test(test-unit-plain "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/test-unit-plain")
add_gtest_dependency(test-unit-plain)
add_dependencies(test-unit test-unit-plain)

######################################################################
# make_test

# given the path to a source file containing gtest tests,
# creates and returns a target that runs them
function(make_test source compile_flags)

    # turn source file path into target name (e.g. "foo/bar.cpp" -> "test-unit-foo-bar")
    string(REPLACE ".cpp" "" stripped "${source}")
    string(REPLACE "/" "-" target "test-unit-${stripped}")

    # create a target and make it a test
    add_executable("${target}" "${source}")
    target_include_directories("${target}" PRIVATE "${CMAKE_CURRENT_LIST_DIR}")
    set_target_properties("${target}" PROPERTIES COMPILE_FLAGS "${compile_flags}")
    target_link_libraries("${target}" Cnl)
    add_test("${target}" "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${target}")

    # Google Test dependency
    add_gtest_dependency("${target}")

    # Boost dependency
    if(Boost_FOUND)
        target_compile_definitions("${target}" PRIVATE "-DCNL_BOOST_ENABLED")
        target_include_directories("${target}" SYSTEM PRIVATE "${Boost_INCLUDE_DIRS}")
    endif(Boost_FOUND)

    # Add to test-unit custom target.
    add_dependencies(test-unit "${target}")
endfunction(make_test)

######################################################################
# create tests to verify CNL

foreach(source ${test_sources})
    make_test("${source}" "${TEST_CXX_FLAGS} ${SANITIZE_CXX_FLAGS}")
endforeach(source)

if (CNL_SANITIZE)
    make_test(ub.cpp "${TEST_CXX_FLAGS} ${SANITIZE_CXX_FLAGS}")
endif(CNL_SANITIZE)
