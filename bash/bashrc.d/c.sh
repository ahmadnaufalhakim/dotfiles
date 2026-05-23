#!/usr/bin/env bash

init_c() {
    mkdir -p src build tests include

    if [ ! -f src/main.c ]; then
        cat > src/main.c <<'EOF'
#include <stdio.h>

int main(void) {
    printf("Hello, world!\n");
    return 0;
}
EOF
    fi

    if [ ! -f tests/test_main.c ]; then
        cat > tests/test_main.c <<'EOF'
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

    if [ ! -f tests/test_example.c ]; then
        cat > tests/test_example.c <<'EOF'
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

    if [ ! -f Makefile ]; then
        cat > Makefile <<'EOF'
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

    echo "Initialized minimal C project in: $(pwd)"
}
