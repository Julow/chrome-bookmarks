(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/24 19:10:12 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/06/05 21:19:31 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type event_t =
	Bookmark_click of Bookmarks.folder_t
	| Arrow_key of int
	| Search_input of string

let (><) a (min, max) = a >= min && a <= max

let arrow_key_observable = Observable.create ()

let root_observable = Observable.join [
	Observable.map arrow_key_observable (fun k -> Arrow_key k);
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
	bookmarks			:Bookmarks.t array;
	cursor				:Cursor.t;
	bookmark_section	:Dom_html.element Js.t
}

let () =
	let callback tree =
		let t =
			let tree = Array.get (Js.to_array tree) 0 in
			let tree = Js.Optdef.get (tree##children) (fun () -> assert false) in
			let tree = Array.map (Bookmarks.from_chrome_tree) (Js.to_array tree) in

			let bookmark_section =
				Js.Opt.get (Dom_html.CoerceTo.div (Dom_html.getElementById "bookmark_section"))
					(fun () -> assert false)
			in

			Array.iter (Bookmarks.put_folder_view bookmark_section) tree;

			{
				bookmarks = tree;
				cursor = Cursor.zero;
				bookmark_section = bookmark_section
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

			| Search_input s	->
				Js_utils.log (Js.string (String.concat "" ["SEARCH: "; s]));
				t

		))

	in
	Chrome_bookmarks.getTree callback;

	let on_keydown e =
		if e##keyCode >< (37, 40) then
			(Observable.notify arrow_key_observable e##keyCode; Js._false)
		else
			Js._true
	in

	ignore (Dom_html.addEventListener Dom_html.document Dom_html.Event.keydown
			(Dom_html.handler on_keydown) Js._false)
