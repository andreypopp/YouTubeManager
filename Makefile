SRC = $(shell find src -name '*.coffee')
LIB = $(SRC:src/%.coffee=lib/%.js)

all: lib

lib: $(LIB)

watch:
	coffee -bc --watch -o lib src

lib/%.js: src/%.coffee
	@echo `date "+%H:%M:%S"` - compiled $<
	@mkdir -p $(@D)
	@coffee -bcp $< > $@

clean:
	rm -rf $(LIB)
