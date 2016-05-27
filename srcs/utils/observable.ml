(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   observable.ml                                      :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/27 10:33:59 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/05/27 17:37:40 by jaguillo         ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type 'a t = {
	mutable listeners : ('a -> unit) list
}

let create () = { listeners = [] }

let register t f = t.listeners <- f :: t.listeners

let notify t v = List.iter (fun f -> f v) t.listeners

let join lst =
	let dst = create () in
	List.iter (fun t -> register t (notify dst)) lst;
	dst

let map t f =
	let dst = create () in
	register t (fun v -> notify dst (f v));
	dst

let filter t f =
	let dst = create () in
	register t (fun v -> if f v then notify dst v else ());
	dst

let split t f =
	let dst_in, dst_out = create (), create () in
	register t (fun v -> notify (if f v then dst_in else dst_out) v);
	dst_in, dst_out

let fold t initial_acc f =
	let dst = create () in
	let acc = ref initial_acc in
	register t (fun v ->
			let v = f !acc v in
			acc := v;
			notify dst v
		);
	dst

let queue t =
	let q = Queue.create () in
	register t (fun v -> Queue.push v q);
	q

let last t def =
	let last = ref def in
	register t (fun v -> last := v);
	last
