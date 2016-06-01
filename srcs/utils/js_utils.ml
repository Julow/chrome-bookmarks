(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   js_utils.ml                                        :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/01 19:30:42 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/06/01 19:44:20 by jaguillo         ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* f is a js expression (string) *)
let call f args =
	Js.Unsafe.fun_call (Js.Unsafe.js_expr f) (Array.map Js.Unsafe.inject args)

let log msg =
	ignore (call "console.log" [| msg |])
