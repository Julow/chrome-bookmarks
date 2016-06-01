(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/24 19:10:12 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/06/01 23:57:36 by juloo            ###   ########.fr       *)
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
			Array.map iter (Js.to_array tree)
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

			| Arrow_key (k)		->
				let focus_next d =
					set_focused (Bookmarks.next_open bookmarks !focused d)
				in

				let focus_childs () =
					let childs = (!focused).Bookmarks.childs in
					Bookmarks.set_opened !focused true;
					if (Array.length childs) > 0 then
						set_focused (Js_dict.fget bookmarks (Array.get childs 0))
					else
						()
				in

				let focus_parent () =
					if (!focused).Bookmarks.opened then
						Bookmarks.set_opened !focused false
					else
						match (!focused).Bookmarks.parent_id with
						| None				-> ()
						| Some parent_id	->
							set_focused (Js_dict.fget bookmarks parent_id)
				in

				begin match k with
					| 40			-> focus_next 1
					| 38			-> focus_next (-1)
					| 37			-> focus_parent ()
					| 39			-> focus_childs ()
					| _				-> Js_utils.log k; assert false
				end

			| Search_input (s)	->
				Js_utils.log (Js.string (String.concat "" ["SEARCH: "; s]))
		);

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
