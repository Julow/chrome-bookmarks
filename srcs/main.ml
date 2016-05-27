(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/24 19:10:12 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/05/27 19:24:49 by jaguillo         ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let log s = Js.Unsafe.fun_call (Js.Unsafe.js_expr "console.log") [| Js.Unsafe.inject s |]

type event_t = Bookmark_click of Js.js_string Js.t | Arrow_key of int | Char_key of char | Char_del_key | Search_input of string

let (><) a (min, max) = a >= min && a <= max

let char_key_observable = Observable.create ()
let arrow_key_observable = Observable.create ()

let root_observable = Observable.join [
	Observable.map arrow_key_observable (fun k -> Arrow_key k);
	Observable.map char_key_observable (fun (_, c) -> Char_key c);
	Observable.map Bookmarks.on_click_observable (fun id -> Bookmark_click id);
	Observable.map Search_input.search_observer (fun s -> Search_input s)
]

let () =
	let bookmarks = Js_dict.create () in

	Observable.register root_observable (function
		| Bookmark_click (b)	->
			let b = Js_dict.get bookmarks b in
			Js.Optdef.case b
				(fun () -> assert false)
				(fun b -> Bookmarks.set_opened b (not b.Bookmarks.opened))
		| Arrow_key (k)		->
			log (Js.string "ARROW")
		| Char_key (c)		->
			Search_input.put c
		| Char_del_key		->
			Search_input.del ()
		| Search_input (s)	->
			log (Js.string (String.concat "" ["SEARCH: "; s]))
	);

	let callback tree =
		let iter node =
			ignore (Bookmarks.create bookmarks (Dom_html.document##body) node)
		in
		Array.iter iter (Js.to_array tree)
	in
	Chrome_bookmarks.getTree callback;

	let on_keypress e =
		let c = Js.Optdef.get (e##charCode) (fun () -> 0) in
		Observable.notify char_key_observable (e##keyCode, char_of_int c);
		Js._false
	in

	let on_keydown e =
		if e##keyCode >< (37, 40) then
			(Observable.notify arrow_key_observable e##keyCode; Js._false)
		else
			Js._true
	in

	ignore (Dom_html.addEventListener Dom_html.document Dom_html.Event.keypress
			(Dom_html.handler on_keypress) Js._false);
	ignore (Dom_html.addEventListener Dom_html.document Dom_html.Event.keydown
			(Dom_html.handler on_keydown) Js._false)
