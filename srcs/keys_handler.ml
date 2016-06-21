(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   keys_handler.ml                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/21 23:04:58 by juloo             #+#    #+#             *)
(*   Updated: 2016/06/21 23:19:17 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

exception Unused_binding

let shift =	1 lsl 0
let ctrl =	1 lsl 1
let meta =	1 lsl 2
let alt =	1 lsl 3

let modifiers e =
	let m m b = if Js.to_bool b then m else 0 in
	m shift	e##.shiftKey lor
	m ctrl	e##.ctrlKey lor
	m meta	e##.metaKey lor
	m alt	e##.altKey

(* Ignore current event *)
(* (must be called from the handler) *)
let unused () = raise Unused_binding

(* Create an observable that map 'handler' with keydown events on 'dom_element' *)
let observe dom_element handler =
	let dst = Observable.create () in
	let keydown_handler e =
		try
			Observable.notify dst (handler e);
			Js._false
		with Unused_binding ->
			Js._true
	in
	Dom_html.addEventListener dom_element Dom_html.Event.keydown
		(Dom_html.handler keydown_handler) Js._false |> ignore;
	dst
