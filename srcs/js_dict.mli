(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   js_dict.mli                                        :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/23 22:15:36 by juloo             #+#    #+#             *)
(*   Updated: 2016/05/23 23:18:09 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type 'a t

val create : unit -> 'a t

val get : 'a t -> Js.js_string Js.t -> 'a Js.Optdef.t
val put : 'a t -> Js.js_string Js.t -> 'a -> unit
val del : 'a t -> Js.js_string Js.t -> unit
val has : 'a t -> Js.js_string Js.t -> bool

val iter : 'a t -> (Js.js_string Js.t -> 'a -> unit) -> unit
