# Autogiftr

This tutorial will help you build the Autogiftr app using RailsComposer.
We will use the [Carrierwave](https://github.com/carrierwaveuploader/carrierwave) gem to upload images for your Gifts and [FriendlyId](https://github.com/norman/friendly_id) for friendly URLs (better SEO).
You will get more practice interacting with Devise (authentication) and CanCan (athorisation).

I won't cover UI possibilities here. I will leave it up to you to style as you like.
Also, we will force the user to sign up before creating recipients/occasions at this stage and we will come back later and add the concept of "guest user".

### Step 1.

Make sure your command line is using the correct RVM.

`rails -v` will tell you if you are using the right version. If it says that Rails is not installed, then enter the RVM command:

```
rvm use ruby-2.0.0-p247@rails4
```

If you get an error that says you need to use `--create` do this:

```
rvm use ruby-2.0.0-p247@rails4 --create
gem install rails --version=4.0.0 --no-docs --no-ri
```


### Step 2. 

Go to the [Rails Composer](http://railsapps.github.io/rails-composer/) app to copy the url you will need to create the app.

Open your command line/terminal, go to your apps folder and create the new app

```
rails new autogiftr -m https://raw.github.com/RailsApps/rails-composer/master/composer.rb
```

Respond to the questions as follows:

1. (3) Build your own application
2. (2) Thin
3. (2) Thin
4. (1) SQLite
5. (1) ERB
6. (1) Test::Unit
7. (1) None
8. (1) None
9. (1) None
10. (2) Twitter Bootstrap
11. (2) Twitter Bootstrap (SASS)
12. (4) Sendgrid
13. (2) Devise
14. (1) Devise with default modules
15. (2) CanCan with Rolify
16. (2) SimpleForm
17. (4) Home Page, User Accounts, Admin Dashboard
18. y (Ban spiders)
19. y (Create a Github repo)
20. n (Don't use application.yml)
21. y (Reduce logs)
22. y (Use better_errors)
23. n (Don't create project specific gemset)

### Step 3.

Now go into the folder that we just created in your command line

```
cd Autogiftr
```

Open the directory in Sublime `subl .`

And test that the app works by running your server `rails s` and opening your browser to [localhost:3000](localhost:3000)

If you get an error, you might need to run `bundle`.

### Step 4.

Let's seed the database with our admin user and roles. Copy the text from the [Gist](https://gist.github.com/pedrogrande/5632376) and paste into (replace all the text) in *db/seeds.rb*

Change the name, email and password if you want.

Then seed the data to the database by typing this command in the terminal (stop the server or open a new tab - you may need to set RVM with the command above in the new tab, and make sure you are in the correct folder *autogiftr*):

```
rake db:seed
```

Test that you can log in as the admin user and that you see the admin menu in the navbar.

### Step 5.

Let's add our scaffolds to our app. Remember we already have the User scaffold from Rails Composer.

We decided on the following:

1. Gift
2. Recipient
3. Occasion

+ A Recipient belongs to User, a User has many Recipients (one to many)
+ An Occasion belongs to Recipient, a Recipient has many Occasions (one to many)
+ A Gift has many occasions, an Occasion has many gifts (many to many)

We create our scaffolds in order so where there is a relationship, we can express it with our commands and not get an error from the database. (eg. create the Recipient scaffold before the Occasion scaffold) If you use `recipient:references` before creating the Recipient table, the database will throw an error.

Create the Recipient scaffold:
```
rails g scaffold Recipient name user:references
```

Create the Occasion scaffold
```
rails g scaffold Occasion title date:date recipient:references
```

Create the Gift scaffold
```
rails g scaffold Gift name description:text price:decimal image
```

Finally we create the **join table** for the many to many relationship between gifts and occasions.
```
rails g model GiftOccasion gift:references occasion:references
```

Now migrate these changes to the database
```
rake db:migrate
```

### Step 6.

Now you will continue to tell your app about the data relationships. We do this in the model files for each object.

*app/models/user.rb*
```
class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :recipients
end
```

*app/models/recipient.rb*
```
class Recipient < ActiveRecord::Base
  belongs_to :user
  has_many :occasions
end
```

*app/models/occasion.rb*
```
class Occasion < ActiveRecord::Base
  belongs_to :recipient
  has_many :gift_occasions
  has_many :gifts, through: :gift_occasions
end
```

*app/models/gift.rb*
```
class Gift < ActiveRecord::Base
	has_many :gift_occasions
	has_many :occasions, through: :gift_occasions
end
```

You can look at *app/models/gift_occasion.rb* and see that it already has the `belongs_to` lines:
```
class GiftOccasion < ActiveRecord::Base
  belongs_to :gift
  belongs_to :occasion
end
```

### Step 7. 

Now might be a good time to commit your work to git and Github.

In your terminal:
```
git add .
git commit -am 'scaffolds and model'
git push origin master
```

### Step 8.

Add a button on the front page that allows the user to choose a Recipient. They need to be signed in to be able to do this.

Go to *app/controllers/recipients_controller.rb* and **add** the following line up the top of the document. Leave everything below the before_action line alone.

```
class RecipientsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_recipient, only: [:show, :edit, :update, :destroy]
  .....
```

The `before_filter :authenticate_user!` line means that the user must sign in before going to any page within that controller's views.

Go to *app/views/home/index.html.erb*

And change the file to read:

```
<h1>AutoGiftr</h1>

<!-- this section shows a list of the current user's recipients if they have any. We use the 'current_user' method given to use by devise to refer to the user using the site. They must be signed in to be a current_user -->
<% if user_signed_in? %>
	<% if current_user.recipients.count > 0 %>
		<p><b>You currently have <%= pluralize(current_user.recipients.count, 'recipient') %></b></p>
		<table class="table">
			<% current_user.recipients.each do |recipient| %>
				<tr>
					<td><%= recipient.name %></td>
				</tr>
			<% end %>
		</table>
	<% end %>
<% end %>

<%= link_to "Add a recipient", new_recipient_path, class: 'btn btn-success' %>
```

If you are logged out when you click on "Add a recipient" button, you will asked to sign in/sign up. When you do so, you will be taken to the New recipient form.

We now need to change the recipient form because we don't give the user the choice of User to attach the recipient to.

Remove the field for User from the form. *app/views/recipients/_form.html.erb* should look like this:
```
<%= simple_form_for(@recipient) do |f| %>
  <%= f.error_notification %>

  <div class="form-inputs">
    <%= f.input :name %>
  </div>

  <div class="form-actions">
    <%= f.button :submit %>
  </div>
<% end %>
```

We do need to attach the recipient to the current user - we do this in the controller.
Find the **create method** in *app/controllers/recipients_controller.rb* and add a line for @recipient.user:
```
  def create
    @recipient = Recipient.new(recipient_params)
    @recipient.user = current_user
    ...
```

Now add a recipient and return to the home page. You should see your recipient listed there.

### Step 9.

Let's create occasions for our recipients.

Change the table in *app/views/home/index.html.erb* to:
```
<table class="table">
	<% current_user.recipients.each do |recipient| %>
		<tr>
			<td><%= recipient.name %></td>
			<td>
				<% if recipient.occasions.count > 0 %>
					<ul>
						<% recipient.occasions.each do |occasion| %>
							<li><%= occasion.title %></li>
						<% end %>
					</ul>
				<% end %>
			</td>
			<td><%= link_to "Add occasion", new_occasion_path, class: 'btn btn-success' %></td>

		</tr>
	<% end %>
</table>
```

This will add a "Add occasion button" to each row and list any occasions already associated with the recipient.

Later, we will create a more elegant solution, but for now the user gets taken to a page where they will choose the recipient again.

Change *app/views/occasions/_form.html.erb* to look like:

```
<%= simple_form_for(@occasion) do |f| %>
  <%= f.error_notification %>

  <div class="form-inputs">
    <%= f.association :recipient, collection: current_user.recipients,as: :radio_buttons %>
    <%= f.input :title, label: 'Title for occasion', placeholder: 'eg. Birthday, anniversary, St Valentines Day etc' %>
    <%= f.input :date %>
  </div>

  <div class="form-actions">
    <%= f.button :submit %>
  </div>
<% end %>
```

Adding the *collection* to the form field, the user will only see their recipients.

If you add an occasion for your recipient now you will see the occasion listed on the home page of the app.




















