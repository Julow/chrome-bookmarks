(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Chrome_tabs.mli                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/07 22:56:36 by juloo             #+#    #+#             *)
(*   Updated: 2016/06/07 23:27:39 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

class type tab = object

	method id			:int Js.t Js.optdef Js.readonly_prop

	method index		:int Js.t Js.readonly_prop
	method windowId		:int Js.t Js.readonly_prop
	method openerTabId	:int Js.t Js.optdef Js.readonly_prop

	method selected		:bool Js.t Js.readonly_prop
	method highlighted	:bool Js.t Js.readonly_prop
	method active		:bool Js.t Js.readonly_prop
	method pinned		:bool Js.t Js.readonly_prop
	method audible		:bool Js.t Js.optdef Js.readonly_prop

	method url			:Js.js_string Js.t Js.optdef Js.readonly_prop
	method title		:Js.js_string Js.t Js.optdef Js.readonly_prop
	method favIconUrl	:Js.js_string Js.t Js.optdef Js.readonly_prop
	method status		:Js.js_string Js.t Js.optdef Js.readonly_prop

	method incognito	:bool Js.t Js.readonly_prop
	method width		:int Js.t Js.optdef Js.readonly_prop
	method height		:int Js.t Js.optdef Js.readonly_prop
	method sessionId	:Js.js_string Js.t Js.optdef Js.readonly_prop

	(* TODO: mutedInfo *)

end

class type t = object

	method get				:int Js.t -> (tab Js.t -> unit) -> unit Js.meth
	method getCurrent		:(tab Js.t -> unit) -> unit Js.meth

	(* TODO: connect *)
	(* TODO: sendRequest *)
	(* TODO: sendMessage *)

	method getSelected		:int Js.t -> (tab Js.t -> unit) -> unit Js.meth
	method getAllInWindow	:int Js.t -> (tab Js.t Js.js_array Js.t -> unit) -> unit Js.meth

	(* TODO: create *)

	method duplicate		:int Js.t -> (tab Js.t -> unit) -> unit Js.meth

	(* TODO: query *)

	(* TODO: highlight *)
	(* TODO: update *)

	(* TODO: move *)
	(* TODO: reload *)

	method remove			:int Js.t -> (unit -> unit) -> unit Js.meth
	(* TODO: remove<array of tab> *)

	method detectLanguage	:int Js.t -> (Js.js_string Js.t -> unit) -> unit Js.meth

	(* TODO: captureVisibleTab *)
	(* TODO: executeScript *)
	(* TODO: insertCSS *)

	method setZoom			:int Js.t -> float Js.t -> (unit -> unit) -> unit Js.meth
	method getZoom			:int Js.t -> (float Js.t -> unit) -> unit Js.meth

	(* TODO: setZoomSettings *)
	(* TODO: getZoomSettings *)

end
