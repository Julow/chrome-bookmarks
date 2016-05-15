(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   test.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/15 16:08:02 by juloo             #+#    #+#             *)
(*   Updated: 2016/05/15 16:08:02 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let callback tree =
	Js.Unsafe.fun_call (Js.Unsafe.js_expr "console.log")
		[| (Js.Unsafe.inject tree) |]

let () =
	Chrome_bookmarks.getTree callback;
	print_endline "lolmdr"
