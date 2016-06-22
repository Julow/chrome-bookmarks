(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/24 19:10:12 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/06/22 22:56:06 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Result.Type

type event_t =
	| Bookmark_click of Bookmarks.folder_t
	| Arrow_key of [ `Left | `Right | `Up | `Down ]
	| Enter_key
	| Tab_key
	| Char_key of string
	| Search_input of string

let (><) (min, max) a = a >= min && a <= max

let keydown_observable, keypress_observable =
	let is_input e =
		Js.Opt.case e##.target
			(fun () -> false)
			(fun t -> t##.nodeName = (Js.string "INPUT"))
	in
	let on_keypress e =
		let r = Result.of_bool (not (is_input e))
			&&? fun () -> Js.Optdef.case e##.charCode Result.error Result.ok
			&&? fun c ->
				let s = Js.string_constr##fromCharCode c |> Js.to_string in
				let mods = Keys_handler.modifiers e in
				if mods = Keys_handler.shift then
					Ok (Char_key s)
				else if mods = 0 then
					Ok (Char_key (String.lowercase s))
				else
					Error ()
		in
		Result.get Keys_handler.unused r
	in
	let on_keydown e =
		match e##.keyCode, Keys_handler.modifiers e, is_input e with
		| 38,	0,	_			-> Arrow_key `Up
		| 40,	0,	_			-> Arrow_key `Down
		| 37,	0,	false		-> Arrow_key `Left
		| 39,	0,	false		-> Arrow_key `Right
		| 9,	0,	false		-> Tab_key
		| 13,	0,	_			-> Enter_key
		| _						-> Keys_handler.unused ()
	in
	Keys_handler.observe Dom_html.document Dom_html.Event.keydown on_keydown,
	Keys_handler.observe Dom_html.document Dom_html.Event.keypress on_keypress

let root_observable = Observable.join [
	keydown_observable;
	keypress_observable;
	Observable.map Bookmarks.on_click_observable (fun f -> Bookmark_click f);
	Observable.map Search_input.search_observer (fun s -> Search_input s)
]

type t = {
	root_bookmarks	:Bookmarks.t array;
	bookmarks		:Bookmarks.t array;
	cursor			:Cursor.t
}

let () =
	let bookmark_section =
		Js.Opt.get (Dom_html.CoerceTo.div (Dom_html.getElementById "bookmark_section"))
			(fun () -> assert false)
	in

	let main_loop t event =
		match event with
		| Bookmark_click b	->
			Bookmarks.set_opened b (not b.Bookmarks.opened);
			t

		| Arrow_key k		->
			let f = match k with
				| `Down			-> Cursor.select_next 1
				| `Up			-> Cursor.select_next (-1)
				| `Left			-> Cursor.select_parent
				| `Right		-> Cursor.select_child
			in
			{ t with cursor = f t.bookmarks t.cursor }

		| Char_key c		->
			Search_input.append c;
			Search_input.focus ();
			t

		| Enter_key			->
			begin match Cursor.get t.bookmarks t.cursor with
			| Bookmarks.Folder _	-> ()
			| Bookmarks.Leaf l		->
				let props = object%js
					val url = Js.string l.Bookmarks.url
				end in
				Chrome.tabs##create props ignore
			end;
			t

		| Tab_key			->
			Search_input.focus ();
			{ t with cursor = Cursor.zero }

		| Search_input s	->
			let put_view =
				if (String.length s) = 0 then
					Bookmarks.put_folder_view
				else
					Bookmarks.put_list_view (String_score.score s)
			in
			{ t with
				bookmarks = put_view bookmark_section t.root_bookmarks;
				cursor = Cursor.zero
			}

	in

	let callback tree =
		let t =
			let tree =
				let tree = Array.get (Js.to_array tree) 0 in
				let tree = Js.Optdef.get tree##.children (fun () -> assert false) in
				let tree = Array.map (Bookmarks.from_chrome_tree) (Js.to_array tree) in
				let childs b =
					match b with
					| Bookmarks.Folder f	-> f.Bookmarks.childs
					| _						-> assert false
				in
				let bookmarks_bar = childs (tree.(0)) in
				let other_bookmarks =
					let b = tree.(1) in
					if Array.length (childs b) > 0 then [| b |] else [||]
				in
				Array.append bookmarks_bar other_bookmarks
			in

			{
				root_bookmarks = tree;
				bookmarks = Bookmarks.put_folder_view bookmark_section tree;
				cursor = Cursor.zero
			}
		in

		Observable.fold root_observable t main_loop |> ignore

	in
	Chrome.bookmarks##getTree callback;
