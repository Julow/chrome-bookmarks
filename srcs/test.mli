(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   test.mli                                           :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/24 23:49:33 by juloo             #+#    #+#             *)
(*   Updated: 2016/05/24 23:59:31 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module type MAKE_T =
sig
	type t
end

module type TEST =
sig

	(* Type of events *)
	type t

	(* Register a listener *)
	val register : (t -> unit) -> unit

	(* Process an event *)
	val push : t -> unit

end

module Make (T :MAKE_T) :TEST with type t := T.t
