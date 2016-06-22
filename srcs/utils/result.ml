(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   result.ml                                          :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/22 22:12:16 by juloo             #+#    #+#             *)
(*   Updated: 2016/06/22 22:47:51 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Type = struct

	type ('a, 'b) result = Ok of 'a | Error of 'b

	let (&&?) v f =
		match v with
		| Ok v				-> f v
		| Error _ as err	-> err

	let (||?) v f =
		match v with
		| Ok _ as ok		-> ok
		| Error v			-> f v

end

open Type

let ok v = Ok v
let error v = Error v

let bind f v = v &&? f
let recover f v = v ||? f

let get err_f = function Ok v -> v | Error v -> err_f v

let ignore_err v = v ||? fun _ -> Error ()

let of_bool b = if b then Ok () else Error ()
let of_option = function Some v -> Ok v | None -> Error ()
