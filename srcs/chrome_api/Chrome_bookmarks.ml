(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Chrome_bookmarks.ml                                :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/15 16:08:06 by juloo             #+#    #+#             *)
(*   Updated: 2016/05/17 23:46:19 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

class type tree_node = object

	method id			:Js.js_string Js.t Js.readonly_prop
	method parentId		:Js.js_string Js.t Js.optdef Js.readonly_prop
	method index		:int Js.t Js.optdef Js.readonly_prop
	method url			:Js.js_string Js.t Js.optdef Js.readonly_prop
	method title		:Js.js_string Js.t Js.readonly_prop
	method dateAdded	:float Js.t Js.readonly_prop
	method dateGroupModified	:float Js.t Js.optdef Js.readonly_prop
	method children		:tree_node Js.t Js.js_array Js.t Js.optdef Js.readonly_prop

end

let getTree callback =
	Js.Unsafe.fun_call (Js.Unsafe.js_expr "chrome.bookmarks.getTree")
		[| (Js.Unsafe.inject (Js.wrap_callback callback)) |]
