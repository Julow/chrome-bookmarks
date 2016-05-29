(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   bookmarks.ml                                       :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/24 12:30:10 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/05/29 23:52:55 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type t = {

	mutable opened	:bool;
	id				:Js.js_string Js.t;
	parent_id		:Js.js_string Js.t option;

	element			:Dom_html.element Js.t;

	childs			:Js.js_string Js.t array

}

let on_click_observable = Observable.create ()

let rec create dict parent_element node =
	let element =
		let div = Dom_html.createDiv Dom_html.document in
		let a = Dom_html.createA Dom_html.document in
		let on_click _ = Observable.notify on_click_observable node##id; Js._false in
		a##textContent <- (Js.some node##title);
		Js.Optdef.case (node##url) (fun _ -> ()) (fun url -> a##href <- url);
		a##classList##add (Js.string "bookmark_label");
		Dom.appendChild div a;
		Dom.appendChild parent_element div;
		if Js.Optdef.test (node##url) then
			div##classList##add (Js.string "bookmark")
		else (
			div##classList##add (Js.string "bookmark_folder");
			ignore (Dom_html.addEventListener a Dom_html.Event.click
						(Dom_html.handler on_click) Js._false)
		);
		div
	in

	Js_dict.put dict (node##id) {
		opened = false;
		id = node##id;
		parent_id = Js.Optdef.to_option node##parentId;
		element = element;
		childs = Js.Optdef.case (node##children)
			(fun () -> [||])
			(fun c -> Array.map (create dict element) (Js.to_array c))
	};
	node##id

let set_opened b v =
	let open_class = Js.string "open" in
	b.opened <- v;
	if v then
		b.element##classList##add (open_class)
	else
		b.element##classList##remove (open_class)

let next_open dict id =
	None

let prev_open dict id =
	None
