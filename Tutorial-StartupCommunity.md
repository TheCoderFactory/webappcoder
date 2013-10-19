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
$ rails generate simple_form:install --bootstrap
````

Set up Devise

```
$ rails generate devise:install
$ rails generate devise User
````

Set up FriendlyId
```
$ rails generate friendly_id
````

```
$ rake db:migrate
````

Restart server.

Refresh browser

Scaffold for PersonProfile

````
rails g scaffold UserProfile user:references name email phone tagline about:text url blog twitter facebook linkedin google github image slug
````

Scaffold for BusinessProfile

```
rails g scaffold BusinessProfile user:references name email phone tagline about:text url blog twitter facebook linkedin google github image slug employees:integer hiring:boolean latitude:float longitude:float gmaps:boolean owner:integer
```

in *db/migrate/xxx_create_user_profiles.rb*
```
	...
    end
    add_index :user_profiles, :slug, unique: true
  end
end
````

in *db/migrate/xxx_create_business_profiles.rb*
```
	...
    end
    add_index :business_profiles, :slug, unique: true
  end
end
````


`rake db:migrate`

In *app/models/user_profile.rb*
```
class UserProfile < ActiveRecord::Base
  belongs_to :user
  extend FriendlyId
  friendly_id :name, use: :slugged
end
````

In *app/models/business_profiles.rb*
```
class BusinessProfile < ActiveRecord::Base
  belongs_to :user
  extend FriendlyId
  friendly_id :name, use: :slugged
end
````

Edit the controllers:

*app/controllers/user_profiles_controller.rb*
```
def set_user_profile
   @user_profile = UserProfile.friendly.find(params[:id])
end
````

*app/controllers/business_profiles_controller.rb*
```
def set_user_profile
   @business_profile = BusinessProfile.friendly.find(params[:id])
end
````




