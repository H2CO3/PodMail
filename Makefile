TARGET = PodMail.dylib

CC = gcc
LD = $(CC)
CFLAGS = -isysroot /User/sysroot \
	 -I/usr/include/glib-2.0 \
	 -I/usr/include/gpod-1.0 \
	 -I. \
	 -I.. \
	 -Wall \
	 -std=gnu99 \
	 -DTARGET_OS_IPHONE=1 \
	 -c
LDFLAGS = -isysroot /User/sysroot \
	  -w \
	  -dynamiclib \
	  -lobjc \
	  -lsubstrate \
	  -framework CoreFoundation \
	  -framework MobileCoreServices \
	  -framework Foundation \
	  -framework UIKit \
	  -framework MessageUI \
	  -framework MFMusicLibrary

OBJECTS = PodMail.o \
	  PMViewController.o \
	  PMDonate.o \
	  NSString+PodMail.o

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $(TARGET) $(OBJECTS)
	sudo chown root:wheel $(TARGET)
	sudo cp $(TARGET) /Library/MobileSubstrate/DynamicLibraries

%.o: %.c
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.m
	$(CC) $(CFLAGS) -o $@ $^

