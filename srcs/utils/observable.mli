(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   observable.mli                                     :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/05/27 10:33:57 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/05/27 14:34:47 by jaguillo         ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type 'a t

(* Create an observable *)
val create : unit -> 'a t

(* Register a listener *)
val register : 'a t -> ('a -> unit) -> unit

(* Send a value to registred listeners *)
val notify : 'a t -> 'a -> unit

(* Create an observable that repeat events of multiple observables *)
val join : 'a t list -> 'a t

(* Repeat an observable and apply a function to events *)
val translate : 'a t -> ('a -> 'b) -> 'b t

(* Repeat some events of an observable depending on a predicate *)
val filter : 'a t -> ('a -> bool) -> 'a t

(* Like translate with an accumulator *)
val fold : 'a t -> 'b -> ('b -> 'a -> 'b) -> 'b t

(* bonus *)

(* Queue events of an observable *)
val queue : 'a t -> 'a Queue.t

(* Store the value of the last event into a ref *)
val last : 'a t -> 'a -> 'a ref
