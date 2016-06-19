(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/24 19:10:12 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/06/19 20:02:39 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type event_t =
	Bookmark_click of Bookmarks.folder_t
	| Arrow_key of int
	| Enter_key | Tab_key
	| Char_key of string
	| Search_input of string

let (><) (min, max) a = a >= min && a <= max

let arrow_key_observable = Observable.create ()
let char_key_observable = Observable.create ()
let action_observable = Observable.create ()

let root_observable = Observable.join [
	action_observable;
	Observable.map arrow_key_observable (fun k -> Arrow_key k);
	Observable.map char_key_observable (fun c -> Char_key c);
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
				| 40			-> Cursor.select_next 1
				| 38			-> Cursor.select_next (-1)
				| 37			-> Cursor.select_parent
				| 39			-> Cursor.select_child
				| _				-> assert false
			in
			{ t with cursor = f t.bookmarks t.cursor }

(* 		| Char_key c		->
			Search_input.append c;
			Search_input.focus ();
			t *)

		| Char_key _		-> assert false (* TODO: reimplement *)

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
			let t = { t with
				bookmarks = put_view bookmark_section t.root_bookmarks;
				cursor = Cursor.zero
			} in
			Js_utils.log t;
			t

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

	let on_keydown e =
		if Js.Opt.case e##.target
			(fun () -> false)
			(fun t -> t##.id = (Js.string "search_input")) then
			Js._true
		else
			let notify observable v =
				Observable.notify observable v;
				Js._false
			in
			if Js.to_bool (e##.shiftKey) || Js.to_bool (e##.ctrlKey)
				|| Js.to_bool (e##.metaKey) || Js.to_bool (e##.altKey) then
				Js._true
			else if (37, 40) >< (e##.keyCode) then
				notify arrow_key_observable e##.keyCode
			else if (e##.keyCode) == 9 then
				notify action_observable Tab_key
			else if (e##.keyCode) == 13 then
				notify action_observable Enter_key
			else
				Js._true
	in

	Dom_html.addEventListener Dom_html.document Dom_html.Event.keydown
		(Dom_html.handler on_keydown) Js._false |> ignore;
