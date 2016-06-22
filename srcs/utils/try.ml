(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   try.ml                                             :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/06/26 16:42:01 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/06/22 18:23:02 by jaguillo         ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type ('a, 'b) t = Ok of 'a | Error of 'b

let return v = Ok v
let throw v = Error v

let (&&?) v f =
	match v with
	| Ok v				-> f v
	| Error _ as err	-> err

let (||?) v f =
	match v with
	| Ok _ as ok		-> ok
	| Error v			-> f v

let bind f v = v &&? f
let recover f v = v ||? f
