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

### Step 10.

Let's build the functionality for the admin user to Add Gifts to the app.

At the bottom of the *app/views/gifts/index.html.erb* page, add the logic to only allow the admin user to Add a Gift.

```
...
<% if user_signed_in? %>
  <% if current_user.has_role? :admin %>
    <%= link_to 'New Gift', new_gift_path %>
  <% end %>
<% end %>
```

As before, we check to see if the user is signed in and then if the user has the role, 'admin'.

Let's also add a link to the Gifts page to our navbar.

*app/views/layouts/_navigation.html.erb*

Add the following code in line 3:
```
<li><%= link_to 'Gifts', gifts_path %></li>
````

(Under the `<ul class="nav">` line)

Let's also restrict access to the new and edit gifts pages, so only logged in admin users can see them.

In *app/controllers/gifts_controller.rb*

The first 3 lines should look like this:

```
class GiftsController < ApplicationController
  before_filter :authenticate_user!, :except => ['index', 'show']
  before_action :set_gift, only: [:show, :edit, :update, :destroy]
  ...
```

Note that this time we are allowing non-authenticated users to see the index and show pages of gifts.

We will add some more security later using authorization and CanCan.

### Step 11.

Now we will use the Carrierwave gem to upload images for our gifts.

In your *Gemfile*, add `gem "carrierwave"` above the development group and run `bundle` in your terminal.

Restart your server (*Control+C*, `rails s`)

Now we will *generate* an uploader using the carrierwave gem.

In your terminal:

```
rails g uploader GiftPicture
```

this should give you a file in *app/uploaders/gift_picture_uploader.rb*

Have a look in this file and read the comments which explain each line of ruby code in there.

You can:
+ choose to use a default picture if one is not uploaded
+ specify what file extensions you will accept
+ scale images

We will leave this file for now but come back to it later.

In your *app/models/gift.rb* file we add a line of code to tell it which attribute is connected to our Uploader

```
class Gift < ActiveRecord::Base
	mount_uploader :image, GiftPictureUploader
	
	has_many :gift_occasions
	has_many :occasions, through: :gift_occasions
end
```

If you look at the New Gift form in your browser now, you will see that it just has a text field for the Image attribute.

We will now make it so you can upload a file instead.

*app/views/gifts/_form.html.erb*

```
<%= simple_form_for @gift, :html => {:multipart => true} do |f| %>
  <%= f.error_notification %>

  <div class="form-inputs">
    <%= f.input :title %>
    <%= f.input :description %>
    <%= f.input :image, as: :file %>
    <%= f.input :price %>
  </div>

  <div class="form-actions">
    <%= f.button :submit %>
  </div>
<% end %>
```

Note the first line. We have removed the brackets around `@gift` and added `:html => {:multipart => true}`.

This helps us because if the form reloads due to a validation error, the uploaded image will remain as a part of the form.

Also see that the image field now has the `as: :file` notation. This means you will see an upload button instead of the text field.

Create a gift using the upload image button and then we will change the index and show pages to surface the image.

*app/views/gifts/index.html.erb*
This:
```
<td><%= gift.image %></td>
```

becomes this:
```
<td><%= image_tag gift.image %></td>
```

Make a similar change to *app/views/gifts/show.html.erb*

```
<td><%= image_tag @gift.image %></td>
```

You will probably want to pretty your page up by adding CSS classes or styling to the image.

For now I have just added the width property to my image tags:
```
<%= image_tag gift.image, width: '100px' %>
```

### Step 12.

First let's tidy up the Gift index page a little bit before adding the ability to give gifts to a recipient/occasion.

Add a .gift-image class to your stylesheet. I put it in *app/assets/stylesheets/bootstrap_and_overrides.css.scss*

```
.gift-image {
	width: 150px;
}
```

This is how my *app/views/gifts/index.html.erb* looks now:

```
<h1>Choose Gifts</h1>

<table class="table table-hover">


<% @gifts.each do |gift| %>
  <tr>
    <td><%= image_tag gift.image, class: 'gift-image' %></td>
    <td><strong><%= gift.title.titleize %></strong>
        <br><p><%= gift.description %></p>
    </td>
    <td><%= number_to_currency(gift.price) %></td>
    <td><%= link_to 'Choose ' + gift.title.parameterize, gift, class: 'btn btn-success pull-right' %></td>
    <% if user_signed_in? %>
      <% if current_user.has_role? :admin %>
        <td><%= link_to 'Edit', edit_gift_path(gift) %><br>
            <%= link_to 'Destroy', gift, method: :delete, data: { confirm: 'Are you sure?' } %>
        </td>
      <% end %>
    <% end %>
  </tr>
<% end %>
</table>

<br />

<% if user_signed_in? %>
  <% if current_user.has_role? :admin %>
    <%= link_to 'New Gift', new_gift_path %>
  <% end %>
<% end %>
```
What I've done:
+ Add the table class to the table tag `<table class="table table-hover">`
+ Remove the `<thead>` section
+ used the `titleize` method for the gift title (in case you didn't use a capital when adding the gift)
+ used the `number_to_currency` method to give the price a dollar sign and two zeros after the decimal place
+ added a button to take the user to the gift *show* page
+ used the `parameterize` method for the gift title on the button to make it lower case
+ hide the Edit and Destroy links from non-admin users


### Step 13.

Ok, this is the tricky but fun bit.

The next steps will be using some more advanced techniques so we will cover these next week.














