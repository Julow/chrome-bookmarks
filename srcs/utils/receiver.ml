(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   receiver.ml                                        :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/24 23:49:37 by juloo             #+#    #+#             *)
(*   Updated: 2016/05/25 17:30:28 by jaguillo         ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module type MAKE_T =
sig
	type t
end

module type RECEIVER =
sig
	type t
	val bind : (t -> unit) -> unit
	val transmit : t -> unit
end

module Make (T :MAKE_T) =
struct

	type t = T.t

	let listeners = ref [||]

	let bind l = listeners := Array.append !listeners [| l |]

	(* force type because of destructive type substitution in Join *)
	let transmit (event :t) = Array.iter (fun l -> l event) !listeners

end

(*  *)

module type JOIN_T =
sig
	type t
	type _lt
	type _rt
	val left : _lt -> t
	val right : _rt -> t
end

module type JOIN =
sig
	type t

	include RECEIVER with type t := t
end

module Join (Left :RECEIVER) (Right :RECEIVER) (T :JOIN_T with type _lt := Left.t and type _rt := Right.t) =
struct

	type t = T.t

	include (Make (T) :RECEIVER with type t := t)

	let () =
		Left.bind (fun e -> transmit (T.left e));
		Right.bind (fun e -> transmit (T.right e))

end
