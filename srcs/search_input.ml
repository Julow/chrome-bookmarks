(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   search_input.ml                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/27 18:01:04 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/06/08 22:07:03 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let element = Js.Opt.get
		(Dom_html.CoerceTo.input (Dom_html.getElementById "search_input"))
		(fun () -> assert false)

let search_observer = Observable.create ()

let append c =
	let s = (Js.to_string (element##.value)) ^ c in
	Observable.notify search_observer s;
	element##.value := (Js.string s)

let focus () = element##focus

let () =
	let on_search _ =
		Observable.notify search_observer (Js.to_string (element##.value));
		Js._false
	in
	ignore (Dom_html.addEventListener element Dom_html.Event.input
			(Dom_html.handler on_search) Js._false)
