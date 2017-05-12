#!/usr/bin/make

# Author: Shuhei Hayakawa

#_______________________________________________________________________________
TARGET_NAME	= git-manual
INC_DIR		= inc
FIG_DIR		= fig
BLD_DIR		= build
TEXT_ENCODING	= utf8
COLOR		= 1
#
TEX2DVI	= platex --kanji=$(TEXT_ENCODING)
DVI2PDF	= dvipdfmx
DVI2PS	= dvips
#
CONVERT	= convert
ECHO	= gecho -e
CP	= cp -fpr
MV	= mv -f
RM	= rm -frv

#_______________________________________________________________________________
TARGET_TEX	= $(TARGET_NAME).tex
TARGET_DVI	= $(TARGET_NAME).dvi
TARGET_PDF	= $(TARGET_NAME).pdf
TARGET_PS	= $(TARGET_NAME).ps
INC_TEX	= $(wildcard $(INC_DIR)/*.tex)

FIG_JPG	= $(wildcard $(FIG_DIR)/*.jpg)
FIG_GIF	= $(wildcard $(FIG_DIR)/*.gif)
FIG_PNG	= $(wildcard $(FIG_DIR)/*.png)
FIG_EPS	= $(FIG_JPG:.jpg=.eps) $(FIG_GIF:.gif=.eps) $(FIG_PNG:.png=.eps)

TARGET_TAR	= $(TARGET_NAME).tar.gz
TAR_EXCLUDE	= $(shell find . -name "*~" -o -name "\#*\#" -o -name ".DS_Store" )
TAR_SRC		= \
	$(TARGET_TEX) $(INC_DIR) $(FIG_DIR) \
	$(wildcard *.sty) Makefile

OUT_FILES	= aux bbl blg dvi idx lof log lot out toc
BLD_OUT	= \
	$(addprefix *., $(OUT_FILES)) \
	$(addprefix $(INC_DIR)/*., $(OUT_FILES))

#_______________________________________________________________________________
# STDOUT	= /dev/null
# STDERR	= /dev/null
STDOUT	= /dev/tty
STDERR	= /dev/tty
ifeq ($(COLOR), 1)
  DEF		= \\e[m
  BLACK		= \\e[30;1m
  RED		= \\e[31;1m
  GREEN		= \\e[32;1m
  YELLOW	= \\e[33;1m
  BLUE		= \\e[34;1m
  MAGENTA	= \\e[35;1m
  CYAN		= \\e[36;1m
  WHITE		= \\e[33;1m
endif

#_______________________________________________________________________________
.PHONY: all dvi pdf ps eps clean distclean tar show help

#all: pdf ps
all: pdf

dvi: $(TARGET_DVI)
pdf: $(TARGET_PDF)
ps:  $(TARGET_PS)

$(BLD_DIR)/$(TARGET_DVI): $(TARGET_TEX) $(INC_TEX) $(FIG_EPS)
	@$(ECHO) "$(GREEN)=== Compiling $< ...$(DEF)"
	@$(TEX2DVI) $< >$(STDOUT) 2>$(STDERR)
	@$(TEX2DVI) $< >$(STDOUT) 2>$(STDERR)
	@mkdir -p $(BLD_DIR)
	@for f in $(BLD_OUT); do \
	if [ -f $$f ]; then $(MV) $$f $(BLD_DIR); fi; done;

$(TARGET_PDF): $(BLD_DIR)/$(TARGET_DVI)
	@$(ECHO) "$(GREEN)=== Converting $@ ...$(DEF)"
	@$(DVI2PDF) $< >$(STDOUT) 2>$(STDERR)

$(TARGET_PS): $(BLD_DIR)/$(TARGET_DVI)
	@$(ECHO) "$(GREEN)=== Converting $@ ...$(DEF)"
	@$(DVI2PS) $< >$(STDOUT) 2>$(STDERR)

#===== eps
eps: $(FIG_EPS)

%.eps: %.jpg
	@$(ECHO) "$(GREEN)=== Converting $(shell basename $@) ...$(DEF)"
	@$(CONVERT) $< eps2:$@
#	@test -d $(ORG_DIR) && $(MV) $< $(ORG_DIR)

%.eps: %.gif
	@$(ECHO) "$(GREEN)=== Converting $(shell basename $@) ...$(DEF)"
	@$(CONVERT) $< eps2:$@
#	@test -d $(ORG_DIR) && $(MV) $< $(ORG_DIR)

%.eps: %.png
	@$(ECHO) "$(GREEN)=== Converting $(shell basename $@) ...$(DEF)"
	@$(CONVERT) $< eps2:$@
#	@test -d $(ORG_DIR) && $(MV) $< $(ORG_DIR)

#===== misc.
clean:
	@$(ECHO) "$(YELLOW)=== Cleaning up ...$(DEF)"
	@$(RM) $(BLD_DIR) *~ \#*\# $(INC_DIR)/*~ $(INC_DIR)/\#*\# \
	>$(STDOUT) 2>$(STDERR)

distclean:
	@$(ECHO) "$(YELLOW)=== Cleaning up ...$(DEF)"
	@$(RM) $(BLD_DIR) *~ \#*\# $(INC_DIR)/*~ $(INC_DIR)/\#*\# \
	$(TARGET_PDF) $(TARGET_PS) $(TARGET_TAR) \
	>$(STDOUT) 2>$(STDERR)

tar: $(TARGET_TAR)
$(TARGET_TAR): $(TAR_SRC)
	@$(ECHO) "$(RED)=== Creating $(TARGET_TAR) ...$(DEF)"
	@test -d $(TARGET_NAME) || mkdir $(TARGET_NAME)
	@$(CP) $(TAR_SRC) $(TARGET_NAME)/
	@tar $(addprefix --exclude=,$(TAR_EXCLUDE)) -vczf $(TARGET_TAR) $(TARGET_NAME)/ \
	>$(STDOUT) 2>$(STDERR)
	@$(RM) $(TARGET_NAME)/ >/dev/null

show:
	@$(ECHO) "$(RED)===== configuration ==============================$(DEF)"
	@$(ECHO) "PWD		: $(PWD)"
	@$(ECHO) "TARGET_NAME	: $(TARGET_NAME)"
	@$(ECHO) "INC_DIR		: $(INC_DIR)"
	@$(ECHO) "FIG_DIR		: $(FIG_DIR)"
#	@$(ECHO) "ORG_DIR		: $(ORG_DIR)"
	@$(ECHO) "BLD_DIR		: $(BLD_DIR)"
	@$(ECHO) "TEXT_ENCODING	: $(TEXT_ENCODING)"
	@$(ECHO) "$(GREEN)===== command ====================================$(DEF)"
	@$(ECHO) "TEX2DVI		: $(TEX2DVI)"
	@$(ECHO) "DVI2PDF		: $(DVI2PDF)"
	@$(ECHO) "DVI2PS		: $(DVI2PS)"
	@$(ECHO) "CONVERT		: $(CONVERT)"
	@$(ECHO) "ECHO		: $(ECHO)"
	@$(ECHO) "MV		: $(MV)"
	@$(ECHO) "RM		: $(RM)"
	@$(ECHO) "$(YELLOW)===== target =====================================$(DEF)"
	@$(ECHO) "TARGET_TEX	: $(TARGET_TEX)"
	@$(ECHO) "TARGET_DVI	: $(TARGET_DVI)"
	@$(ECHO) "TARGET_PDF	: $(TARGET_PDF)"
	@$(ECHO) "TARGET_PS	: $(TARGET_PS)"
	@$(ECHO) "INC_TEX	:"
	@for f in $(INC_TEX); do $(ECHO) "	$$f"; done;
	@$(ECHO) "FIG_JPG	:"
	@for f in $(FIG_JPG); do $(ECHO) "	$$f"; done;
	@$(ECHO) "FIG_GIF	:"
	@for f in $(FIG_GIF); do $(ECHO) "	$$f"; done;
	@$(ECHO) "FIG_PNG	:"
	@for f in $(FIG_PNG); do $(ECHO) "	$$f"; done;
	@$(ECHO) "FIG_EPS	:"
	@for f in $(FIG_EPS); do $(ECHO) "	$$f"; done;
	@$(ECHO) "TARGET_TAR	: $(TARGET_TAR)"
	@$(ECHO) "TAR_EXC_FILE	: $(TAR_EXC_FILE)"
	@$(ECHO) "TAR_SRC	:"
	@for f in $(TAR_SRC); do $(ECHO) "	$$f"; done;
	@$(ECHO) "BLD_OUT	:"
	@for f in $(BLD_OUT); do $(ECHO) "	$$f"; done;
	@$(ECHO) "$(BLUE)===== stdout/stderr ==============================$(DEF)"
	@$(ECHO) "STDOUT	: $(STDOUT)"
	@$(ECHO) "STDERR	: $(STDERR)"

help:
	@$(ECHO) "$(GREEN)=== Showing target list ...$(DEF)"
	@$(MAKE) --print-data-base --question | \
	awk '/^[^.%][-A-Za-z0-9_]*:/ \
	{ print substr($$1, 1, length($$1)-1) }' | \
	sort | uniq | pr -t -w 80 -4
