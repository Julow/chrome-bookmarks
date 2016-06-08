(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   bookmarks.ml                                       :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/24 12:30:10 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/06/08 22:13:35 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type folder_t = {
	id				:Js.js_string Js.t;
	element			:Dom_html.element Js.t;
	title			:Dom_html.anchorElement Js.t;
	mutable opened	:bool;
	childs			:t array
}

and leaf_t = {
	leaf_id			:Js.js_string Js.t;
	leaf_element	:Dom_html.element Js.t;
	leaf_title		:Dom_html.anchorElement Js.t;
	url				:Js.js_string Js.t
}

and t = Folder of folder_t | Leaf of leaf_t

(* getter *)

let element b =
	match b with
	| Folder f	-> f.element
	| Leaf l	-> l.leaf_element

let title b =
	match b with
	| Folder f	-> f.title
	| Leaf l	-> l.leaf_title

(* on folder click observable *)

let on_click_observable = Observable.create ()

let on_click_handler node _ =
	Observable.notify on_click_observable node;
	Js._false

(* convert chrome bookmarks tree to t *)

let rec from_chrome_tree node =

	let div = Dom_html.createDiv Dom_html.document in
	let title = Dom_html.createA Dom_html.document in

	title##.textContent := (Js.some node##.title);
	title##.classList##add (Js.string "bookmark_label");
	title##.href := (Js.Optdef.get (node##.url) (fun () -> Js.string "#"));
	Dom.appendChild div title;

	let create_folder () =
		div##.classList##add (Js.string "bookmark_folder");
		let f = {
			id = node##.id;
			element = div;
			title = title;
			opened = false;
			childs = Js.Optdef.case node##.children (fun () -> [||])
					(fun c -> Array.map from_chrome_tree (Js.to_array c))
		} in

		(* LOL *)
		ignore (Dom_html.addEventListener title Dom_html.Event.click
			(Dom_html.handler (on_click_handler f)) Js._false);

		Folder f
	in

	let create_leaf url =
		div##.classList##add (Js.string "bookmark");
		Leaf {
			leaf_id = node##.id;
			leaf_element = div;
			leaf_title = title;
			url = url
		}
	in

	Js.Optdef.case (node##.url) create_folder create_leaf

(* folder view *)

let rec put_folder_view parent_element node =
	let e = match node with
		| Folder f		->
			f.element##.classList##remove (Js.string "hidden");
			Array.iter (put_folder_view f.element) f.childs;
			f.element
		| Leaf l		-> l.leaf_element
	in
	Dom.appendChild parent_element e

(* list view *)

let rec put_list_view parent_element node =
	match node with
	| Folder f		->
		f.element##.classList##add (Js.string "hidden");
		Array.iter (put_list_view parent_element) f.childs
	| Leaf l		->
		Dom.appendChild parent_element l.leaf_element

(* open/close a folder *)

let set_opened b v =
	let open_class = Js.string "open" in
	b.opened <- v;
	if v then
		b.element##.classList##add (open_class)
	else
		b.element##.classList##remove (open_class)
