require 'sqlite3'

#Skapar databasen

def get_db()
    db = SQLite3::Database.new('db/library.db')
    db.results_as_hash = true
    return db
end

#Räknar upp alla böcker från book tabellen

def get_all_books()
    db = get_db()
    return db.execute("SELECT * FROM books")
end

#Skapar användare i user tabellen

def create_user(username,password_digest)
    db = get_db()
    db.execute('INSERT INTO users (username,pwdigest) VALUES (?,?)',[username,password_digest])
end

#Skapar specifika användare

def get_user_by_username(username)
    db = get_db()
    return db.execute("SELECT * FROM users WHERE username = ?",username).first
end

#Lägger till böcker i loan tabellen 

def create_user_book(bookid, id)
    db = get_db()
    db.execute("INSERT INTO loan (bookid, userid) VALUES (?, ?)", [bookid, id])
end

#Räknar upp användares böcker

def get_user_books(id)
    db = get_db()
    return db.execute("SELECT * FROM books WHERE id IN (SELECT bookid FROM loan WHERE userid = ?)", id)
end

#Tar bort användres böcker från loan tabellen

def delete_user_book(id, bookid)
    db = get_db()
    db.execute("DELETE FROM loan WHERE userid = ? and bookid = ?", [id, bookid])
end

#Tar bort böcker från public biblioteket

def delete_book(bookid)
    db = get_db()
    db.execute("DELETE FROM Books WHERE id = ?", [bookid]) 
end