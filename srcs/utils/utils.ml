(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   utils.ml                                           :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/07/18 23:42:50 by juloo             #+#    #+#             *)
(*   Updated: 2016/07/18 23:42:56 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module StringMap = Hashtbl.Make (struct
	type t = string
	let equal a b = String.compare a b = 0
	let hash = Hashtbl.hash
end)
