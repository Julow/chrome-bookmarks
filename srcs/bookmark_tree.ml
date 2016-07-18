(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   bookmark_tree.ml                                   :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/07/18 23:16:11 by juloo             #+#    #+#             *)
(*   Updated: 2016/07/19 00:38:56 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type t = {
	view		:Bookmark.t array;
	cursor		:Cursor.t;
	root		:Bookmark.t array;
	map			:Bookmark.t Utils.StringMap.t
}

(* build bookmark_tree.t from a chrome bookmark tree *)

let of_chrome_tree tree = 
	let map = Utils.StringMap.create 64 in
	let root = Array.map (Bookmark.of_chrome_tree_node map) (Js.to_array tree) in
	{
		view = root;
		cursor = Cursor.zero;
		root;
		map
	}

(* Cursor *)
(* TODO: generalize/remove cursor module *)

let move_cursor tree dir =
	let f = match dir with
		| `Next			-> Cursor.select_next 1
		| `Prev			-> Cursor.select_next (-1)
		| `Parent		-> Cursor.select_parent
		| `Child		-> Cursor.select_child
		| `Reset		-> (fun _ _ -> Cursor.zero)
	in
	{ tree with cursor = f tree.view tree.cursor }

let get_selected tree =
	Cursor.get tree.view tree.cursor

(* folder view *)

let put_folder_view parent_element tree =
	let rec loop parent_element node =
		let e = Bookmark.element node in
		begin match Bookmark.data node with
		| Bookmark.Folder f	-> Array.iter (loop e) f.Bookmark.childs
		| Bookmark.Leaf _	-> ()
		end;
		Dom.appendChild parent_element e
	in
	Array.iter (loop parent_element) tree.root;
	{ tree with view = tree.root ; cursor = Cursor.zero }

(* list view *)
(* sort leaf nodes using the score function as key *)

let put_list_view score parent_element tree =
	let score_list =
		let rec score_list acc node =
			Js_utils.remove_element (Bookmark.element node);
			match Bookmark.data node with
			| Bookmark.Folder f		->
				Array.fold_left score_list acc f.Bookmark.childs
			| Bookmark.Leaf _		->
				let score = score (Bookmark.title node) in
				if score < 0 then
					acc
				else
					(score, node) :: acc
		in
		Array.fold_left score_list [] tree.root
	in
	let sorted =
		let score_cmp (a, _) (b, _) = b - a in
		List.sort score_cmp score_list
	in
	List.iter (fun (_, b) -> Dom.appendChild parent_element (Bookmark.element b)) sorted;
	{ tree with
		view = Array.of_list (List.map (fun (_, b) -> b) sorted);
		cursor = Cursor.zero
	}
