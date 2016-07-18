(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   cursor.ml                                          :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/05 21:10:12 by juloo             #+#    #+#             *)
(*   Updated: 2016/07/18 23:59:50 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type t = Node of int * t | Leaf of int

let zero = Leaf 0

let rec get bookmarks = function
	| Node (index, next)	->
		begin match Bookmark.data bookmarks.(index) with
		| Bookmark.Folder f		-> get f.Bookmark.childs next
		| Bookmark.Leaf _		-> assert false
		end
	| Leaf index			-> bookmarks.(index)

let select_next dir bookmarks cursor =
	let rec loop bookmarks = function
		| Node (index, next)	->
			begin match Bookmark.data bookmarks.(index) with
			| Bookmark.Folder f	->
				Node (index, loop f.Bookmark.childs next)
			| Bookmark.Leaf _		->
				assert false
			end
		| Leaf index			->
			let index =
				let len = Array.length bookmarks in
				(index + dir + len) mod len
			in
			(Bookmark.title_element bookmarks.(index))##focus;
			Leaf index
	in
	loop bookmarks cursor

let rec select_parent bookmarks = function
	| Node (index, next)	->
		begin match next with
		| Node _		->
			begin match Bookmark.data bookmarks.(index) with
			| Bookmark.Folder f	->
				Node (index, select_parent f.Bookmark.childs next)
			| Bookmark.Leaf _	->
				assert false
			end
		| Leaf _		->
			let b = bookmarks.(index) in
			begin match Bookmark.data b with
			| Bookmark.Folder _		-> Bookmark.set_opened b false
			| Bookmark.Leaf _		-> assert false
			end;
			(Bookmark.title_element b)##focus;
			Leaf index
		end
	| Leaf _ as l			-> l

let rec select_child bookmarks = function
	| Node (index, next)	->
		begin match Bookmark.data bookmarks.(index) with
		| Bookmark.Folder f	->
			Node (index, select_child f.Bookmark.childs next)
		| Bookmark.Leaf _		->
			assert false
		end
	| Leaf index as prev	->
		let b = bookmarks.(index) in
		begin match Bookmark.data b with
		| Bookmark.Folder f
				when (Array.length f.Bookmark.childs) > 0	->
			Bookmark.set_opened b true;
			(Bookmark.title_element f.Bookmark.childs.(0))##focus;
			Node (index, Leaf 0)
		| _													->
			prev
		end
