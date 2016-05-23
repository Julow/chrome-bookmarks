(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   bookmarks.ml                                       :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/24 12:30:10 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/05/24 19:26:50 by jaguillo         ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type t = {

	mutable opened	:bool;
	id				:Js.js_string Js.t;
	parent_id		:Js.js_string Js.t option;

	element			:Dom_html.element Js.t;

	childs			:Js.js_string Js.t array

}

type map_t = t Js_dict.t

let rec create_bookmark dict parent_element node =
	let element =
		let div = Dom_html.createDiv Dom_html.document in
		let a = Dom_html.createA Dom_html.document in
		let onClick _ = Js._false in
		a##textContent <- (Js.some node##title);
		Js.Optdef.case (node##url) (fun _ -> ()) (fun url -> a##href <- url);
		a##classList##add (Js.string "bookmark_label");
		ignore (Dom_html.addEventListener a Dom_html.Event.click (Dom_html.handler onClick) Js._false);
		Dom.appendChild div a;
		Dom.appendChild parent_element div;
		div##classList##add (Js.string (if Js.Optdef.test (node##url) then "bookmark" else "bookmark_folder"));
		div
	in
	Js_dict.put dict (node##id) {
		opened = false;
		id = node##id;
		parent_id = Js.Optdef.to_option node##parentId;
		element = element;
		childs = Js.Optdef.case (node##children)
			(fun () -> [||])
			(fun c -> Array.map (create_bookmark dict element) (Js.to_array c))
	};
	node##id

let create_map parent_element tree =
	let dict = Js_dict.create () in
	Array.iter (fun node -> ignore (create_bookmark dict parent_element node)) (Js.to_array tree);
	dict
