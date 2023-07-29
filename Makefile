BIN_DIR = $(HOME)/.local/bin
SCRIPTS = reboot.sh shutdown.sh

OUTPUT_FILES = $(patsubst %.sh,$(BIN_DIR)/%,$(SCRIPTS))

all: $(OUTPUT_FILES)

$(BIN_DIR)/%: $(CURDIR)/%.sh
	link $< $@

clean:
	rm -f $(OUTPUT_FILES)
