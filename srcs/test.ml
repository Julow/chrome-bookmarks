(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   test.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/15 16:08:02 by juloo             #+#    #+#             *)
(*   Updated: 2016/05/16 23:19:42 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let rec buildBookmarks bookmark =
	let recChilds e childs =
		Array.iter (fun c -> Dom.appendChild e (buildBookmarks c)) childs;
		e
	in
	let div = Dom_html.createDiv (Dom_html.document) in
	let title = Dom_html.createP (Dom_html.document) in
	Dom.appendChild div title;
	title##textContent <- (Js.some bookmark##title);
	recChilds (div :> Dom.node Js.t) (Js.to_array bookmark##children)

let callback tree =
	Js.Unsafe.fun_call (Js.Unsafe.js_expr "console.log")
		[| (Js.Unsafe.inject (Array.map buildBookmarks (Js.to_array tree))) |];
	()

let () =
	Chrome_bookmarks.getTree
		callback;
	print_endline "lolmdr"
