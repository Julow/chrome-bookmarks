(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   test.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/24 23:49:37 by juloo             #+#    #+#             *)
(*   Updated: 2016/05/25 00:07:00 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module type MAKE_T =
sig
	type t
end

module type TEST =
sig
	type t
	val register : (t -> unit) -> unit
	val push : t -> unit
end

module Make (T :MAKE_T) =
struct

	let listeners = ref []

	let register l = listeners := l :: !listeners

	let push event =
		let rec iter = function
			| l :: tail		-> l event; iter tail
			| []			-> ()
		in
		iter !listeners

end
