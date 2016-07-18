(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Chrome_bookmarks.mli                               :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/15 16:08:09 by juloo             #+#    #+#             *)
(*   Updated: 2016/07/18 14:35:29 by jaguillo         ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type tree_node_unmodifiable = Js.js_string

class type tree_node = object

	method id			:Js.js_string Js.t Js.readonly_prop
	method parentId		:Js.js_string Js.t Js.optdef Js.readonly_prop
	method index		:int Js.optdef Js.readonly_prop
	method url			:Js.js_string Js.t Js.optdef Js.readonly_prop
	method title		:Js.js_string Js.t Js.readonly_prop
	method dateAdded	:Js.number Js.t Js.readonly_prop
	method dateGroupModified	:Js.number Js.t Js.optdef Js.readonly_prop
	method unmodifiable	:tree_node_unmodifiable Js.t Js.optdef Js.readonly_prop
	method children		:tree_node Js.t Js.js_array Js.t Js.optdef Js.readonly_prop

end

type tree_node_callback = tree_node Js.t -> unit
type tree_node_array_callback = tree_node Js.t Js.js_array Js.t -> unit

class type remove_info = object

	method parentId		:Js.js_string Js.t Js.readonly_prop
	method index		:int Js.readonly_prop
	method node			:tree_node Js.t Js.readonly_prop

end

class type change_info = object

	method title		:Js.js_string Js.t Js.readonly_prop
	method url			:Js.js_string Js.t Js.optdef Js.readonly_prop

end

class type move_info = object

	method parentId		:Js.js_string Js.t Js.readonly_prop
	method index		:int Js.readonly_prop
	method oldParentId	:Js.js_string Js.t Js.readonly_prop
	method oldIndex		:int Js.readonly_prop

end

class type reorder_info = object

	method childIds		:Js.js_string Js.t Js.js_array Js.t Js.readonly_prop

end

class type t = object

	method get			:Js.js_string Js.t -> tree_node_array_callback -> unit Js.meth
	method get_list		:Js.js_string Js.t Js.js_array Js.t -> tree_node_array_callback -> unit Js.meth

	method getTree		:tree_node_array_callback -> unit Js.meth
	method getSubTree	:Js.js_string Js.t -> tree_node_array_callback -> unit Js.meth
	method getChildren	:Js.js_string Js.t -> tree_node_array_callback -> unit Js.meth
	method getRecent	:int -> tree_node_array_callback -> unit Js.meth

	method search		:< .. > Js.t -> tree_node_array_callback -> unit Js.meth

	method create		:< .. > Js.t -> tree_node_callback -> unit Js.meth

	method move			:Js.js_string Js.t -> < .. > Js.t -> tree_node_callback -> unit Js.meth
	method update		:Js.js_string Js.t -> < .. > Js.t -> tree_node_callback -> unit Js.meth

	method remove		:Js.js_string Js.t -> unit Js.meth
	method removeTree	:Js.js_string Js.t -> unit Js.meth
	method remove_callback		:Js.js_string Js.t -> (unit -> unit) -> unit Js.meth
	method removeTree_callback	:Js.js_string Js.t -> (unit -> unit) -> unit Js.meth

	method onCreated	:(Js.js_string Js.t -> tree_node Js.t -> unit) Chrome_utils.event_listener_prop

	method onRemoved	:(Js.js_string Js.t -> remove_info Js.t -> unit) Chrome_utils.event_listener_prop
	method onChanged	:(Js.js_string Js.t -> change_info Js.t -> unit) Chrome_utils.event_listener_prop
	method onMoved		:(Js.js_string Js.t -> move_info Js.t -> unit) Chrome_utils.event_listener_prop
	method onChildrenReordered	:(Js.js_string Js.t -> reorder_info Js.t -> unit) Chrome_utils.event_listener_prop

	method onImportBegan		:(unit -> unit) Chrome_utils.event_listener_prop
	method onImportEnded		:(unit -> unit) Chrome_utils.event_listener_prop

end
