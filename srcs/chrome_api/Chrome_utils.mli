(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Chrome_utils.mli                                   :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/07/18 14:04:13 by jaguillo          #+#    #+#             *)
(*   Updated: 2016/07/18 14:24:16 by jaguillo         ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

class type ['callback] event_listener = object

	method addListener	:'callback -> unit Js.meth

end

type 'a event_listener_prop = 'a event_listener Js.t Js.readonly_prop

