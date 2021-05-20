APP = axidma-benchmark

# Add any other object files to this list below
APP_OBJS = axidma_benchmark.o
APP_OBJS += libaxidma.o
APP_OBJS += util.o

all: build

build: $(APP)

$(APP): $(APP_OBJS)
	$(CC) -o $@ $(APP_OBJS) $(LDFLAGS) $(LDLIBS)
clean:
	rm -f $(APP) *.o

