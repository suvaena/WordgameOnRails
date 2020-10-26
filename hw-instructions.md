# WordGame on Rails

This assignment is a reworking of the assignment "Hangperson on Rails" by Armando Fox and contains portions of his code, but the majority of the content is new and written by Mark Smucker, July 2020.  The signficiant difference between the two is that the ESaaS assignment does not show how to create a new rails application and was out of date with current versions of Ruby and Rails.

This assignment was tested using the MSCI-245-S20 stack on Codio.  It works with [Ruby 2.6.6](https://ruby-doc.org/core-2.6.6/) and [Rails 6.0.3.2](https://guides.rubyonrails.org/).

----

## Overview

In this assignment, you will build a working version of your WordGame in Rails.  By using the same game and model from the WordGame assignment, we can better understand how Rails apps work and are built.  The WordGame app is stripped down to make some aspects of the app building process clear.

## Part 1 - A new rails app

Your repo should be named wordgame.

If you do not have a directory named "wordgame", stop!  Go back to the homework instructions and properly clone your repo.

`cd` into your repo directory: `cd wordgame`

There isn't anything in your repo right now except the hw instructions, and the .git directory.

Our first step is to use rails to make you a new app and to get it up and running at the "hello world" level.

Run the following command:

```
rails new . --skip-javascript --skip-test --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-action-cable --skip-active-storage --skip-keeps --skip-spring --skip-sprockets --skip-turbolinks --database=postgresql
```

Before going further, you should add all of this generated content to git, commit it and push it to GitHub for backup:
```
git add --all
git commit -m"ran rails new"
git push
```

The `rails new .` creates your new web app in this directory.  All of the "skip" options are to turn off functionality that we don't need in this app.  The most important ones to turn off are:
+ --skip-test : In general, in MSCI 245 and 342, we will follow ESaaS and use RSpec and Cucumber rather than the Rails unit testing framework.

+ --skip-turbolinks : This is a fancy javascript library to make your app seem to work faster for users, but it can lead to lots of headaches, which we don't need.

The important option we added is to say we will use the Postgresql database:

+ --database=postgresql

The default database for Rails is sqlite, but Heroku uses Postgresql.  We want to have the same database setup in development as we do in the deployed version, and so we also use Postgresql here.

Next, we need to finish setting up the database:
```
rails db:create 
```
You may get a warning about "The dependency tzinfo-data...", and this warning can be safely ignored every time you see it.

And that's it.  We've created a "hello world" rails app.  To verify that it is working, do:
```
rails server -b 0.0.0.0
```
You will see that we are using the Puma webserver and that it is running on port 3000.  

At the top of your Codio window, you will see a dropdown menu titled "Project Index (static)".  Click the white downward pointing arrow and select "Box URL".  You will be transported to a new browser tab and you should see a message telling you that you need to configure Rails to allow your machine to access the site while in development mode.  (Thankfully, Codio's default "Box URL" is also on port 3000.  You should be able to simply click "Box URL" and see what we've created for the remainder of your work on this app.)

To fix this, you need to edit the file `config/environments/development.rb` and add
```ruby
  # NOTE: needs to be custom set for each Codio box.
  # CHANGE yourCodio-hostName to the two word identifier for your
  # codio box!!!
  config.hosts << "yourCodio-hostName-3000.codio.io"  
```
after "Rails.application.configure do". So, we get:
```ruby
Rails.application.configure do
    config.hosts << "yourCodio-hostName-3000.codio.io"  
    # ... lots of other stuff not shown here. Don't mess it up.
end
```
Alright.  Stop the web server (puma).  (Hit CTRL-C a couple of times.)

Restart the web server. (Go look back up there for how to do this.)

Go to your website in a browser tab (https://yourCodio-hostName-3000.codio.io/) and verify Rails is running.  You should see something that now congratulates you on getting Rails running.

## Part 2 - Make the app 

If you haven't done it recently, now is a good time to commit your repo and push to GitHub.  This gives you a backup in case of disaster.

Now, we want to make our WordGame app.  What are the tasks?

Well, we know that Rails apps are based on the MVC pattern (Model, View, Controller), and so it seems pretty sensible to figure out what the model(s), view(s), and controller(s) are going to be.  As you'll see as we go through this, we don't do them separately except for the model.  It works best for us to go back and forth between the controller and the views as we build the app.  This let's us test it as we progress in getting it up and running.  When we do development, we want to follow this process:

1. Write a bit of code or make a small change to the app.

1. Check that the app still works and/or does what we expect the new code to do.  If the app is broken or buggy, work on the app to fix it.  Do not add more functionality or other changes until you are back to a working app.  If the app is working, go to step 1 and add some more code.

It is very important to note that you should have a working rails app at this point.  It isn't the WordGame, but it does work.  If you didn't get it working in Part 1, do not proceed!  

### Generate Controller

The controller mediates between the model and the view.  It handles the actions of the web app, talks with the model, and then renders a view.  In the Sinatra app, our controller was in the app.rb file.  Our goal is to get the same functionality up and running for our Rails app.

In Rails, just like "rails new" generated a whole new app for you, rails will auto-generate a skeleton controller for us.  

When we ask for a new controller, we need to know:

1. name : what do we want it to be named?  Our controller will be the `game` controller.

1. actions : what are the actions of the controller?  We already know from our work in the Sinatra homework that we need to handle these actions: win, lose, show, new, create, guess.

To generate the controller:
```
rails generate controller game win lose show new create guess 
```
This produces the following output:
```
      create  app/controllers/game_controller.rb
       route  get 'game/win'
get 'game/lose'
get 'game/show'
get 'game/new'
get 'game/create'
get 'game/guess'
      invoke  erb
      create    app/views/game
      create    app/views/game/win.html.erb
      create    app/views/game/lose.html.erb
      create    app/views/game/show.html.erb
      create    app/views/game/new.html.erb
      create    app/views/game/create.html.erb
      create    app/views/game/guess.html.erb
      invoke  helper
      create    app/helpers/game_helper.rb
      invoke  assets
      invoke    css
      create      app/assets/stylesheets/game.css
```
This one simple command has done a lot for us:  

1. Each "create" above is a new file that has been created.  The GameController is in the file `app/controllers/game_controller.rb`.  

2. We've created a bunch of new routes: 'game/win' etc.  A route is the path to which GET or POST requests are made.  For example, we will send the user to 'http://hostname/game/win' when they have won the game.  In the Sinatra app, we put all of our routes as /win, /show, etc. 

3. We've made a directory, `app/views/game` to hold our views.  One view per action was automatically created for us.

4. Plus some other stuff, too!

### Routes 

In Rails, routes are stored separately and used to direct requests of the web app to the correct controller.

We can see the routes that rails know about by typing:
```
rails routes
```
we get as output:
```
     Prefix Verb URI Pattern            Controller#Action
   game_win GET  /game/win(.:format)    game#win
  game_lose GET  /game/lose(.:format)   game#lose
  game_show GET  /game/show(.:format)   game#show
   game_new GET  /game/new(.:format)    game#new
game_create GET  /game/create(.:format) game#create
 game_guess GET  /game/guess(.:format)  game#guess
```
The "Prefix" means that Rails will make available in the controller, and the view, special helper methods that will return the path for the route.  For example there will be `game_win_path` and it will return "/game/win".  It is much better practice to call these helper methods rather than type the path directly.

Okay, we issued one command, and it produced a pile of changes.  There is always a good chance we've mucked up our app.  We should see if it is still okay!

If you've shut down the server, bring it back up again (if it is still up, shut it down and restart it):
```
rails server -b 0.0.0.0
```
Now, go to our app in a browser tab (use the Box URL to go to port 3000).  At the root, i.e. '/', we should still get "yay! you're on rails!"

If we go to /new, we get a development error page. The error shows us helper path names that have been created, the HTTP verb and the controller action.  In other words, the web app knows nothing about the route '/new'.  Why should it?  We didn't make a '/new' route.  We made routes like '/game/new'.  Go to to '/game/new'.  (What I mean by this is go to http://codio-host-3000.codio.io/game/new , where you replace codio-host with your box name.)

You should see at 'game/new' a default page.  This is the page at `app/views/game/new.html.erb` that was created for us when we made the controller.  It can be handy to take a look at the file to verify what is going on. 

Back to our routes (see output from rails routes above):

The "Verb" says whether these routes are set up for an http GET or POST.  These are all set up for GET.  We know that we want game_create and game_guess to be POST, because we are going to POST a form to them.  So, we need to change this.  

Open up the file `config/routes.rb` and change "get" to "post" for 'game/create' and 'game/guess'.

Save the file.  Then run `rails routes` to check your changes.   

When we made the sinatra version, going to "/" took us to the new game view.  In rails, to do this we need to add a route for "root", which is another name for "/", i.e. it is the root of the file tree.  So, we want "root" to be handled by the "game#new" controller action.  So, add 
```
root 'game#new' 
```
to the routes.rb file before the other routes.  It is the most popular choice, and should be matched before the others.

Type `rails routes` to see that we didn't botch things  up.  Then go to "/" in your browser to test that our game controller shows the game_new view.  Yes, it does.  (I'm serious.  If you aren't changing -> checking -> fixing -> checking -> etc. you'll make a typo and get lost and have to start over.)

If we go to "/glarp", we get a development error page, which shows us helper path names that have been created, the HTTP verb and the controller action.  In development mode, Rails is helping us understand that we haven't told it how to handle a request to /glarp.  In this case, this is good, for we don't want /glarp to be handled.

### View Layout

If you haven't done it recently, now is a good time to commit your repo and push to GitHub.  This gives you a backup in case of disaster.

Let's make our views look a bit better.

In `app/view/layouts`, there is `application.html.erb`, and this file is the "layout" that is used for all the views. You could also call it the [boilerplate](https://en.wikipedia.org/wiki/Boilerplate_code#HTML) for the website. The `<%= yield %>` inside of the `<body>` tag inserts the given view, e.g. game/new.html.erb, into the layout, which is then sent to the web browser for viewing of the html.

Let's spruce up our application's layout.  Open up `app/view/layouts/application.html.erb` and change its title to:
```
<title>WordGame</title>
```
after `<body>`, add:
```
<h1>Your Name's WordGame</h1>
```
where "Your Name's" is replace with your name, for example "Mark Smucker's". Save these changes, and then go to your browser, refresh the website, and see our changes.

Now, try out /game/show.  

Okay, that's nice.  We at least always know we're playing the WordGame.

### Model and Controller Improvements

Let's work on our model and controller.  No sense to make the views look better until there is some data to show.

First thing is to copy over our word game model from the last homework.

The model for the WordGame is the same as it was in the Sinatra WordGame homework.  Please use my version of the WordGame model so that everything works as tested.

Copy and paste the following into `app/models/word_game.rb`

```ruby
class WordGame

  # Author: Mark Smucker
  # Date: June 2020

  attr_reader :word, :guesses, :wrong_guesses
    
  def initialize(word)
    @word = word.downcase
    @guesses = '' # stores all correct guesses
    @wrong_guesses = '' # stores all incorrect guesses
  end  
  
  # returns true if illegal argument for guess method
  # use this to check argument and avoid exception
  def guess_illegal_argument? letter
    letter == nil || letter.length != 1 || letter =~ /[^a-zA-Z]/
  end
    
  # user guesses this letter
  # return true if not guessed before
  # return false if guessed
  # @guesses is a string holding all unique guesses
  # WordGame is case insensitive, change all guesses to lowercase via downcase
  def guess letter
     if guess_illegal_argument? letter
         raise ArgumentError, 'letter must be a single character a-zA-Z'
     end
      
     letter = letter.downcase
     if @word.include? letter
        if ! @guesses.include? letter 
           @guesses << letter
           return true 
        else
           return false
        end
     else
        if ! @wrong_guesses.include? letter
            @wrong_guesses << letter
            return true
        else
            return false
        end
     end
  end
    
  def check_win_or_lose
      if @wrong_guesses.length >= 7
         return :lose
      elsif word_with_guesses == @word 
         return :win
      else
         return :play
      end
  end
    
  def word_with_guesses
     if @guesses == ''
        return @word.gsub /./, '-'
     else
        return @word.gsub /[^#{@guesses}]/, '-'     
     end
  end

  # Get a word from remote "random word" service
  #     
  # You can test get_random_word by running $ bundle exec irb -I. -r app.rb
  # And then in the irb: irb(main):001:0> WordGame.get_random_word
  #  => "cooking"   <-- some random word
  def self.get_random_word
    require 'uri'
    require 'net/http'
    uri = URI('http://watchout4snakes.com/wo4snakes/Random/RandomWord')
    Net::HTTP.new('watchout4snakes.com').start { |http|
      return http.post(uri, "").body
    }
  end
end
```

By creating word_game.rb, the WordGame class, which is our model, will be available to our game controller.  **The name of the file is very important.**  We use snake_case for the name of the file, which then makes the CamelCase model available to our controller.

To edit out game controller, open up `app/controllers/game_controller.rb` .  Once you have it open, notice that it follows the same convention: snake_case for the file name, and CamelCase for the class name!  In Ruby and Rails, following the conventions saves you lots of time and effort.  If you do not follow the conventions, you have to figure out a lot to set everything up manually yourself.  

We will see that our controller actions: win, lose, etc. are already defined with nothing in their method bodies.  In Rails, the default view to show after running an action is the view with the same name as the action.  Thus, after GameController.win runs, we process the `app/views/game/win.html.erb` view by first processing the layout in `app/views/layouts/application.html.erb`, and when we reach `<%= yield %>`, we 
process `win.html.erb`.

Anyways, let's work on the controller.  The first thing we need to do is to always have our game model available for us.  So, whenever we handle an action in the controller, we need our WordGame object available, and when we are done, we need to save the game state.  Remember that web applications operate by the user's browser making requests to the server. We need to keep track of each user's state for them, and we do that with the `session` hash, which by default is stored in the user's browser via a cookie.

First, let's figure out how to save a game if we have one.  Let's add this method:

```ruby
    def store_game_in_session
    session[:game] = @game.to_yaml
  end    
```

In the above code, assume `@game` will refer to a WordGame object.  To save it as a string, we call to_yaml, which converts it to a ruby string format.  Now that we know how we're storing it, we can write the method to retrieve it.

Add the following to your game controller:

```ruby
  def get_game_from_session
    if !session[:game].blank? 
      @game = YAML.load(session[:game])
    else
      @game = WordGame.new('')
    end
  end
```

This method, checks the session hash for an entry with the key `:game`, and if it exists, it fetches the game and converts the YAML back to a ruby object. Otherwise, it creates a new game.

In Rails controllers, we can set a method to run before every action and a method to run after every action. So, add the following to your game controller:
```ruby
  before_action :get_game_from_session
  after_action :store_game_in_session
```
This is great.  Now we have a game loaded before and saved after all requests.  

Save your controller.  Launch your server and make sure it doesn't burst into flames.  (Translation, your web site should work as before.  If it is now broken, we've done something wrong and you shouldn't proceed until you fix the error.)

Now that we have a controller that has a game object, how do we use it?  Well, for the lose, new, show, and win actions, all we do is show the view, and so there is nothing to add to those methods.

The create and the guess methods need to process data that comes in from the user via POSTs of forms.  But, we cannot write these methods unless we know how we are going to send data to them.  So, let's go back to working on the views.

### Creating FORMs

If you haven't done it recently, now is a good time to commit your repo and push to GitHub.  This gives you a backup in case of disaster.

Let's work on the 'new' view.  To edit it, open up `app/views/game/new.html.erb` .

Delete what is in the file now.

We want a nice button to click on and request a new game.  We need to POST our request to the create path so that the game controller's create action can process the request and make a new game with a new word.

So, we need a form.  In Rails, we need to use the tools Rails provides for creating forms, or we'll have problems.  We do **not** hack out our own html forms.  By using the Rails tools, we gain all sorts of security protections that Rails has already figured out.

To create a form, we use the following code:
```
<%= form_with( url: game_create_path, local: true) do |form| %>
<!-- Insert into here the form buttons, etc.  We'll get to these in a moment. -->
<% end %>
```
The `<%= %>` tags run some ruby code and print out the value returned.  The code we're running here is the "form_with" method.  We're passing it a value for the  parameter "url:", and the value is "game_create_path".  What is this `game_create_path`?  Remember when we run `rails routes` it shows us that each route has a "Prefix", and this "Prefix" is added to "_path" to give us a handy way of referring to the path to the route.  Super handy.  The `local: true` option disables use of AJAX for submitting the form.

To make the submit button, we use this Rails code:
```
<%= submit_tag 'New Game' %>
```
Putting together, you should have this in your new.html.erb file
```
<%= form_with( url: game_create_path, local: true) do |form| %>
<%= submit_tag 'New Game' %>
<% end %>
```
The `<% %>` tag without the equals sign, just lets us have ruby code without any ouput, and that is why the "end" statement is inside <% %>.

To test that we didn't botch this operation, start up your web server if it isn't running and go to /game/new .

To see what Rails is doing, right click on your web browser and select "view source", and you will then get to see how all of this code turns into some nifty HTML for us.

If you click on "New Game", you end up at the create view.  

Are we supposed to have a create view?  

No. The create path and controller action for create is supposed to create a new game and then redirect us to the show view.  Let's go back to app/controllers/game_controller.rb and fix this.

### Controller Action Handlers

Our create action handler should be:
```ruby
  def create
      word = params[:word] || WordGame.get_random_word
      @game = WordGame.new word
      redirect_to game_show_path 
  end
```

Note how we use the game_show_path to make it easy for us to send the user to the correct path without having to type in the path.  We use the Rails method `redirect_to` handles the redirection to the show path in the web app, and when the user gets there, the game controller's show action handler will be called.

Save the controller file, and go back to the website, and see what happens when we click "New Game".  We should now end up at the show view.  Yay!

What does the `show` controller do?  

All it does is display the 'show' view, and that is done by default, and so we don't need to write anything in the show controller.  

### show view

Okay, let's go work on the show view.  Open up `app/views/game/show.html.erb` .

Delete what is there now.

We need to show the user their wrong guesses, the word with guesses, and a form to submit a new guess.

Let's do these!

```
<p>Wrong guesses: <%= @game.wrong_guesses %></p>
<p>Word so far: <%= @game.word_with_guesses %></p>
<p>
<%= form_with url: game_guess_path do |form| %>
<%= label_tag( :guess, "Guess a letter:" ) %>
<%= text_field_tag( :guess, nil, maxlength: 1 ) %>
<%= submit_tag 'Guess!' %>
<% end %>
</p>
```

You can see that we've introduced two new Rails methods for helping us create a form.  The label_tag and text_field_tag.  You can see all of the helpers here: https://www.rubydoc.info/docs/rails/6.0.2.1/ActionView/Helpers/FormTagHelper . These are directly related to the HTML tags for FORMs: https://www.w3schools.com/html/html_forms.asp

Save the file and take a look in the browser by starting at the root, and then clicking on new game, that then takes us to create, which then takes us to show.  It should all look good before proceeding.  Be sure to right click and "view source" to see how our Rails code is turning into HTML.  You need to learn how to create FORMs, for they are critical to web app development.

In the show view, we'd also like to include a button to create a new game, if the user wants to bail on the current game.  While we could cut and past the form from the 'new' view, that is bad practice. We try to follow DRY: Don't Repeat Yourself.  So, instead we can call `render` to go and run the 'new' view in place by adding the following:
```
<%= render template: 'game/new' %>
```

so that we now have in our show view:
```
<p>Wrong guesses: <%= @game.wrong_guesses %></p>
<p>Word so far: <%= @game.word_with_guesses %></p>
<p>
<%= form_with( url: game_guess_path, local: true) do |form| %>
<%= label_tag( :guess, "Guess a letter:" ) %>
<%= text_field_tag( :guess, nil, maxlength: 1 ) %>
<%= submit_tag 'Guess!' %>
<% end %>
</p>
<%= render template: 'game/new' %>
```

Again, check your work in the browser.  We want to do a little work, and then check.  The sooner we detect we've made a mistake, the easier it is to find and fix the mistake.

### win and lose views

While we're working on views, let's go and fix up the win and lose views.  First in `app/views/game/win.html.erb` :
```
<p>You Win!</p>
<p>The word was "<%= @game.word %>".</p>
<%= render template: 'game/new' %>
```
Remember that this code: 
```
<p>The word was <%= @game.word %>.</p>
```

uses the `<%= %>` tag to run some ruby and print out the value returned.

Then edit `app/views/game/lose.html.erb` :
```
<p>Sorry, you lose!</p>
<p>The word was "<%= @game.word %>".</p>
<%= render template: 'game/new' %>
```

Save the files, and go to /game/win and /game/lose in the browser to see that they display nicely and the new game button works.

Okay, now with the views in pretty good shape, let's get back to the game controller.

### Game Controller: guess action handler 

If you haven't done it recently, now is a good time to commit your repo and push to GitHub.  This gives you a backup in case of disaster.


We need to write the guess method to handle the guesses from the user.

Here is some code that works:
```ruby
  def guess
    letter = params[:guess].to_s[0]
    
    if @game.guess_illegal_argument? letter
        flash[:message] = "Invalid guess."
    elsif ! @game.guess letter # enter the guess here
        flash[:message] = "You have already used that letter."
    end
    
    if @game.check_win_or_lose == :win
        redirect_to game_win_path
    elsif @game.check_win_or_lose == :lose
        redirect_to game_lose_path
    else    
        redirect_to game_show_path
    end
  end    
```
You can see that we make use of the flash hash to store temporary strings for use in the view.

Go back to your browser and see that we're still working.

### show view flash messages

What we haven't done yet is make the show view handle the messages from the flash hash.

So, back to `app/views/game/show.html.erb` , and add at the top of the file:
```
<% if flash[:message] %>
  <p><%= flash[:message] %></p>
<% end %>
```
This is neat code because you can see that we're using ruby (the `if` statement) to control whether or not to produce some html output.

Now, go check the game out again in the browser.  It should be fully functioning!

# Adding Features

If you haven't done it recently, now is a good time to commit your repo and push to GitHub.  This gives you a backup in case of disaster.

Before you are done, we need you to add some further functionality to the game.

## Preventing Cheating

As noted in the last assignment, we want to prevent people from going directly to /game/win or /game/lose .  They should only be at those paths if they have won or lost, respectively.  

Modify your app to prevent this form of cheating.

## Better User Interface

Modify your game so that it tells the user how many guesses they have remaining.  

For example: "You have 7 guesses remaining." Should be displayed when the game starts, and each wrong guess decrements the count by 1.

## Number of Wrong Guesses 

Modify your app so that when a user creates a new game, they also set the number of allowed wrong guesses.  The HTML form should default to 7 wrong guesses, but allow the user to edit this input field and change it to some other value.  If the user inputs a value less than 0, or something other than a number, your app sends them back to /game/new and displays a message that says they must enter a number 0 or larger.  You may not use javascript.

# Submit Your Work

+ Commit your repo and push to GitHub.

+ Create a Heroku app named rails-wordgame-watiamname, where watiamname is your WatIAM user name, and deploy your new game to that app.

+ Edit the README.md file to be:

```
# WordGame on Rails

Author: Your Name

Heroku URL of deployed web app: http://replace-with-your-heroku-app-hostname/

Notes: Any notes to TA or instructor or notes for yourself.
```
Put your name and Heroku URL into the `README.md` file.  

+ Commit your repo and push to GitHub.

+ Verify that when viewing the Readme in GitHub, that it shows your full name and you can click on the Heroku URL and play your game.

Please note that you will not be able to mark your work as completed in Codio.  You submit your work by committing it and pushing it to GitHub and Heroku.  **The time of your last commit in GitHub will be used as the time of submission.**  
