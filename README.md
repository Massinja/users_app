# Welcome to My Users App

## Objective
Build an app according to Model-View-Controller architecture using Ruby.    
Practice writing own classes.  
Work with Database and learn how to avoid SQL injections.  
Build routes with Sinatra.  
Use session & cookies for "signed in" methods.
Send and receive some data from the server with curl.  

## Description
### **Part I: Model**

There are two classes User and Dbconnect to manipulate user's data and store it in sqlite database.

### **Part II: Controller**
The application is running on puma server using Sinatra to create calls to methods like get, post, put, and delete.

The routes are:
* GET on /. Responds with HTML. Returns all users.
* GET on /users. Returns all users.
* POST on /users. Receives firstname, lastname, age, password and email. Creates a user, stores it in the database and returns the user created.
* POST on /sign_in. Receives email and password. Adds a session containing the user_id in order to be logged in and returns the user created.
* PUT on /users. This action require a user to be logged in. It will receive a new password and will update it. It returns the user created.
* DELETE on /sign_out. This action requires a user to be logged in. Signs out the current user. Returns nothing (code 204 in HTTP).
* DELETE on /users. This action requires a user to be logged in. Signs out and destroys the current user. Returns nothing (code 204 in HTTP).

### **Part III: View**
ERB template was used in order to return HTML. 

## Installation
To install dependencies specified in the Gemfile run command:
```
bundle install  
```
To start running this application:
```
ruby app.rb -s Puma
```
## Usage
Open a second terminal window (in the first terminal you are already running the app(server)) and start interacting with the server using curl. 

**Create User**: curl -X POST -i http://localhost:8080/users -d "firstname=value1" -d "lastname=value2" -d "age=value3" -d "email=value4" -d "password=value5"

**Get all Users**: curl -i http://localhost:8080/users

**Sign In**: curl -c cookie.txt -b cookie.txt -X POST -i http://localhost:8080/sign_in -d "email=value4" -d "password=value5"

**Sign Out**: curl -c cookie.txt -b cookie.txt -X DELETE -i http://localhost:8080/sign_out

**Update Password**: curl -c cookie.txt -b cookie.txt -X PUT -i http://localhost:8080/users -d "password=value5"

**Delete current user and logout**: curl -c cookie.txt -b cookie.txt -X DELETE -i http://localhost:8080/users

**Access index view**: curl http://localhost:8080/ (Or visit the page in browser)

-i, --include is optional. It will include protocol response headers in the output
