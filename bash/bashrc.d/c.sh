#!/usr/bin/env bash

init_c() {
    set -e

    mkdir -p src build

    # Create main.c if it doesn't exist
    if [ ! -f src/main.c ]; then
        cat > src/main.c <<'EOF'
#include <stdio.h>

int main(int argc, char *argv[]) {
    printf("Hello, world!\n");
    return 0;
}
EOF
    fi

    # Create Makefile
    cat > Makefile <<'EOF'
CC = gcc

CFLAGS = -Wall -Wextra -std=c11
DEVFLAGS = -fsanitize=address -g
RELEASEFLAGS = -O2

SRC = src/main.c
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

    echo "Initialized minimal C project in: $(pwd)"
}