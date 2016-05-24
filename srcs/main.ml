(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/24 19:10:12 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/05/25 00:10:02 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let log s = Js.Unsafe.fun_call (Js.Unsafe.js_expr "console.log") [| Js.Unsafe.inject s |]

module TestTest = Test.Make (struct type t = int end)

let () =

	TestTest.register (fun event ->
			(* Main loop *)
			log event
		);

	(* Register to async callbacks *)

	(* Test *)
	TestTest.push 4;
	TestTest.push 5;
	TestTest.push 1;
	TestTest.push 9;

	();

	let callback tree = ignore (Bookmarks.create_map (Dom_html.document##body) tree) in
	Chrome_bookmarks.getTree callback
