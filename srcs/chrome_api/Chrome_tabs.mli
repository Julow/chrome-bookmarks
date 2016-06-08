(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Chrome_tabs.mli                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/07 22:56:36 by juloo             #+#    #+#             *)
(*   Updated: 2016/06/08 22:58:21 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type muted_info_reason = Js.js_string

class type muted_info = object

	method muted		:bool Js.t Js.readonly_prop
	method reason		:muted_info_reason Js.t Js.readonly_prop
	method extensionId	:Js.js_string Js.t Js.optdef Js.readonly_prop

end

class type tab = object

	method id			:int Js.optdef Js.readonly_prop

	method index		:int Js.readonly_prop
	method windowId		:int Js.readonly_prop
	method openerTabId	:int Js.optdef Js.readonly_prop

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
	method width		:int Js.optdef Js.readonly_prop
	method height		:int Js.optdef Js.readonly_prop
	method sessionId	:Js.js_string Js.t Js.optdef Js.readonly_prop

	method mutedInfo	:muted_info Js.t Js.optdef Js.readonly_prop

end

type zoom_settings_mode = Js.js_string
type zoom_settings_scope = Js.js_string

class type zoom_settings = object

	method mode			:zoom_settings_mode Js.t Js.optdef Js.readonly_prop
	method scope		:zoom_settings_scope Js.t Js.optdef Js.readonly_prop
	method defaultZoomFactor	:Js.number Js.t Js.optdef Js.readonly_prop

end

(* properties/query objects are not typed *)
class type t = object

	method get				:int -> (tab Js.t -> unit) -> unit Js.meth
	method getCurrent		:(tab Js.t -> unit) -> unit Js.meth

	method getSelected_current	:(tab Js.t -> unit) -> unit Js.meth
	method getSelected		:int -> (tab Js.t -> unit) -> unit Js.meth
	method getAllInWindow_current	:(tab Js.t Js.js_array Js.t -> unit) -> unit Js.meth
	method getAllInWindow	:int -> (tab Js.t Js.js_array Js.t -> unit) -> unit Js.meth

	method duplicate		:int -> (tab Js.t Js.optdef -> unit) -> unit Js.meth

	method create			:< .. > Js.t -> (tab Js.t -> unit) -> unit Js.meth
	method query			:< .. > Js.t -> (tab Js.t Js.js_array Js.t -> unit) -> unit Js.meth

	method update_current	:< .. > Js.t -> (tab Js.t Js.optdef -> unit) -> unit Js.meth
	method update			:int -> < .. > Js.t -> (tab Js.t Js.optdef -> unit) -> unit Js.meth

	method move_array		:int Js.js_array Js.t -> < .. > Js.t -> (tab Js.t Js.js_array Js.t -> unit) -> unit Js.meth
	method move				:int -> < .. > Js.t -> (tab Js.t -> unit) -> unit Js.meth

	method reload_current	:< .. > Js.t -> (unit -> unit) -> unit Js.meth
	method reload			:int -> < .. > Js.t -> (unit -> unit) -> unit Js.meth

	method remove_array		:int Js.js_array Js.t -> (unit -> unit) -> unit Js.meth
	method remove			:int -> (unit -> unit) -> unit Js.meth

	method detectLanguage_current	:(Js.js_string Js.t -> unit) -> unit Js.meth
	method detectLanguage	:int -> (Js.js_string Js.t -> unit) -> unit Js.meth

	method captureVisibleTab_current	:< .. > Js.t -> (Js.js_string Js.t -> unit) -> unit Js.meth
	method captureVisibleTab	:int -> < .. > Js.t -> (Js.js_string Js.t -> unit) -> unit Js.meth

	method executeScript_current	:< .. > Js.t -> (Js.Unsafe.any Js.js_array Js.t -> unit) -> unit Js.meth
	method executeScript	:int -> < .. > Js.t -> (Js.Unsafe.any Js.js_array Js.t -> unit) -> unit Js.meth

	method insertCSS_current	:< .. > Js.t -> (unit -> unit) -> unit Js.meth
	method insertCSS		:int -> < .. > Js.t -> (unit -> unit) -> unit Js.meth

	method setZoom_current	:Js.number Js.t -> (unit -> unit) -> unit Js.meth
	method setZoom			:int -> Js.number Js.t -> (unit -> unit) -> unit Js.meth
	method getZoom_current	:(Js.number Js.t -> unit) -> unit Js.meth
	method getZoom			:int -> (Js.number Js.t -> unit) -> unit Js.meth

	(* TODO: connect *)
	(* TODO: sendRequest *)
	(* TODO: sendMessage *)

	(* TODO: highlight callback *)
	method highlight		:< .. > Js.t -> unit Js.meth

	method setZoomSettings_current	:zoom_settings Js.t -> (unit -> unit) -> unit Js.meth
	method setZoomSettings	:int -> zoom_settings Js.t -> (unit -> unit) -> unit Js.meth
	method getZoomSettings_current	:(zoom_settings Js.t -> unit) -> unit Js.meth
	method getZoomSettings	:int -> (zoom_settings Js.t -> unit) -> unit Js.meth

	(* TODO: onCreated *)
	(* TODO: onUpdated *)
	(* TODO: onMoved *)
	(* TODO: onSelectionChanged *)
	(* TODO: onActiveChanged *)
	(* TODO: onActivated *)
	(* TODO: onHighlightChanged *)
	(* TODO: onHighlighted *)
	(* TODO: onDetached *)
	(* TODO: onAttached *)
	(* TODO: onRemoved *)
	(* TODO: onReplaced *)
	(* TODO: onZoomChange *)

end
