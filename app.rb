require 'slim'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/flash'

require_relative 'model/model.rb'
also_reload 'model/model.rb'



enable :sessions




db = SQLite3::Database.new('db/library.db')
db.results_as_hash = true
id = 0


# Shows the home page with a welcome message and a button to go to the different pages

get('/') do
  slim(:home)
end

# Shows the home page with a welcome message and a button to go to the different pages

get('/home') do
    slim (:home)
end

# Shows the books page with all the books in the database
#Also displays a different view for admin users and normal users.


get('/books') do   

    @result = get_all_books()

    puts "session id"
    puts session[:id]

    localId = session[:id]

    puts id

    if localId == 11 then
      localId = 11
    else
      localId = 0
    end

    slim (:"books/index"),locals:{id:localId}

end



#@param [String] title, The title of the book
#@param [String] author, The author of the book
#@param [String] year, The year of the book

#Error message if the title, author or year is empty or if the year is not a number or if the year is not between 0 and 2023 or if the year is not an intager or if the title or author is too long or too short or if the title or author contains multiple spaces or if the author contains numbers.

#@see Model#get_all_books

post ('/addbook') do

  title = params[:title]
  author = params[:author]
  year = params[:year]
  books = get_all_books().last
  bookid = books["id"]
  bookid += 1


  if title.empty? || author.empty? || year.empty?
    flash[:index_error] = "Du måste fylla i alla fält."
    redirect('/books')
  end

  if year.to_i.to_s != year 
    flash[:index_error] = "Året får bara innehålla siffror."
    redirect('/books')
  end

  if year.to_i < 0 || year.to_i > 2023
    flash[:index_error] = "Året måste vara mellan 0 och 2023."
    redirect('/books')
  end

  if title.length > 40 || author.length > 40
    flash[:index_error] = "Titeln eller författaren är för lång."
    redirect('/books')
  end

  if title.length < 2 || author.length < 4
    flash[:index_error] = "Titeln eller författaren är för kort."
    redirect('/books')
  end

  if author.include?("1") || author.include?("2") || author.include?("3") || author.include?("4") || author.include?("5") || author.include?("6") || author.include?("7") || author.include?("8") || author.include?("9")
    flash[:index_error] = "Författaren får inte innehålla siffror."
    redirect('/books')
  end

  if author.include?("  ") || title.include?("  ")
    flash[:index_error] = "Titeln eller författaren får inte innehålla flera mellanslag."
    redirect('/books')
  end


  db.execute("INSERT INTO Books (id, title, author, year) VALUES (?, ?, ?, ?)", [bookid, title, author, year])


  redirect('/books')

end

#Post route for registering a new user. Connected to a submit button in the register.slim page.

post('/register') do
    slim(:register)
end

#Håller koll på logik för om användare kan registrera sig
#Skapar en ny användare
#Sparar användarnamn och password_digest i users tabellen i databasen

#Error message if the username or password is empty or if the login credentials are incorrect. This means that the user is not in the database or that the password is incorrect.
#Also checks if the username already exists in the database , if the two passwords match and if the password is less than 4 characters long.

#@param [String] username, The username of the user
#@param [String] password, The password of the user
#@param [String] password_confirm, The password confirmation of the user

#@see Model#create_user
#@see Model#select_username

post('/users') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]


    users = select_username(username)
    


    if username.empty? || password.empty? || password_confirm.empty?
        flash[:login_error] = "Du måste fylla i alla fält."
        redirect('/showlogin')
    end

    if password.length < 4
      flash[:login_error] = "Lösenordet måste vara minst 4 tecken långt."
      redirect('/showlogin')
    end
    
    if users.include?(username) 
        flash[:login_error] = "Användarnamnet existerar redan."
        redirect('/showlogin')
    else
      if (password == password_confirm)
    
        password_digest = BCrypt::Password.create(password)
        create_user(username,password_digest)
        redirect('/')
    
      else
        flash[:login_error] = "Du måste ha samma lösenord."
        redirect('/showlogin')
      end
    end
end

#Shows the login page for the user to login, logout or register
  
get('/showlogin') do
    slim(:login)
end

#Post route for logging in a user. Checks the username and password against the database and if they match, it sets the session id and username.


#Error message if the username or password is empty or if the login credentials are incorrect. This means that the user is not in the database or that the password is incorrect.


#@param [String] username, The username of the user
#@param [String] password, The password of the user

#@see Model#get_user_by_username
  
post('/login') do
    username = params[:username]
    password = params[:password]

    if username.empty? || password.empty?
      flash[:login_error] = "Du måste fylla i alla fält."
      redirect('/showlogin')
    end

    user = get_user_by_username(username)
    pwdigest = user["pwdigest"]
    id = user["id"]


    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id
      session[:username] = username
      redirect('/showlogin')
    else
      flash[:login_error] = "Fel Inloggningsuppgifter."
      redirect('/showlogin')
    end
  
end

#Post route for logging out a user

#Checks if the user is logged in and if not, redirects to the login page with an error message
#If the user is logged in, it clears the session and redirects to the login page with a logout message

#Error message if the user is not logged in, or if the user is already logged out and trying to push the logout button again.


post('/logout') do

  if session[:id] == nil
    flash[:login_error] = "Du är inte inloggad."
    redirect('/showlogin')
  else

    session[:id] = nil
    session[:username] = nil
    flash[:login_error] = "Du har loggat ut."
    redirect('/showlogin')
  end

end

#Post route for loaning a book. Connected to a submit button in the books.slim page. 

#Error message if the user is not logged in or if the book is already loaned by the same user

#@param [String] bookid, The id of the book to be loaned
#@param [String] username, The username of the user who is loaning the book	
#@param [String] password, The password of the user who is loaning the book

#@see Model#create_user_book
#@see Model#select_bookid
#@see Model#get_user_by_username

post('/loan') do
  owners = select_bookid(session[:id])
  book_ids = owners.map { |book| book["bookid"] }
  value = params[:bookid].to_i

  id = session[:id]
  puts id
  puts (id == nil)

  if (id == nil)
    flash[:index_error] = "Du måste vara inloggad för att låna böcker."
    redirect('/books')
  end


  if !book_ids.include?(value)


    username = params[:username]
    password = params[:password]
    bookid = params[:bookid]
    userinfo = get_user_by_username(username)


    if (id > 0) 
      create_user_book(bookid, id)    
    end

    redirect('/books')

  else
    flash[:index_error] = "Du har redan lånat boken."
    redirect('/books')
  end

end


#Post route for editing a book in the admin view
#Checks if the user is logged in and if not, redirects to the login page with an error message
#If the user is logged in, it updates the book title in the database and redirects to the books page

#Error message if the title is empty or too long or if it contains multiple spaces, or if it is too long. 


#@param [String] bookid, The id of the book to be edited
#@param [String] title, The new title of the book

#@see Model#update_book_title

post('/adminedit') do

  puts "admin edit"
  puts params[:bookid]
  puts params[:title]

  if params[:title].empty?
    flash[:index_error] = "Du måste fylla i alla fält."
    redirect('/books')
  end

  if params[:title].length > 40
    flash[:index_error] = "Titeln är för lång."
    redirect('/books')
  end

  if params[:title].include?("  ")
    flash[:index_error] = "Titeln får inte innehålla flera mellanslag." 
    redirect('/books')
  end

  
  update_book_title(params[:title], params[:bookid])


  redirect('/books')

end





#Checks if the user is logged in before accessing the library page

#Error message if the user is not logged in

before ('/library') do
  if session[:username] == nil
    flash[:home_error] = "Du måste vara inloggad för att kunna se dina böcker."
    redirect('/home')
  end
end


#Get route for the library page
#Shows all the books that different users have loaned.

#see Model#get_all_loans_with_users

get('/library') do
    name = session[:username]
    currentUserId = session[:id]
    userloans = get_all_loans_with_users()
    slim :library, locals:{userloans:userloans, currentUserId:currentUserId}
end

#Creates all users and opens the slimp page users.slim


get('/users') do

  users = get_all_users()
  slim :users, locals:{users:users}

end

#Post route for deleting a book from the user's library
#Checks if the user is logged in to the correct acount, and if not, redirects to the login page with an error message
#If the user is logged in, it deletes the book from the user's library and redirects to the library page


#@param [String] bookId, The id of the book to be deleted

#@see Model#delete_user_book
#@see Model#select_userid

post('/delete') do

  bookId = params[:bookId].to_i

  userId = session[:id]

  owners = select_userid(bookId)

  puts "bookId param (to_i): #{bookId}"
  puts "userId from session: #{userId}"



  if owners.any?{ |hash| hash["userid"] == userId } 
    delete_user_book(userId, bookId)  
    redirect('/library')
  else
    flash[:library_error] = "Du äger inte denna boken."
    redirect('/library')
  end
end


#Post route for deleting a book from the database. Only accessible by admin users.

#@param [String] bookid, The id of the book to be deleted

#@see Model#delete_book

post('/bookdelete') do

  puts "userid"
  puts "#{session[:id]}"
  puts "bookid"
  puts "#{params[:bookid]}"

  delete_book(params[:bookid])


  redirect('/books')

end

#Post route for deleting a user from the database. Only accessible by admin users.
#Checks if the user is logged in and if not, redirects to the login page with an error message
#If the user is logged in, it deletes the user from the database and redirects to the users page

#Checks if the user is an admin and if not, redirects to the users page with an error message
#If the user is an admin and tries to delete themselves, redirects to the users page with an error message

#@param [String] bookid, The id of the book to be deleted

#@param [String] userid, The id of the user to be deleted

#@see Model#delete_user


post ('/userdelete') do
  puts "userid"
  puts "#{params[:userid]}"

  if session[:id] == 11

    userid = params[:userid].to_i

    if session[:id] != userid

      delete_user(userid)
      redirect('/users')
    else
      flash[:user_error] = "Du kan inte ta bort dig själv."
      redirect('/users')
    end
  else
    flash[:user_error] = "Du är inte admin."
    redirect('/users')
  end

end