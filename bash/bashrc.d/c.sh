#!/usr/bin/env bash

init_c() {
    mkdir -p src build tests

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

int main(void)
{
    test_example();
    printf("ALL TESTS PASSED\n");
    return 0;
}
EOF
    fi

    if [ ! -f Makefile ]; then
        cat > Makefile <<'EOF'
CC = gcc

CFLAGS = -Wall -Wextra -std=c11
DEVFLAGS = -fsanitize=address -g
RELEASEFLAGS = -O2

SRC = $(wildcard src/*.c)
TEST_SRC = $(wildcard tests/*.c)

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
    $(CC) $(CFLAGS) $(DEVFLAGS) $(SRC) $(TEST_SRC) -o $(TEST_OUT)
    ./$(TEST_OUT)

clean:
	rm -rf build
EOF
    fi

    echo "Initialized minimal C project in: $(pwd)"
}
