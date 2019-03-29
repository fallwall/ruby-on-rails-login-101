# README

This is a solution for the [Rails from Scratch Lesson / Lab](https://git.generalassemb.ly/wdi-nyc-bananas/rails_from_scratch_101)

# Rails from Scratch 102 - Sessions
Let's take the next step with our blog app and add sessions so that our users can log in and log out and so that we can begin to control what pages users are allowed to see.

## Sessions
When we refer to "sessions" we're talking about Window.sessionStorage. Here's the official definition:

> The sessionStorage property allows you to access a session Storage object for the current origin. sessionStorage is similar to localStorage; the only difference is while data stored in localStorage has no expiration time, data stored in sessionStorage gets cleared when the page session ends. A page session lasts for as long as the browser is open and survives over page reloads and restores. Opening a page in a new tab or window will cause a new session to be initiated with the value of the top-level browsing context, which differs from how session cookies work.

Put simply, we're going to allow a user to log in and temporarily save that user in the browser so that our app knows which user is currently using the app. We'll use the `bcrypt` gem's `authenticate` method to help us out.

First though, we'll need the following:
- routes for our sessions actions
- a `sessions_controller.rb` file
- a view where users can log in

## Sessions Routes
We won't need full CRUD actions for our sessions. Users only need three things: a view with a form where they can log in, an action to create a new login session, and an action to destroy a session (aka log out).

Go to your `routes.rb` file inside your `config` folder and add the following routes:

```
resources :sessions, only: [:create, :new, :destoy]
    get '/logout', to: 'sessions#destroy'
    get '/login', to: 'sessions#new'
    post '/login' => 'sessions#create'
```

Save the file and, in your terminal, run rails routes to see your three new routes. Great work! Now let's create a controller to manage these actions.

## Sessions Controller
We could manually create a `sessions_controller.rb` file; however, let's take a shortcut and let rails generate this for us. In your terminal, enter the following command:

```
rails g controller Sessions new 
```

You'll notice this command is similar to the `rails g` commands we used to make our models. However, there's no migration files that we need to deal with this time.

In fact, if you open your code in your text editor, you'll see a new `sessions_controller.rb` file in your controllers folder AND you'll see a sessions folder in your views. Both of these already have a `new` action ready to go.

The `new` action in your `sessions_controller.rb` will connect to the login page. When a user is on a login page, they don't need access to any User or Post informatin, so your `new` action won't need to assign any instance variables. You can actually just leave it blank.

Instead, the work will happen in our `create` and `destroy` actions. Let's make those. Your code will end up looking like this:

```
class SessionsController < ApplicationController

 def new
 end
 
 def create
  user = User.find_by(name: params[:name])
 
   if user && user.authenticate(params[:password])
    session[:user_id] = user.id
    redirect_to user
   else
    redirect_to ‘/login’
   end
 end
  
 def destroy
  session[:user_id] = nil
  redirect_to ‘/login’
 end
 
end
```

Next, let's navigate over to our `users_controller.rb` file and update the `create` action to ensure that a user is automatically logged in when they create a new account.

```
def create
  @user = User.new(user_params)
  if @user.save
    session[:user_id] = @customer.id
    redirect_to @user
  end
end
```

Great! Now let's create a view where a user can log in.

## Sessions New View
Navigate to the `new.html.erb` file in your `sessions` view folder. Let's make a form where a user can log in. You'll notice that we're using `form_tag` instead of `form_for` here. `form_tag` simply creates a form. `form_for` creates a form for a model object. Since we don't have a sessions model, we don't need the latter. Our form should look like this:

```
<h2>Login</h2>
<%= form_tag ‘/login’, method: :post do %>
 <div>
  <%= text_field_tag :name%>
 </div>
 <div>
  <%= password_field_tag :password %>
 </div>
  <%= submit_tag “Submit” %>
<%end%>
```

Use your `rails s` command in the terminal to run your server and check to make sure your new view is visible. 

Great! Let's add one more cool piece of logic.

## Current User
Navigate to the `application_controller.rb` file in your controllers folder. We're going to add two methods here to help us authenticate users and ensure that they're only seeing pages that they're supposed to see.

```
def current_user 
  @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id] 
end 

helper_method :current_user

def authenticate_user! 
  redirect_to ‘/login’ unless current_user 
end
```
Basically, these methods check whether a user is currently logged in. If they are logged in, we get a handy helper method called `current_user` that we can use to create conditional logic that only displays information if a user is logged in. If the user is not currently logged in, it redirects them to the login page.

Let's put this `current_user` method to use. Go to your `views` folder and open the `application.html.erb` file in the `layouts` folder. This page is essentially our `index.html` page. Inside the `<body>` tag, above the `<%= yield %>`, let's create a header that uses `current_user` to tell us whether or not we are currently logged in.

```
<header>
  <% if current_user %>
    <a href="/logout">Log Out</a>
  <% else %>
    <a href="/login">Log In</a>
  <% end %>
</header>
```

Awesome. Now go ahead and give this log in thing a try!

