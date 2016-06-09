(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   string_score.ml                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/09 19:01:21 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/06/09 19:26:42 by jaguillo         ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* TODO: improve *)

let match_case_value = 10
let match_value = 8
let unmatch_value = -1
let trailing_value = -10
let combo_inc = 10

let score pattern str =
	let s_len = String.length str in
	let p_len = String.length pattern in
	let rec loop i j combo score =
		if j >= p_len then
			score
		else if i >= s_len then
			score + ((p_len - j) * trailing_value)
		else
			let next = loop (i + 1) (j + 1) (combo + combo_inc) in
			let v a b =
				if a = b then
					next match_case_value
				else if (Char.lowercase a) = (Char.lowercase b) then
					next match_value
				else
					loop (i + 1) j 1 (score + unmatch_value)
			in
			v str.[i] pattern.[j]
	in
	loop 0 0 1 0
