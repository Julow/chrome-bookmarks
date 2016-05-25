(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   receiver.mli                                       :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/24 23:49:33 by juloo             #+#    #+#             *)
(*   Updated: 2016/05/25 17:30:31 by jaguillo         ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module type RECEIVER =
sig

	(* Type of events *)
	type t

	(* Register a listener *)
	val bind : (t -> unit) -> unit

	(* Trigger registred listeners *)
	val transmit : t -> unit

end

module type MAKE_T =
sig
	type t
end

module Make (T :MAKE_T) :RECEIVER with type t = T.t

(* Same interface as RECEIVER *)
(* Join the flow of two receivers into one *)
module type JOIN =
sig
	type t

	include RECEIVER with type t := t
end

module type JOIN_T =
sig

	(* Type of joined event *)
	type t

	(* Internal types, Left.t and Right.t *)
	type _lt
	type _rt

	(* Convertion function left/right event -> joined event *)
	val left : _lt -> t
	val right : _rt -> t

end

module Join (L :RECEIVER) (R :RECEIVER) (T :JOIN_T with type _lt := L.t and type _rt := R.t) :JOIN with type t = T.t
