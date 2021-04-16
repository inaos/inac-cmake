set(CURRENT_LIST_DIR ${CMAKE_CURRENT_LIST_DIR})
if (NOT DEFINED pre_configure_dir)
    set(pre_configure_dir ${CMAKE_CURRENT_LIST_DIR})
endif ()

if (NOT DEFINED post_configure_dir)
    set(post_configure_dir ${CMAKE_BINARY_DIR}/generated)
endif ()

set(pre_configure_file ${pre_configure_dir}/git_version.c.in)
set(post_configure_file ${post_configure_dir}/git_version.c)

if (NOT EXISTS "${pre_configure_dir}/git_version.h")
    file(WRITE "${pre_configure_dir}/git_version.h"
            "#ifndef GIT_VERSION_H\n#define GIT_VERSION_H\n\nextern const char *git_hash;\n\n#endif // GIT_VERSION_H")
endif ()

if (NOT EXISTS "${pre_configure_file}")
    file(WRITE "${pre_configure_file}"
            "#include \"git_version.h\"\nconst char *git_hash = \"@INAC_GIT_HASH@\";"
            )
endif ()


function(inac_git_hash_write git_hash)
    file(WRITE ${CMAKE_BINARY_DIR}/git-state.txt ${git_hash})
endfunction()

function(inac_git_hash_read git_hash)
    if (EXISTS ${CMAKE_BINARY_DIR}/git-state.txt)
        file(STRINGS ${CMAKE_BINARY_DIR}/git-state.txt CONTENT)
        LIST(GET CONTENT 0 var)

        set(${git_hash} ${var} PARENT_SCOPE)
    endif ()
endfunction()

function(inac_git_hash_check)
    # Get the latest abbreviated commit hash of the working branch
    execute_process(
            COMMAND git log -1 --format=%h
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
            OUTPUT_VARIABLE GIT_HASH
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
    )

    inac_git_hash_read(GIT_HASH_CACHE)
    if (NOT EXISTS ${post_configure_dir})
        file(MAKE_DIRECTORY ${post_configure_dir})
    endif ()

    if (NOT EXISTS ${post_configure_dir}/git_version.h)
        file(COPY ${pre_configure_dir}/git_version.h DESTINATION ${post_configure_dir})
    endif()

    if (NOT DEFINED INAC_GIT_HASH OR "${INAC_GIT_HASH}" STREQUAL "")
        set(INAC_GIT_HASH "NA")
    endif ()

    if (NOT DEFINED INAC_GIT_HASH_CACHE)
        set(INAC_GIT_HASH_CACHE "INVALID")
    endif ()

    message(STATUS "Git hash: ${INAC_GIT_HASH}")

    # Only update the git_version.c if the hash has changed. This will
    # prevent us from rebuilding the project more than we need to.
    if (NOT ${INAC_GIT_HASH} STREQUAL ${INAC_GIT_HASH_CACHE} OR NOT EXISTS ${post_configure_file})
        # Set che GIT_HASH_CACHE variable the next build won't have
        # to regenerate the source file.
        inac_git_hash_write(${INAC_GIT_HASH})

        configure_file(${pre_configure_file} ${post_configure_file} @ONLY)
    endif ()

endfunction()

function(inac_git_hash)

    add_custom_target(AlwaysCheckGitHash COMMAND ${CMAKE_COMMAND}
            -DRUN_GIT_HASH_CHECK=1
            -Dpre_configure_dir=${pre_configure_dir}
            -Dpost_configure_file=${post_configure_dir}
            -DINAC_GIT_HASH_CACHE=${INAC_GIT_HASH_CACHE}
            -P ${CURRENT_LIST_DIR}/GitHash.cmake
            BYPRODUCTS ${post_configure_file}
            )

    add_library(git_version ${CMAKE_BINARY_DIR}/generated/git_version.c)
    target_include_directories(git_version PUBLIC ${CMAKE_BINARY_DIR}/generated)
    add_dependencies(git_version AlwaysCheckGitHash)

    inac_git_hash_check()
endfunction()

# This is used to run this function from an external cmake process.
if (RUN_GIT_HASH_CHECK)
    inac_git_hash_check()
endif ()
