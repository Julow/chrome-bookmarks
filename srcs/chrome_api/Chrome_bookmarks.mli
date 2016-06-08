(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Chrome_bookmarks.mli                               :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/15 16:08:09 by juloo             #+#    #+#             *)
(*   Updated: 2016/06/08 00:38:07 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

class type tree_node = object

	method id			:Js.js_string Js.t Js.readonly_prop
	method parentId		:Js.js_string Js.t Js.optdef Js.readonly_prop
	method index		:int Js.optdef Js.readonly_prop
	method url			:Js.js_string Js.t Js.optdef Js.readonly_prop
	method title		:Js.js_string Js.t Js.readonly_prop
	method dateAdded	:Js.number Js.t Js.readonly_prop
	method dateGroupModified	:Js.number Js.t Js.optdef Js.readonly_prop
	method children		:tree_node Js.t Js.js_array Js.t Js.optdef Js.readonly_prop

end

class type t = object

	(* TODO: add missing functions *)

	method getTree		:(tree_node Js.t Js.js_array Js.t -> unit) -> unit Js.meth

end
