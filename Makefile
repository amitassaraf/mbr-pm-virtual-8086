
# The source assembly files
ASM = $(wildcard *.asm)

# The binary
BINS = $(ASM:.asm=.bin)

# Compile all the assembly files to bin files
$(BINS): $(ASM)
	nasm -O0 $^ -o $@

# Compile the MBR
all: $(BINS)
	@echo  The MBR has been compiled.


.PHONY: clean

# Clean the created bin files
clean:
	sudo rm -rf $(BINS)