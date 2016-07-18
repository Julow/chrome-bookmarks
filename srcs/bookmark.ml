(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   bookmark.ml                                        :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/07/18 22:20:56 by juloo             #+#    #+#             *)
(*   Updated: 2016/07/19 00:40:33 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type folder_t = {
	opened		:bool;
	childs		:t array
}

and leaf_t = {
	url			:string
}

and data_t = Folder of folder_t | Leaf of leaf_t

and node_t = {
	id				:string;
	title			:string;
	element			:Dom_html.element Js.t;
	title_element	:Dom_html.anchorElement Js.t;
	data			:data_t
}

and t = node_t ref

let id node = !node.id
let title node = !node.title
let element node = !node.element
let title_element node = !node.title_element
let data node = !node.data

let rec of_chrome_tree_node map tree_node =

	let element = Dom_html.createDiv Dom_html.document in
	let title_element = Dom_html.createA Dom_html.document in

	title_element##.textContent := (Js.some tree_node##.title);
	title_element##.classList##add (Js.string "bookmark_label");
	title_element##.href := (Js.Optdef.get (tree_node##.url) (fun () -> Js.string "#"));
	Dom.appendChild element title_element;

	let create_folder () =
		element##.classList##add (Js.string "bookmark_folder");
		Folder {
			opened = false;
			childs = Js.Optdef.case tree_node##.children (fun () -> [||])
					(fun c -> Array.map (of_chrome_tree_node map) (Js.to_array c))
		}
	in

	let create_leaf url =
		element##.classList##add (Js.string "bookmark");
		Leaf {
			url = Js.to_string url
		}
	in

	let id = Js.to_string tree_node##.id in

	let node = ref {
		id;
		title = Js.to_string tree_node##.title;
		element;
		title_element;
		data = Js.Optdef.case (tree_node##.url) create_folder create_leaf
	} in
	Utils.StringMap.add map id node;
	node

let set_opened node opened =
	let open_class = Js.string "open" in
	let element = element node in
	let data = match data node with
		| Folder f		-> Folder { f with opened }
		| Leaf _		-> assert false
	in
	node := { !node with data };
	if opened then
		element##.classList##add open_class
	else
		element##.classList##remove open_class
