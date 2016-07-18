(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   js_utils.ml                                        :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/01 19:30:42 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/07/19 00:27:12 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* f is a js expression (string) *)
let call f args =
	Js.Unsafe.fun_call (Js.Unsafe.js_expr f) (Array.map Js.Unsafe.inject args)

let log msg =
	ignore (Js.Unsafe.fun_call (Js.Unsafe.js_expr "console.log")
		[| Js.Unsafe.inject msg |])

let remove_element element =
	Js.Opt.case element##.parentNode
		ignore
		(fun p -> Dom.removeChild p element)
