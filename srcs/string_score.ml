(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   string_score.ml                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/09 19:01:21 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/06/18 02:43:05 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* TODO: improve (bt)
	score "abcd" "abffffffffcffffffffcd" (* 10 *)
	score "abcd" "abfffffffffffffffffcd" (* 15 *)
*)

let max_dist = 5

let score pattern str =
	let str = String.lowercase str in
	let rec loop i offset acc =
		if i >= (String.length pattern) then
			acc
		else
			let pattern = Char.lowercase pattern.[i] in
			let next = String.index_from str offset pattern in
			let acc = acc + (max (offset - next + max_dist) 0) in
			loop (i + 1) (next + 1) acc
	in
	try loop 0 0 0
	with Not_found -> -1
