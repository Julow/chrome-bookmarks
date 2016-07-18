(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/24 19:10:12 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/07/19 01:20:59 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Result.Type

type event_t =
	| Bookmark_click of Bookmark.t
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
	Observable.map Bookmark.on_click_observable (fun f -> Bookmark_click f);
	Observable.map Search_input.search_observer (fun s -> Search_input s)
]

type t = {
	bookmarks		:Bookmark_tree.t
}

let () =
	let bookmark_section =
		Js.Opt.get (Dom_html.CoerceTo.div (Dom_html.getElementById "bookmark_section"))
			(fun () -> assert false)
	in

	let open_bookmark b =
		match Bookmark.data b with
		| Bookmark.Folder f		-> Bookmark.set_opened b (not f.Bookmark.opened)
		| Bookmark.Leaf l		->
			let props = object%js
				val url = Js.string l.Bookmark.url
			end in
			Chrome.tabs##create props ignore
	in

	let main_loop t = function
		| Bookmark_click b	->
			open_bookmark b;
			t

		| Arrow_key k		->
			let dir = match k with
				| `Down			-> `Next
				| `Up			-> `Prev
				| `Left			-> `Parent
				| `Right		-> `Child
			in
			{ bookmarks = Bookmark_tree.move_cursor t.bookmarks dir }

		| Char_key c		->
			Search_input.append c;
			Search_input.focus ();
			t

		| Enter_key			->
			open_bookmark (Bookmark_tree.get_selected t.bookmarks);
			t

		| Tab_key			->
			Search_input.focus ();
			{ bookmarks = Bookmark_tree.move_cursor t.bookmarks `Reset }

		| Search_input s	->
			let put_view =
				if (String.length s) = 0 then
					Bookmark_tree.put_folder_view
				else
					Bookmark_tree.put_list_view (String_score.score s)
			in
			{ bookmarks = put_view bookmark_section t.bookmarks }
	in

	let callback bookmarks =
		let t =
			let get_childs b =
				Js.Optdef.case b##.children (fun () -> assert false) Js.to_array
			in
			let bookmarks = Js.to_array bookmarks in
			let bookmarks = get_childs bookmarks.(0) in
			let bookmarks =
				let other_bookmarks =
					if Js.Optdef.case bookmarks.(1)##.children
						(fun () -> false) (fun c -> c##.length > 0) then
						 [| bookmarks.(1) |]
					else
						[| |]
				in
				Array.append (get_childs bookmarks.(0)) other_bookmarks
			in
			let bookmarks = Bookmark_tree.of_chrome_tree bookmarks in
			let bookmarks = Bookmark_tree.put_folder_view bookmark_section bookmarks in

			{ bookmarks }
		in

		Observable.fold root_observable t main_loop |> ignore

	in
	Chrome.bookmarks##getTree callback;
