# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: juloo <juloo@student.42.fr>                +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/05/15 16:07:55 by juloo             #+#    #+#              #
#    Updated: 2016/05/15 18:17:06 by juloo            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

OBJS_DIR			= _objs

JS_OF_OCAML_TARGET	= popup.js
JS_OF_OCAML_FLAGS	= --pretty --no-inline

OCAML_TARGET		= $(OBJS_DIR)/popup.byte
OCAML_DIRS			= srcs
OCAML_FLAGS			= -g $(addprefix -I ,$(OCAML_OBJ_TREE))
OCAML_FIND			= -package js_of_ocaml,js_of_ocaml.syntax -syntax camlp4o -linkpkg
OCAML_DEPEND		= depend.mk

PRINT_SUCCESS		= printf "\033[32m%s\033[0m\n" "$@"

all: $(JS_OF_OCAML_TARGET)

$(JS_OF_OCAML_TARGET): $(OCAML_TARGET)
	@js_of_ocaml $(JS_OF_OCAML_FLAGS) -o $@ $< && $(PRINT_SUCCESS)

-include $(OCAML_DEPEND)

OCAML_COMMAND		:= $(shell ocamlfind ocamlc $(OCAML_FIND) -only-show) $(OCAML_FLAGS)

$(OCAML_TARGET): $(OCAML_OBJ_TREE) $(OCAML_OBJS)
	@$(OCAML_COMMAND) -o $@ $(filter %.cmo,$(OCAML_OBJS)) && $(PRINT_SUCCESS)

$(OBJS_DIR)/%.cmi: %.mli
	@$(OCAML_COMMAND) -o $@ -c $< && $(PRINT_SUCCESS)
$(OBJS_DIR)/%.cmo: %.ml
	@$(OCAML_COMMAND) -o $@ -c $< && $(PRINT_SUCCESS)

$(OCAML_OBJ_TREE):
	@mkdir -p $@

clean:
	-@rm -f $(OCAML_TARGET) 2> /dev/null || true
	-@rm -f $(OCAML_OBJS) 2> /dev/null || true
	-@rm -f $(OCAML_DEPEND) 2> /dev/null || true
	-@rmdir -p $(OCAML_OBJ_TREE) 2> /dev/null || true

fclean: clean
	-@rm -f $(JS_OF_OCAML_TARGET)

$(OCAML_DEPEND):
	@DEPEND_FILE=$(OCAML_DEPEND) OBJS_DIR=$(OBJS_DIR) OCAML_DIRS=$(OCAML_DIRS) bash ocaml_depend.sh

re: fclean all

.PHONY: all clean fclean re
