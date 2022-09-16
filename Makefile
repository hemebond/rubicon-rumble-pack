CC=fteqcc64
CFLAGS=-Wall -O3


# all: effectinfo.txt progs.dat csprogs.dat
all: progs.dat



progs.dat: $(shell find qc -name *.qc) ./qc/progs.src
	$(CC) $(CFLAGS) -srcfile qc/progs.src



csprogs.dat: $(shell find qc -name *.qc) ./qc/csprogs.src
	$(CC) $(CFLAGS) -srcfile qc/csprogs.src



effectinfo.txt: ./effectinfo.d/*
	./effectinfo.sh
