(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/24 19:10:12 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/06/06 22:50:26 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type event_t =
	Bookmark_click of Bookmarks.folder_t
	| Arrow_key of int
	| Char_key of string
	| Search_input of string

let (><) (min, max) a = a >= min && a <= max

let arrow_key_observable = Observable.create ()
let char_key_observable = Observable.create ()

let root_observable = Observable.join [
	Observable.map arrow_key_observable (fun k -> Arrow_key k);
	Observable.map char_key_observable (fun c -> Char_key c);
	Observable.map Bookmarks.on_click_observable (fun f -> Bookmark_click f);
	Observable.map Search_input.search_observer (fun s -> Search_input s)
]

let array_find arr f =
	let rec find i =
		if i > (Array.length arr) then
			-1
		else if f arr.(i) then
			i
		else
			find (i + 1)
	in
	find 0

type t = {
	bookmarks		:Bookmarks.t array;
	cursor			:Cursor.t;
}

let () =
	let bookmark_section =
		Js.Opt.get (Dom_html.CoerceTo.div (Dom_html.getElementById "bookmark_section"))
			(fun () -> assert false)
	in

	let callback tree =
		let t =
			let tree =
				let tree = Array.get (Js.to_array tree) 0 in
				let tree = Js.Optdef.get (tree##children) (fun () -> assert false) in
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

			Array.iter (Bookmarks.put_folder_view bookmark_section) tree;

			{
				bookmarks = tree;
				cursor = Cursor.zero
			}
		in

		ignore (Observable.fold root_observable t (fun t -> function
			| Bookmark_click b	->
				Bookmarks.set_opened b (not b.Bookmarks.opened);
				t

			| Arrow_key 40		-> { t with cursor = Cursor.select_next t.bookmarks t.cursor 1 }
			| Arrow_key 38		-> { t with cursor = Cursor.select_next t.bookmarks t.cursor (-1) }
			| Arrow_key 37		-> { t with cursor = Cursor.select_parent t.bookmarks t.cursor }
			| Arrow_key 39		-> { t with cursor = Cursor.select_child t.bookmarks t.cursor }

			| Arrow_key _		-> assert false

			| Char_key c		->
				Search_input.append c;
				Search_input.focus ();
				t

			| Search_input s	->
				if (String.length s) = 0 then
					Array.iter (Bookmarks.put_folder_view bookmark_section) t.bookmarks
				else
					Array.iter (Bookmarks.put_list_view bookmark_section) t.bookmarks;
				t

		))

	in
	Chrome_bookmarks.getTree callback;

	let on_keydown e =
		if Js.to_bool (e##shiftKey) || Js.to_bool (e##ctrlKey)
			|| Js.to_bool (e##metaKey) || Js.to_bool (e##altKey)
			|| not ((37, 40) >< e##keyCode) then
			Js._true
		else
			(Observable.notify arrow_key_observable e##keyCode; Js._false)
	in

	let on_keypress e =
		let c = Js.to_string (Js.string_constr##fromCharCode (e##keyCode)) in
		Observable.notify char_key_observable c;
		Js._false
	in

	ignore (Dom_html.addEventListener Dom_html.document Dom_html.Event.keydown
			(Dom_html.handler on_keydown) Js._false);

	ignore (Dom_html.addEventListener Dom_html.document Dom_html.Event.keypress
			(Dom_html.handler on_keypress) Js._false)
