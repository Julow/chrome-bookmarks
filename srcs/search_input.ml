(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   search_input.ml                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/27 18:01:04 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/05/27 19:25:52 by jaguillo         ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let element = Js.Opt.get (Dom_html.CoerceTo.input (Dom_html.getElementById "search_input"))
		(fun () -> assert false)
let log s = Js.Unsafe.fun_call (Js.Unsafe.js_expr "console.log") [| Js.Unsafe.inject s |]

let search_observer = Observable.create ()

let on_search _ =
	Observable.notify search_observer (Js.to_string (element##value));
	Js._false

let put c =
	element##value <- element##value##concat (Js.string (String.make 1 c));
	ignore (on_search ())

let del () =
	if (element##value##length) > 0 then
		element##value <- element##value##slice (0, (element##value##length - 1))
	else ()

let () =
	ignore (Dom_html.addEventListener element Dom_html.Event.input
			(Dom_html.handler on_search) Js._false)
