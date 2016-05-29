(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   js_dict.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/23 22:10:54 by juloo             #+#    #+#             *)
(*   Updated: 2016/05/29 23:29:55 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type 'a t = Js.Unsafe.any Js.t

let create () = Js.Unsafe.obj [||]

let get = Js.Unsafe.get
let put = Js.Unsafe.set
let del = Js.Unsafe.delete

let fget d k = Js.Optdef.get (get d k) (fun () -> assert false)

let has dict key = Js.Optdef.test (get dict key)

let iter dict f =
	let keys :Js.js_string Js.t Js.js_array Js.t =
		Js.Unsafe.fun_call (Js.Unsafe.js_expr "Object.keys")
			[| Js.Unsafe.inject dict |]
	in
	for i = 0 to keys##length - 1 do
		let k = Js.Unsafe.get keys i in
		f k (get dict k)
	done
