(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/24 19:10:12 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/05/25 20:05:10 by jaguillo         ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let log s = Js.Unsafe.fun_call (Js.Unsafe.js_expr "console.log") [| Js.Unsafe.inject s |]

module KeyboardReceiver = Receiver.Make (struct type t = unit end)

type receiver_t = Bookmark_click of Bookmarks.OnClickReceiver.t | Keyboard_event

module RootReceiver = Receiver.Join (Bookmarks.OnClickReceiver) (KeyboardReceiver)
	(struct
		type t = receiver_t
		let left v = Bookmark_click v
		let right () = Keyboard_event
	end)

let () =
	let bookmarks = Js_dict.create () in

	RootReceiver.bind (function
		| Bookmark_click (b)	->
			let b = Js_dict.get bookmarks b in
			Js.Optdef.case b
				(fun () -> assert false)
				(fun b -> Bookmarks.set_opened b (not b.Bookmarks.opened))
		| Keyboard_event		->
			log (Js.string "KEYBOARD")
	);

	let callback tree =
		let iter node =
			ignore (Bookmarks.create bookmarks (Dom_html.document##body) node)
		in
		Array.iter iter (Js.to_array tree)
	in
	Chrome_bookmarks.getTree callback;

	ignore (Dom_html.addEventListener Dom_html.document (Dom_html.Event.keypress)
		(Dom_html.handler (fun _ -> KeyboardReceiver.transmit (); Js._false)) Js._false)
