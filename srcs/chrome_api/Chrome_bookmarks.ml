(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Chrome_bookmarks.ml                                :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/15 16:08:06 by juloo             #+#    #+#             *)
(*   Updated: 2016/05/15 16:08:07 by juloo            ###   ########.fr       *)
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
	(* method unmodifiable	:Js.t Js.readonly_prop *)
	method children		:tree_node Js.js_array Js.readonly_prop

end

let getTree callback =
	Js.Unsafe.fun_call (Js.Unsafe.js_expr "chrome.bookmarks.getTree")
		[| (Js.Unsafe.inject (Js.wrap_callback callback)) |]
