(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/24 19:10:12 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/06/03 11:38:33 by jaguillo         ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type event_t =
	Bookmark_click of Js.js_string Js.t |
	Arrow_key of int |
	Search_input of string

let (><) a (min, max) = a >= min && a <= max

let arrow_key_observable = Observable.create ()

let root_observable = Observable.join [
	Observable.map arrow_key_observable (fun k -> Arrow_key k);
	Observable.map Bookmarks.on_click_observable (fun id -> Bookmark_click id);
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

let () =
	let bookmarks = Js_dict.create () in

	let callback tree =
		let root_bookmarks =
			let bookmark_section =
				Js.Opt.get (Dom_html.CoerceTo.div (Dom_html.getElementById "bookmark_section"))
					(fun () -> assert false)
			in
			let iter node =
				Bookmarks.create bookmarks bookmark_section node
			in
			let root = Array.get (Js.to_array tree) 0 in
			Js.Optdef.case (root##children)
				(fun () -> [||])
				(fun c -> Array.map iter (Js.to_array c))
			(* Array.map iter (Js.to_array tree) *)
		in

		let next_open b dir =
			let siblings =
				match b.Bookmarks.parent_id with
				| None			-> root_bookmarks
				| Some parent	->
					let parent = Js_dict.fget bookmarks parent in
					parent.Bookmarks.childs
			in
			let c_index = array_find siblings ((=) b.Bookmarks.id) in
			let c_index =
				let c_count = Array.length siblings in
				(c_index + dir + c_count) mod c_count
			in
			Js_dict.fget bookmarks siblings.(c_index)
		in

		let focused = ref (Js_dict.fget bookmarks (Array.get root_bookmarks 0)) in

		let set_focused b =
			(!focused).Bookmarks.element##classList##remove (Js.string "focus");
			focused := b;
			b.Bookmarks.element##classList##add (Js.string "focus")
		in
		set_focused !focused;

		Observable.register root_observable (function
			| Bookmark_click (b)	->
				let b = Js_dict.get bookmarks b in
				Js.Optdef.case b
					(fun () -> assert false)
					(fun b -> Bookmarks.set_opened b (not b.Bookmarks.opened))

			| Arrow_key (40)	->
				set_focused (next_open !focused 1)
			| Arrow_key (38)	->
				set_focused (next_open !focused (-1))

			| Arrow_key (37)	->
				if (!focused).Bookmarks.opened then
					Bookmarks.set_opened !focused false
				else
					begin match (!focused).Bookmarks.parent_id with
					| None				-> ()
					| Some parent_id	->
						set_focused (Js_dict.fget bookmarks parent_id)
					end

			| Arrow_key (39)	->
				let childs = (!focused).Bookmarks.childs in
				Bookmarks.set_opened !focused true;
				if (Array.length childs) > 0 then
					set_focused (Js_dict.fget bookmarks (Array.get childs 0))
				else
					()

			| Arrow_key (_)		-> assert false

			| Search_input (s)	->
				Js_utils.log (Js.string (String.concat "" ["SEARCH: "; s]))
		)

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
