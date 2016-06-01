(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/24 19:10:12 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/05/29 23:49:01 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let log s = Js.Unsafe.fun_call (Js.Unsafe.js_expr "console.log") [| Js.Unsafe.inject s |]

type event_t = Bookmark_click of Js.js_string Js.t | Arrow_key of int | Search_input of string

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
			let iter node =
				Bookmarks.create bookmarks (Dom_html.document##body) node
			in
			Array.map iter (Js.to_array tree)
		in
		let focused = ref None in

		Observable.register root_observable (function
			| Bookmark_click (b)	->
				let b = Js_dict.get bookmarks b in
				Js.Optdef.case b
					(fun () -> assert false)
					(fun b -> Bookmarks.set_opened b (not b.Bookmarks.opened))
			| Arrow_key (k)		->
				(match !focused with
				| None			->
					focused := Some (Js_dict.fget bookmarks (Array.get root_bookmarks 0));
					(!focused).element##classList##add (Js.string "focus")
				| Some b		->
					b.element##classList##remove (Js.string "focus");
					let b = next_open b in
					focused := Some b;
					b.element##classList##add (Js.string "focus")
				)
			| Search_input (s)	->
				log (Js.string (String.concat "" ["SEARCH: "; s]))
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
