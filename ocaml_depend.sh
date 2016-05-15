# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    ocaml_depend.sh                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: juloo <juloo@student.42.fr>                +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/05/15 16:09:28 by juloo             #+#    #+#              #
#    Updated: 2016/05/15 18:16:47 by juloo            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#
# Generate ocaml depend file
#
# Should be called from `make depend`
# Variable DEPEND_FILE, OBJS_DIR, OCAML_DIRS have to be defined
#

OCAML_SOURCES="`find $OCAML_DIRS -name '*.ml*' -type f`"

OCAML_FLAGS=""
OCAML_OBJ_TREE=""
for dir_name in `find $OCAML_DIRS -type d`; do
	OCAML_FLAGS="$OCAML_FLAGS -I $dir_name"
	OCAML_OBJ_TREE="$OCAML_OBJ_TREE $OBJS_DIR/$dir_name"
done

OCAML_OBJS=""

for file_name in `ocamldep -sort $OCAML_FLAGS $OCAML_SOURCES`; do
	file_name=${file_name/.mli/.cmi}
	file_name=${file_name/.ml/.cmo}
	OCAML_OBJS="$OCAML_OBJS $OBJS_DIR/$file_name"
done

(
	printf "OCAML_OBJS ="
	for obj in $OCAML_OBJS; do
		printf " \\\\\n\t%s" "$obj"
	done
	echo
	echo "OCAML_OBJ_TREE =$OCAML_OBJ_TREE"
	echo

	ocamldep -one-line -all $OCAML_FLAGS $OCAML_SOURCES | python -c '
import sys
from os import path

objs_dir = "'"$OBJS_DIR"'/"

objs_exts = [".cmi", ".cmo", ".cmx", ".o"]

def prefix_obj_dir(files):
	return [objs_dir + f if path.splitext(f)[1] in objs_exts else f for f in files.split()]

for line in sys.stdin:
	targets, dependencies = tuple(line.split(":"))
	print("%s: %s" % (
			" ".join(prefix_obj_dir(targets)),
			" ".join(prefix_obj_dir(dependencies))
		))
	'

) > $DEPEND_FILE || exit 1
