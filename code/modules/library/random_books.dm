/obj/item/weapon/book/manual/random/New()
	var/static/banned_books = list(/obj/item/weapon/book/manual,/obj/item/weapon/book/manual/random,/obj/item/weapon/book/manual/nuclear,/obj/item/weapon/book/manual/wiki)
	var/newtype = pick(typesof(/obj/item/weapon/book/manual) - banned_books)
	new newtype(loc)
	qdel(src)

/obj/structure/bookcase/random
	var/category = null
	var/book_count = 2
	anchored = 1
	state = 2
/obj/structure/bookcase/random/New()
	..()
	if(ticker && ticker.current_state >= GAME_STATE_PLAYING)
		initialize()

/obj/structure/bookcase/random/initialize()
	if(!book_count || !isnum(book_count))
		update_icon()
		return
	if(!establish_db_connection())
		if(prob(5))
			var/obj/item/weapon/paper/P = new(get_turf(loc))
			P.info = "There once was a book from Nantucket<br>But the database failed us, so f*$! it.<br>I tried to be good to you<br>Now this is an I.O.U<br>If you're feeling entitled, well, stuff it!<br><br><font color='gray'>~</font>"
		update_icon()
		return
	if(category && prob(25)) category = null
	book_count += pick(-1,-1,0,1,1)
	if(book_count <= 0)
		update_icon()
		return

	var/c = category? " AND category='[sanitizeSQL(category)]'" :""
	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM [format_table_name("library")] WHERE isnull(deleted)[c] GROUP BY title ORDER BY rand() LIMIT [book_count];") // isdeleted copyright (c) not me
	if(query.Execute())
		while(query.NextRow())
			var/obj/item/weapon/book/B = new(src)
			B.author	=	query.item[2]
			B.title		=	query.item[3]
			B.dat		=	query.item[4]
			B.name		=	"Book: [B.title]"
			B.icon_state=	"book[rand(1,7)]"
	else
		log_game("SQL ERROR populating library bookshelf.  Category: \[[category]\], Count: [book_count], Error: \[[query.ErrorMsg()]\]\n")
	update_icon()

/obj/structure/bookcase/random/fiction
	name = "bookcase (Fiction)"
	category = "Fiction"
/obj/structure/bookcase/random/nonfiction
	name = "bookcase (Non-Fiction)"
	category = "Non-fiction"
/obj/structure/bookcase/random/religion
	name = "bookcase (Religion)"
	category = "Religion"
/obj/structure/bookcase/random/adult
	name = "bookcase (Adult)"
	category = "Adult"

/obj/structure/bookcase/random/reference
	name = "bookcase (Reference)"
	category = "Reference"
	var/ref_book_prob = 20
/obj/structure/bookcase/random/reference/initialize()
	while(book_count > 0 && prob(ref_book_prob))
		book_count--
		new /obj/item/weapon/book/manual/random(src)
	..()
