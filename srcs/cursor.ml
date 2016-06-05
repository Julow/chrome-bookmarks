(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   cursor.ml                                          :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/05 21:10:12 by juloo             #+#    #+#             *)
(*   Updated: 2016/06/05 21:18:24 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type t = Node of int * t | Leaf of int

let zero = Leaf 0

let select_next bookmarks cursor dir =
	let rec loop bookmarks = function
		| Node (index, next)	->
			begin match bookmarks.(index) with
			| Bookmarks.Folder f	->
				Node (index, loop f.Bookmarks.childs next)
			| Bookmarks.Leaf _		->
				assert false
			end
		| Leaf index			->
			let index =
				let len = Array.length bookmarks in
				(index + dir + len) mod len
			in
			(Bookmarks.title bookmarks.(index))##focus ();
			Leaf index
	in
	loop bookmarks cursor

let rec select_parent bookmarks = function
	| Node (index, next)	->
		begin match next with
		| Node _		->
			begin match bookmarks.(index) with
			| Bookmarks.Folder f	->
				Node (index, select_parent f.Bookmarks.childs next)
			| Bookmarks.Leaf _		->
				assert false
			end
		| Leaf _		->
			let b = bookmarks.(index) in
			begin match b with
			| Bookmarks.Folder f	-> Bookmarks.set_opened f false
			| Bookmarks.Leaf _		-> assert false
			end;
			(Bookmarks.title b)##focus ();
			Leaf index
		end
	| Leaf _ as l			-> l

let rec select_child bookmarks = function
	| Node (index, next)	->
		begin match bookmarks.(index) with
		| Bookmarks.Folder f	->
			Node (index, select_child f.Bookmarks.childs next)
		| Bookmarks.Leaf _		->
			assert false
		end
	| Leaf index as prev	->
		begin match bookmarks.(index) with
		| Bookmarks.Folder f
				when (Array.length f.Bookmarks.childs) > 0	->
			Bookmarks.set_opened f true;
			(Bookmarks.title f.Bookmarks.childs.(0))##focus ();
			Node (index, Leaf 0)
		| _													->
			prev
		end
