(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Chrome_bookmarks.mli                               :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/15 16:08:09 by juloo             #+#    #+#             *)
(*   Updated: 2016/05/15 16:08:10 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

class type tree_node = object

	method id			:string Js.readonly_prop
	method parentId		:string Js.readonly_prop
	method index		:int Js.readonly_prop
	method url			:string Js.readonly_prop
	method title		:string Js.readonly_prop
	method dateAdded	:float Js.readonly_prop
	method dateGroupModified	:float Js.readonly_prop
	method children		:tree_node Js.js_array Js.readonly_prop

end

val getTree : (tree_node array -> unit) -> unit
