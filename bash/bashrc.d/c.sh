#!/usr/bin/env bash

init_c() {
    mkdir -p src build

    if [ ! -f src/main.c ]; then
        cat > src/main.c <<'EOF'
#include <stdio.h>

int main(void) {
    printf("Hello, world!\n");
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
OUT = build/app

dev:
	mkdir -p build
	$(CC) $(CFLAGS) $(DEVFLAGS) $(SRC) -o $(OUT)

build:
	mkdir -p build
	$(CC) $(CFLAGS) $(RELEASEFLAGS) $(SRC) -o $(OUT)

run: dev
	./$(OUT)

clean:
	rm -rf build
EOF
    fi

    echo "Initialized minimal C project in: $(pwd)"
}
