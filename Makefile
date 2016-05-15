# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: juloo <juloo@student.42.fr>                +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/05/15 16:07:55 by juloo             #+#    #+#              #
#    Updated: 2016/05/15 19:13:26 by juloo            ###   ########.fr        #
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

$(BUILD_TARGET): $(_RES_FILES) | $(JS_OF_OCAML_TARGET) $(BUILD_DIR)
.PHONY: $(BUILD_TARGET)

$(BUILD_DIR)/%: $(RES_DIR)/% | $(BUILD_DIR)
	cp $< $@

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
OCAML_FLAGS			= -g $(addprefix -I ,$(OCAML_OBJ_TREE))
OCAML_FIND			= -package js_of_ocaml,js_of_ocaml.syntax -syntax camlp4o -linkpkg
OCAML_DEPEND		= depend.mk

-include $(OCAML_DEPEND)

OCAML_COMMAND		:= $(shell ocamlfind ocamlc $(OCAML_FIND) -only-show) $(OCAML_FLAGS)

$(OCAML_TARGET): $(OCAML_OBJS)
	echo $(OCAML_OBJS)
	$(OCAML_COMMAND) -o $@ $(filter %.cmo,$(OCAML_OBJS)) && $(PRINT_SUCCESS)

$(OBJS_DIR)/%.cmi: %.mli | $(OCAML_OBJ_TREE)
	$(OCAML_COMMAND) -o $@ -c $< && $(PRINT_SUCCESS)
$(OBJS_DIR)/%.cmo: %.ml | $(OCAML_OBJ_TREE)
	$(OCAML_COMMAND) -o $@ -c $< && $(PRINT_SUCCESS)

$(OCAML_OBJ_TREE): | $(OBJS_DIR)
	mkdir -p $@

$(OCAML_DEPEND):
	DEPEND_FILE=$(OCAML_DEPEND) OBJS_DIR=$(OBJS_DIR) OCAML_DIRS=$(OCAML_DIRS) bash ocaml_depend.sh

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

re: fclean all

.SILENT:
.PHONY: all clean fclean re
