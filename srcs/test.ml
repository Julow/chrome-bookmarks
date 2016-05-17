(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   test.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/15 16:08:02 by juloo             #+#    #+#             *)
(*   Updated: 2016/05/18 00:09:55 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let rec buildBookmarks bookmarks parent =
	let iter b =
		let div = Dom_html.createDiv Dom_html.document in
		let title = Dom_html.createP Dom_html.document in
		Dom.appendChild div title;
		title##textContent <- (Js.some b##title);
		let next childs = buildBookmarks childs div in Js.Optdef.iter b##children next;
		Dom.appendChild parent div
	in
	Array.iter iter (Js.to_array bookmarks)

let () =
	let callback tree = buildBookmarks tree Dom_html.document##body in
	Chrome_bookmarks.getTree callback
