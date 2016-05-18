(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   test.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/15 16:08:02 by juloo             #+#    #+#             *)
(*   Updated: 2016/05/19 00:19:59 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

class bookmark = fun tree_node node childs ->
object

	val tree_node = tree_node
	val node = node
	val childs = childs

end

let createBookmarkElement title url =
	let div = Dom_html.createDiv Dom_html.document in
	let title = Dom_html.createA Dom_html.document in
	let onClick _ =
		if Js.to_bool (div##classList##contains (Js.string "open")) then
			div##classList##remove (Js.string "open")
		else
			div##classList##add (Js.string "open");
		Js._false
	in
	title##textContent <- (Js.some title);
	Js.Optdef.case url (fun _ -> ()) (fun url -> title##href <- url);
	title##classList##add (Js.string "bookmark_label");
	ignore (Dom_html.addEventListener title Dom_html.Event.click (Dom_html.handler onClick) Js._false);
	Dom.appendChild div title;
	div##classList##add (Js.string (if Js.Optdef.test url then "bookmark" else "bookmark_folder"));
	div

let buildBookmarks tree =
	let rec buildChilds bookmarks parent =
		let buildNode b =
			let element = createBookmarkElement b##title b##url in
			Dom.appendChild parent element;
			new bookmark b##title element (Js.Optdef.case (b##children)
					(fun _ -> [||])
					(fun childs -> buildChilds childs element))
		in
		Array.map buildNode (Js.to_array bookmarks)
	in
	buildChilds tree Dom_html.document##body

let () = Chrome_bookmarks.getTree (fun tree -> ignore (buildBookmarks tree))
