# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: juloo <juloo@student.42.fr>                +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/05/15 16:07:55 by juloo             #+#    #+#              #
#    Updated: 2016/05/18 12:14:04 by juloo            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BUILD_DIR			= _build
OBJS_DIR			= _objs

BUILD_TARGET		= build
JS_OF_OCAML_TARGET	= $(BUILD_DIR)/popup.js
OCAML_TARGET		= $(OBJS_DIR)/popup.byte

all: $(BUILD_TARGET)

#
# Build extension
#

RES_DIR				= res
RES_FILES			:= $(shell find $(RES_DIR) -type f)
_RES_FILES			= $(RES_FILES:$(RES_DIR)/%=$(BUILD_DIR)/%)

$(BUILD_TARGET): $(JS_OF_OCAML_TARGET) $(_RES_FILES) | $(BUILD_DIR)
.PHONY: $(BUILD_TARGET)

$(BUILD_DIR)/%: $(RES_DIR)/% | $(BUILD_DIR)
	ln -s $(abspath $<) $@ && $(PRINT_SUCCESS)

#
# Build js file
#

JS_OF_OCAML_FLAGS	= --pretty --no-inline

$(JS_OF_OCAML_TARGET): $(OCAML_TARGET) | $(BUILD_DIR)
	js_of_ocaml $(JS_OF_OCAML_FLAGS) -o $@ $< && $(PRINT_SUCCESS)

#
# Build Ocaml bytecode
#

OCAML_DIRS			= srcs
OCAML_FLAGS			+= -g $(addprefix -I ,$(OCAML_OBJ_TREE))
OCAML_FIND			= -package js_of_ocaml,js_of_ocaml.syntax -syntax camlp4o
OCAML_DEPEND		= $(OBJS_DIR)/ocaml_depend.mk

-include $(OCAML_DEPEND)

$(OCAML_TARGET): $(OCAML_OBJS)
	$(OCAMLC) $(OCAML_FLAGS) -o $@ $(filter %.cmo,$(OCAML_OBJS)) && $(PRINT_SUCCESS)

$(OBJS_DIR)/%.cmi: %.mli | $(OCAML_OBJ_TREE)
	$(OCAMLC) $(OCAML_FLAGS) -o $@ -c $< && $(PRINT_SUCCESS)
$(OBJS_DIR)/%.cmo: %.ml | $(OCAML_OBJ_TREE)
	$(OCAMLC) $(OCAML_FLAGS) -o $@ -c $< && $(PRINT_SUCCESS)

$(OCAML_OBJ_TREE): | $(OBJS_DIR)
	mkdir -p $@

i: $(filter %.cmi,$(OCAML_OBJS))
	OCAML_FLAGS=-i make $(filter %.cmo,$(OCAML_OBJS))

$(OCAML_DEPEND): | $(OBJS_DIR)
	(																					\
		SRC_TREE="`find $(OCAML_DIRS) -type d`"											;\
		SOURCES="`find $(OCAML_DIRS) -name '*.ml*' -type f`"							;\
		INCLUDES="`for d in $$SRC_TREE; do echo "-I $$d"; done`"						;\
		printf "OCAML_OBJS ="															;\
		for obj in `ocamlfind ocamldep $(OCAML_FIND) -sort $$INCLUDES $$SOURCES |		\
				tr ' ' '\n' | sed -e 's/\.ml$$/.cmo/' -e 's/\.mli$$/.cmi/'`; do			\
			printf " \\\\\n\t%s/%s" "$(OBJS_DIR)" "$$obj"								;\
		done ; echo																		;\
		printf "OCAML_OBJ_TREE ="														;\
		for d in $$SRC_TREE; do printf " %s/%s" "$(OBJS_DIR)" "$$d"; done ; echo		;\
		printf "OCAMLC = " ; ocamlfind ocamlc $(OCAML_FIND) -linkpkg -only-show			;\
	) > $(OCAML_DEPEND)

#
# Misc
#

PRINT_SUCCESS		= printf "\033[32m%s\033[0m\n" "$@"

$(BUILD_DIR) $(OBJS_DIR):
	mkdir $@

clean:
	-rm -f $(_RES_FILES) 2> /dev/null || true
	-rm -f $(JS_OF_OCAML_TARGET) 2> /dev/null || true
	-rm -f $(OCAML_TARGET) 2> /dev/null || true
	-rm -f $(OCAML_OBJS) 2> /dev/null || true
	-rm -f $(OCAML_DEPEND) 2> /dev/null || true
	-rmdir -p $(OCAML_OBJ_TREE) 2> /dev/null || true

fclean: clean

re: fclean
	make

.SILENT:
.PHONY: all clean fclean re
