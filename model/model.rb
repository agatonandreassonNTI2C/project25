require 'sqlite3'

#Creates a new SQLite3 database connection and sets the results to be returned as hashes
#This is a helper method to avoid repeating the same code in multiple places

def get_db()
    db = SQLite3::Database.new('db/library.db')
    db.results_as_hash = true
    return db
end

#Selects usernames from the users table and returns them as an array of hashes

def select_username(username)
    db = get_db()
    db.execute("SELECT username FROM users").map { |row| row["username"] } 
end

#Selects userid from the loan table according to the bookid

def select_userid(bookId)
    db = get_db()
    db.execute("SELECT userid FROM loan WHERE bookid=?", bookId)
end

#Selects bookid from the loan table according to the userid

def select_bookid(id)
    db = get_db()
    db.execute("SELECT bookid FROM loan WHERE userid=?",id)
end

#Selects all users from the users table and returns them as an array of hashes. Returns all columns from the users table

def get_all_users()
    db = get_db()
    db.execute("SELECT * FROM Users")
end

#Selects title, author, year, and id from the books table and select, username and id from the users table. The it joins the two tables and returns those variables.

def get_all_loans_with_users
    db = get_db()
    db.execute("SELECT Books.title, Books.author, Books.year, Books.id AS bookid, Users.username, Users.id AS userid FROM Loan 
    JOIN Books ON Loan.bookid = Books.id JOIN Users ON Loan.userid = Users.id")
end
  

#Selects all books from the books table and returns them as an array of hashes. Returns all columns from the books table

def get_all_books()
    db = get_db()
    return db.execute("SELECT * FROM books")
end

#creates a new user according to the username and password digest. The password digest is a hashed version of the password.

def create_user(username,password_digest)
    db = get_db()
    db.execute('INSERT INTO users (username,pwdigest) VALUES (?,?)',[username,password_digest])
end

#Updates a book title i the Books table according to the bookid. The bookid is the id of the book that is being updated.

def update_book_title(title, bookid)

    db = get_db()

    db.execute("UPDATE Books SET title=? Where id =?", [title, bookid])

end

#Selects * from user table from a specific username.

def get_user_by_username(username)
    db = get_db()
    return db.execute("SELECT * FROM users WHERE username = ?",username).first
end

#LCreates a user book which inserts the bookid and userid into the loan table. The loan table is a joint table between the users and books tables.

def create_user_book(bookid, id)
    db = get_db()
    db.execute("INSERT INTO loan (bookid, userid) VALUES (?, ?)", [bookid, id])
end

#Selects * from books that the owners of the books have loaned. It selects i from the books table with regard to the loan table.

def get_user_books(id)
    db = get_db()
    return db.execute("SELECT * FROM books WHERE id IN (SELECT bookid FROM loan WHERE userid = ?)", id)
end

#Removes a book from the loan table according to bookid and userid.

def delete_user_book(id, bookid)
    db = get_db()
    db.execute("DELETE FROM loan WHERE userid = ? and bookid = ?", [id, bookid])
end

#Removes a book from the books table according to bookid. The bookid is the id of the book that is being deleted.
def delete_book(bookid)
    db = get_db()
    db.execute("DELETE FROM Books WHERE id = ?", [bookid]) 
end

#Deletes a user and removes it from the users table according to the id. The id is the id of the user that is being deleted.

def delete_user(id)
    db = get_db()
    db.execute("DELETE FROM Users WHERE id = ?", [id]) 
end