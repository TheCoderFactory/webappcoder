Rails environment setup (including RVM)
Sublime setup


```
rails new TheStartupCommunity
```

`cd TheStartupCommunity`

`rails s`

In your browser visit `localhost:3000`

`rails g controller home index`

Open the app files in sublime: `subl .`

Go to *config/routes.rb* and delete all but first and last lines. Add `root 'home#index'`.

Looks like:

````
TheStartupCommunity::Application.routes.draw do
  root 'home#index'
end
````

Refresh your browser. See the home page displayed.

##Add Bootstrap

Add bootstrap.css to *app/assets/stylesheets* and bootstrap.min.js to *app/assets/javascripts*.

Refresh browser.

Go to *app/views/layouts/application.html.erb*

Find the yield tag and enclose it with a DIV tag with the *container* class:

```
<div class="container">
	<%= yield %>
</div>
````

Refresh your browser.

Add a line above the yield tag:
`<%= render 'layouts/navigation'>`

Cmd + N
Cmd + S

Save as *_navigation.html.erb*

Paste in:
```
<nav class="navbar navbar-default" role="navigation">
	<%= link_to "The Startup Community", root_path, :class => 'navbar-brand' %>
    <ul class="nav navbar-nav">
    </ul>
</nav>
````

Save the file and refresh your browser.

Go to *app/assets/stylesheets/application.css*

After the last line of text, add:
```
body {padding-top: 50px;}
````

## Add Users

Go to _Gemfile_

Add these lines under the gem 'rails' line

```
gem 'simple_form'
gem 'devise'
gem 'cancan'
gem 'friendly_id', '~> 5.0.0'
````

Go to your terminal and run `bundle`

Restart server

Set up Simple Form

```
rails generate simple_form:install --bootstrap
````

Set up Devise

```
rails generate devise:install
````

```
rails generate devise User
````

Set up FriendlyId
```
rails generate friendly_id
````

```
rake db:migrate
````

Restart server.

Refresh browser

````
rails g scaffold PersonProfile user:references name email phone tagline about:text url blog twitter facebook linkedin google github image slug
````



