#!/usr/bin/env bash

init_c() {
    local project_name="${1:-}"
    local target_dir="."

    if [[ -z "$project_name" ]]; then
        local dir_basename
        dir_basename="$(basename "$(pwd)")"
        read -rp "Bootstrap C project in '${dir_basename}'? (y/n) " confirm
        [[ "$confirm" == "y" ]] || return 1
        read -rp "Are you really sure? (y/n) " confirm
        [[ "$confirm" == "y" ]] || return 1
        project_name="$dir_basename"
        target_dir="."
    else
        target_dir="$project_name"
        if [[ -d "$target_dir" ]]; then
            echo "Directory already exists: $target_dir" >&2
            return 1
        fi
        mkdir -p "$target_dir"
    fi

    mkdir -p "$target_dir/src" "$target_dir/build" "$target_dir/tests" "$target_dir/include"

    local header_guard
    if [[ -n "$project_name" ]]; then
        header_guard="${project_name^^}_H"
    else
        header_guard="MYPROJECT_H"
    fi

    if [ ! -f "$target_dir/src/main.c" ]; then
        cat > "$target_dir/src/main.c" <<EOF
#include <stdio.h>

int main(void) {
    printf("Hello from ${project_name:-world}!\\n");
    return 0;
}
EOF
    fi

    if [ ! -f "$target_dir/src/lib.c" ]; then
        cat > "$target_dir/src/lib.c" <<'EOF'
#include "lib.h"

/* Library implementation goes here */
EOF
    fi

    if [ ! -f "$target_dir/include/lib.h" ]; then
        cat > "$target_dir/include/lib.h" <<EOF
#ifndef ${header_guard}
#define ${header_guard}

/* Public API for ${project_name:-myproject} */

#endif /* ${header_guard} */
EOF
    fi

    if [ ! -f "$target_dir/tests/test_main.c" ]; then
        cat > "$target_dir/tests/test_main.c" <<'EOF'
#include <stdio.h>
#include <assert.h>

static void test_example(void)
{
    assert(1 == 1);
}

/*
 * Each test file exposes a function like:
 *   void run_example_tests(void);
 *
 * We manually declare them here so the compiler knows they exist.
 * (In larger projects, you'd move this into a header.)
 */

/* declarations from other test modules */
void run_example_tests(void);

int main(void)
{
    test_example();

    printf("==== RUNNING TEST SUITE ====\n\n");

    run_example_tests();

    printf("\n==== ALL TESTS PASSED ====\n");
    return 0;
}
EOF
    fi

    if [ ! -f "$target_dir/tests/test_example.c" ]; then
        cat > "$target_dir/tests/test_example.c" <<'EOF'
#include <assert.h>
#include <stdio.h>

#define TEST(name) printf("RUNNING: %s\n", name)

static void test_dummy(void) {
    assert(1 == 1);
}

void run_example_tests(void) {
    TEST("dummy test");
    test_dummy();
}
EOF
    fi

    if [ ! -f "$target_dir/Makefile" ]; then
        cat > "$target_dir/Makefile" <<'EOF'
CC = gcc
CFLAGS = \
	-Iinclude \
	-Wall \
	-Wextra \
	-Wpedantic \
	-Wconversion \
	-Wsign-conversion \
	-Wno-override-init \
	-std=c11
DEVFLAGS = \
	-fsanitize=address,undefined \
	-fno-omit-frame-pointer \
	-g3 \
    -fanalyzer
RELEASEFLAGS = -O2

SRC = $(wildcard src/*.c)
APP_MAIN = src/main.c
LIB_SRC = $(filter-out $(APP_MAIN), $(SRC))

TEST_MAIN = tests/test_main.c
TEST_SRC = $(filter-out $(TEST_MAIN), $(wildcard tests/*.c))

OUT = build/app
TEST_OUT = build/test

dev:
	mkdir -p build
	$(CC) $(CFLAGS) $(DEVFLAGS) $(SRC) -o $(OUT)

build:
	mkdir -p build
	$(CC) $(CFLAGS) $(RELEASEFLAGS) $(SRC) -o $(OUT)

run: dev
	./$(OUT)

test:
	mkdir -p build
	$(CC) $(CFLAGS) $(DEVFLAGS) $(LIB_SRC) $(TEST_SRC) $(TEST_MAIN) -o $(TEST_OUT)
	./$(TEST_OUT)

clean:
	rm -rf build
EOF
    fi

    if [ ! -f "$target_dir/.gitignore" ]; then
        cat > "$target_dir/.gitignore" <<'EOF'
build/
*.o
*.obj
*.exe
*.out
*.swp
*.swo
*~
.DS_Store
.vscode/
EOF
    fi

    if [[ -n "$project_name" ]]; then
        cd "$target_dir"
        echo "Initialized C project: $(pwd)"
    else
        echo "Initialized minimal C project in: $(pwd)"
    fi
}
