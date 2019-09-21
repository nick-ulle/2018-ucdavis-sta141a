
watch = standards.md

code =
citation =

template = new_syllabus

# ----- Extra Arguments {{{
# Set up extra pandoc arguments.
data_dir = $(HOME)/.config/pandoc
pandoc_ =

# Set biblatex flag.
ifeq ($(citation),biblatex)
pandoc_ := $(pandoc_) --biblatex
else 
ifeq ($(citation),cite-proc)
pandoc_ := $(pandoc_) --filter pandoc-citeproc
endif
endif

# Set the code block package.
ifeq ($(code),minted)
pandoc_ := $(pandoc_) --filter pandoc-minted
else
ifeq ($(code),listings)
pandoc_ := $(pandoc_) --listings
endif
endif
# }}}

all: standards.pdf

%.pdf: %.md
	pandoc --data-dir=$(data_dir) --template=$(template) $(pandoc_) \
		--pdf-engine=lualatex -o $@ $<

watch:
	while true; do inotifywait --event modify $(watch); $(MAKE); done

reset:
	rm standards.pdf

rebuild: reset all

.PHONY: all reset rebuild
