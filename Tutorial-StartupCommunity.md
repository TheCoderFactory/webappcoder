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
`<%= render 'layouts/navigation' %>`

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

### Add Gems

Go to _Gemfile_

Add these lines under the gem 'rails' line

```
gem 'simple_form'
gem 'devise'
gem "rolify"
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
Set up CanCan

```
rails g cancan:ability
```

Set up Rolify
```
rails g rolify:role Role User
```

Seed the database *db/seeds.rb*
```
puts 'SETTING UP DEFAULT USER LOGIN'
user = User.create!(:email => 'user@example.com', :password => 'pleaseme', :password_confirmation => 'pleaseme')
puts 'New user created: ' << user.email
user2 = User.create!(:email => 'user2@example.com', :password => 'pleaseme', :password_confirmation => 'pleaseme')
puts 'New user created: ' << user2.email
user.add_role :admin
user2.add_role :user
```
```
rake db:seed
```

Set up FriendlyId
```
$ rails generate friendly_id
````


Scaffold for UserProfile

````
rails g scaffold UserProfile user:references name email phone tagline about:text url blog twitter facebook linkedin google github image slug
````


in *db/migrate/xxx_create_user_profiles.rb*
```
  ...
    end
    add_index :user_profiles, :slug, unique: true
  end
end
````

```
$ rake db:migrate
````


Add the FriendlyId config to UserProfile.

In *app/models/user_profile.rb*
```
class UserProfile < ActiveRecord::Base
  belongs_to :user
  extend FriendlyId
  friendly_id :name, use: :slugged
end
````

Link the User model to the UserProfile with the *has_one* statement.
In *app/models/user.rb*
```
class User < ActiveRecord::Base
  has_one :user_profile
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
```


Edit the controller so that FriendlyId works:

*app/controllers/user_profiles_controller.rb*
```
def set_user_profile
   @user_profile = UserProfile.friendly.find(params[:id])
end
````

Add a "Create your profile" button on the home page. Set it so only people who have signed in and don't have a user profile already can see it.

*app/views/home/index.html.erb*
```
<% if user_signed_in? %>
  <div class="row">
    <div class="col-md-12">
      <% if current_user.user_profile.nil? %>
      <div class="alert alert-warning">
        <%= link_to 'Create your user profile', new_user_profile_path, :class => 'alert-link btn btn-warning' %>
      </div>
      <% end %>
    </div>
  </div>
<% end %>
```

Take out the User field and slug field from the UserProfile form:
*app/views/user_profiles/_form.html.erb*
Remove:
```
  <div class="form-group">
    <%= f.association :user, input_html: { class: "form-control"} %>
  </div>
  ...
    <div class="form-group">
      <%= f.input :slug, input_html: { class: "form-control"} %>
    </div>
```

Add the current user to the UserProfile in *app/controllers/user_profiles_controller.rb*
```
def create
  @user_profile = UserProfile.new(user_profile_params)
  @user_profile.user_id = current_user.id

  ....
```

Log in to the site and create a user profile for your user.


Do the same for BusinessProfile. Here is a scaffold you can use:

```
rails g scaffold BusinessProfile name email phone tagline about:text url blog twitter facebook linkedin google github image slug employees:integer hiring:boolean latitude:float longitude:float owner:integer
```
```
rails g model UserBusinessProfile user:references business_profile:references
```

in *db/migrate/xxx_create_business_profiles.rb*
```
  ...
    end
    add_index :business_profiles, :slug, unique: true
  end
end
````
In *app/models/business_profiles.rb*
```
class BusinessProfile < ActiveRecord::Base
  has_many :user_business_profiles
  has_many :users, through: :user_business_profiles
  extend FriendlyId
  friendly_id :name, use: :slugged
end
````

In *app/models/user.rb*
```
class User < ActiveRecord::Base
  rolify
  has_one :user_profile
  has_many :user_business_profiles
  has_many :business_profiles, through: :user_business_profiles
  ...
```

*app/models/user_business_profiles.rb* will already look like this:
```
class UserBusinessProfile < ActiveRecord::Base
  belongs_to :user
  belongs_to :business_profile
end
```


*app/controllers/business_profiles_controller.rb*
```
def set_user_profile
   @business_profile = BusinessProfile.friendly.find(params[:id])
end
````
Add User Profiles, Business Profiles and My Profile links to the navigation bar.
*app/views/layouts/_navigation.html.erb*
```
<div class="header">
  <div class="container">
    <h1>The Startup Community</h1>
    <ul class="nav nav-pills pull-right">
      <li class="active"><a href="#">Home</a></li>
      <li><%= link_to "User Profiles", user_profiles_path %></li>
      <li><%= link_to "Business Profiles", business_profiles_path %></li>
      <li><%= link_to "My Profile", user_profile_path(current_user.user_profile) %></li>
      <% if user_signed_in? %>
          <li>
            <%= link_to destroy_user_session_path, :method=>'delete' do %>
              <i class="icon-sign-out"></i> Logout
            <% end %>
          </li>
          <li>
            <%= link_to edit_user_registration_path do %>
              <i class="icon-user"></i> My account
            <% end %>
          </li>
          
        <% else %>
          <li>
            <%= link_to 'Login', new_user_session_path %>
          </li>
          <li>
            <%= link_to 'Sign up', new_user_registration_path %>
          </li>
        <% end %>
    </ul>
  </div>
</div>
```
On the My Profile page we will add buttons to Add a Business Profile (only show the button if it is the current user's profile page).

```
<% if user_signed_in? %>
  <% if current_page?(user_profile_path(current_user.user_profile)) %>
    <%= link_to "Create your business profile", new_business_profile_path, class: 'btn btn-lg btn-warning' %>
  <% end %>
<% end %>
```

Now we will modify the business profile form and controller to add the current user as the owner and an associated user.
Go to *apps/views/business_profiles/_form.html.erb*
Remove the fields for *slug, longitude, latitude, owner*.

Add the following to lines to the *create* method of *apps/controllers/business_profiles_controller.rb*
```
@business_profile.owner = current_user.id
@business_profile.users << current_user
```
Add a business profile using the form.

On the Business Profile show page we will display a list of the users who are associated with the business (they work there).

*app/views/business_profiles/show.html.erb*
```
<h3>Associated users:</h3>
<% if @business_profile.users %>
  <ul>
    <% @business_profile.users.each do |user| %>
      <li><%= link_to user.user_profile.name, user_profile_path(user.user_profile) %></li>
    <% end %>
  </ul>
<% end %>
```

We will also display the owners name instead of their ID number.
*app/controllers/business_profiles_controller.rb*
```
def show
  @owner = User.find(@business_profile.owner)
end
```

*app/views/business_profiles/show.html.erb*
```
<p>
  <strong>Owner:</strong>
  <%= @owner.user_profile.name %>
</p>
```

Now we will make buttons that allow other people to associate themselves with a business profile.

First we will create a button to Leave the business. We add logic to only show the button if the user is signed in and is already associated with the business.

*app/views/business_profiles/show.html.erb*
```
<% if user_signed_in? %>
  <% if current_user.business_profiles.include?(@business_profile) %>
    <%= link_to "Leave this business", leave_business_profile_path, class: 'btn btn-danger' %>
  <% end %>
<% end %>
```

We now add the route for *leave_business_profile_path*

In *config/routes.rb* change the business profiles resource to look like this:
```
resources :business_profiles do
  member do
    get :leave
  end
end
```

Do a rake routes in your terminal to see this new line:
```
leave_business_profile GET    /business_profiles/:id/leave(.:format) business_profiles#leave
```

Now we need to add a *leave* method to the Business profile controller:
*app/controllers/business_profiles_controller.rb*
```
def leave
  @business_profile = BusinessProfile.find(params[:id])
  current_user.business_profiles.delete(@business_profile)
  redirect_to @business_profile
end
```

This method gets the business profile that the "Leave" button was pressed on. Then deletes that business from the user's list of associated business profiles. Then redirects the user back to the business profile page.


Now let's do a Join button.

Add the *else* clause and the new Join button in *app/views/business_profiles/show.html.erb*
```
<% if user_signed_in? %>
  <% if current_user.business_profiles.include?(@business_profile) %>
    <%= link_to "Leave this business", leave_business_profile_path, class: 'btn btn-danger' %>
  <% else %>
    <%= link_to "Join this business", join_business_profile_path, class: 'btn btn-success' %>
  <% end %>
<% end %>
```

Add the join route to *config/routes.rb*
```
resources :business_profiles do
  member do
    get :leave
    get :join
  end
end
```

Add the Join method to *app/controllers/business_profiles_controller.rb*
```
def join
  @business_profile = BusinessProfile.find(params[:id])
  current_user.business_profiles << @business_profile
  redirect_to @business_profile
end
```

Your users can now create, join and leave business_profiles. 




