# BandRockr

This tutorial steps you through the creation of a web app that is perfect for a rock band. We will make it a generic site so that any band can use it.




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
rails new bandrockr -m https://raw.github.com/RailsApps/rails-composer/master/composer.rb
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
13. (3) Omniauth
14. (1) Facebook
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
cd bandrockr
```

Open the directory in Sublime `subl .`

Because the RailsComposer has not yet been properly updated for Rails 4, we need to remove the *attr_accessible* lines from the User model file:

Delete lines 3 and 4 from *app/models/user.rb*
```
  attr_accessible :role_ids, :as => :admin
  attr_accessible :provider, :uid, :name, :email
```


Test that the app works by running your server `rails s` and opening your browser to [localhost:3000](localhost:3000)

If you get an error, you might need to run `bundle`.

### Step 4.

#### Setting up Facebook login

Go to the [Facebook developers](https://developers.facebook.com/) site and click on **Apps** in the top navbar.

Find the *Create new app* button and click it.

Enter a unique app name - I used *AutorockrPete* - it won't accept a name that is already in use somewhere else.

I chose *Entertainment* as the category and click **Continue**.

Your new Facebook app is in *Sandbox* mode - that means that only you will be able to use it. When we put your site live to production, we will take it out of Sandbox mode - but for now leave it.

In the section *Select how your app will integrate with Facebook*, click on *Website with Facebook login*

Then enter `http://localhost:3000` in the field that is shown.

Scroll down and click *Save changes*

Leave the browser for a minute and go to Sublime where your *bandrockr* code is and open *config/initializers/omniauth.rb* 

You will see this:
```
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['OMNIAUTH_PROVIDER_KEY'], ENV['OMNIAUTH_PROVIDER_SECRET']
end
```

You can see that there are two environmental variables (enclosed in ENV['']) so we need to put these values into our command line window. You get these values from the Facebook app you just created and you will find them at the top of the page. The provider key is the App ID and the provider secret is the App Secret.

Go to the terminal window where your bandrockr app is running and stop the server (Control + C).
Enter the following (replacing the relevant parts with your own app id and secret):
```
export OMNIAUTH_PROVIDER_KEY=XXXXXXXXXXXXXXX OMNIAUTH_PROVIDER_SECRET=XXXXXXXXXXXXXXX
```

Then restart your server (`rails s`)

Reload `localhost:3000` in your browser and click on the Login button to see if it all works.

You should redirected to a Facebook page to give your authorisation, and then redirected back to your site and be logged in. You should also now see your name on the Home page.

If you click on your name, you will see the user's show page with your name and email address. You will also see the *Admin* button in the navbar - as the first user to sign in, you have been given the role of Admin.

Facebook gives us more information about the signing in user which I will show you how to access later in the tutorial.


### Step 5.

Now that we have the basic site set up, we will start to add functionality.

But let's first think about the application design.

I was thinking the data models that make sense are:

+ BandProfile - where the band can put in their name, info
+ Member - info about each band member
+ Link - a collection of the band's and band members' social media links
+ Album - links, image, info
+ Track - links, image, info
+ Photo - image, info
+ Gig - info about their upcoming/past gigs

There is a lot more we could do but lets start with this.

As we discussed last weekend, this is a simple app in regard to data models. The only real data relationships required here are:

+ A BandProfile has many Links, a Link belongs to BandProfile (one to many)
+ A Member has many Links, a Link belongs to Member (one to many)
+ An Album has many tracks, a Track belongs to an album (one to many)

You will notice that a link could belong to either the band or a band member. We could create a BandLink model and a MemberLink model (instead of a single Link model) but lets try it this way and see how it works.

To be fair, a track could belong to more than one album but let's leave it like this for now.

Let's create our scaffolds.

```
rails g scaffold BandProfile name info:text
```

```
rails g scaffold Member name info:text image
```

```
rails g scaffold Link title url band_profile:references member:references
```

```
rails g scaffold Album title release_date:date info:text buy_link
```

```
rails g scaffold Track title album:references info:text buy_link
```

```
rails g scaffold Photo image caption
```

```
rails g scaffold Gig title date:date start_time:time finish_time:time location street_address suburb tickets_url
```

check your files in *db/migrate* to make sure they look right :)

now run `rake db:migrate`

Now add the relationships into the model files:

*app/models/album.rb*
```
class Album < ActiveRecord::Base
	has_many :tracks
end
```

*app/models/member.rb*
```
class Member < ActiveRecord::Base
	has_many :links
end
```

*app/models/band_profile.rb*
```
class BandProfile < ActiveRecord::Base
	has_many :links
end
```

### Step 6.

Now we will set up the Admin page so that the band can enter their information.

We will put the info about the band on the Admin page (and show an edit button) but if they have not entered their information yet, we will have a button to Create their band profile. 

The current *admin* page (created by RailsComposer) is actually the User index page. We will now create our own admin page. In your terminal:

```
rails g controller admin index
```

Go to *config/routes.rb* and change the new line at the top from:
```
get "admin/index"
```

to 

```
get "admin" => "admin#index"
```

Now let's change the link in the navbar so that the Admin button actually takes you to the admin page.

In *app/views/layouts/_navigation.html.erb*, find the following line (probably line 15):
```
<%= link_to 'Admin', users_path %>
```

And change it to:
```
<%= link_to 'Admin', admin_path %>
```

Go to your browser, refresh the page and check that the Admin button takes you to the new admin page.

To show the band's info on the admin page, we need to add instance variables to the admin controller and its index method (action).

*app/controllers/admin_controller.rb*

```
class AdminController < ApplicationController
  def index
  	@band_profile = BandProfile.first
  	@links = Link.all
  	@members = Member.all
  	@gigs = Gig.all
  	@albums = Album.all
  end
end
```
As the band should only have one profile - we will need to bring in only the 'first' profile created, and also prevent more from being created.

Let's edit the Admin page. *app/views/admin/index.html.erb*

Here, we are:
+ adding an if/else statement
+ if a band profile does not exist, show the button to Add a profile
+ if a band profile **does** exist, show the info the band has provided
+ if there are links associated with the band profile, show them
+ show a button to add links
+ if band members have been added, show them and their info
+ show a button to add band members
+ if gigs have been added, show the info about them
+ show a button to add a gig
+ if photos have been added, show a button to the photo gallery/list
+ show a button to add a photo
+ if an album has been added, show the title and tracks on it
+ show an edit button next to each listed track
+ show a button to add a track
+ show a button to add an album

[Click here to see the admin/index.html.erb file](https://github.com/pedrogrande/bandrockr/blob/master/app/views/admin/index.html.erb)

### Step 7.

Let's show some stuff on the home page.

+ The most recent photo uploaded
+ The next gig
+ The latest album
+ An embedded track (the most recent)
+ Band info
+ Links
+ Twitter feed

Starting with the *app/controllers/home_controller.rb* file, we will bring in the data we will need to display in the view.

```
class HomeController < ApplicationController
  def index
    @band_profile = BandProfile.first
    if @band_profile
      @links = @band_profile.links
      @photo = Photo.first
      @gig = Gig.next
      @album = Album.first
      @track = Track.first
    end
  end
end
```



Then apply some default scopes to our models so that the first record returned is the last one added. Except for Gig, where we will create a method in our Gig model so that it returns the next gig to the controller.

*app/models/photo.rb*
```
class Photo < ActiveRecord::Base
	default_scope { order("created_at DESC") }
end
```
This default scope means that every time a database call for photos is made, they are ordered by the created_at field in descending order.

*app/models/gig.rb*
```
class Gig < ActiveRecord::Base
	def self.next
		where("date > ?", Date.today).order("date ASC").first
	end
end
```

*app/models/album.rb*
```
class Album < ActiveRecord::Base
	has_many :tracks

	def self.latest
		order("release_date DESC").first
	end
end
```

*app/models/track.rb*
Work it out yourself :) Look at photo.rb for clues.


You can decide how you would like your home page to be formatted: *app/views/home/index.html.erb*

[Here's mine](https://github.com/pedrogrande/bandrockr/blob/master/app/views/home/index.html.erb)




#### Step 8.

Embedding a SoundCloud widget onto the home page.

Let's create a new field/attribute for the Track model. In your terminal:

```
rails g migration AddEmbedLinkToTrack embed_link:text
```

After checking your migration file (*db/migrate/xxxxxxx_add_embed_link_to_track.rb*) run `rake db:migrate`

Now we'll add the embed_link field to the Track form. *app/views/tracks/_form.html.erb*

```
<%= f.input :embed_link, label: 'Paste the embed link here' %>
```

We also need to add the *:embed_link* attribute to our params list in *apps/controllers/tracks_controller.rb*

Down the bottom of the file, find the *track_params* method and change it to read:
```
def track_params
  params.require(:track).permit(:title, :album_id, :info, :buy_link, :embed_link)
end
```

Then add this to your home page *apps/views/home/index.html.erb* 
```
<%= @track.embed_link.html_safe %>
```

Go to [SoundCloud](https://soundcloud.com/theloveyourights/hey-now), click on Share and copy the widget code. Paste the code into the embed_link field for a track in your app (in your browser). Go to your homepage and see that it works.

### Step 9.

Let's put our app onto [Heroku](https://dashboard.heroku.com/)!

Follow the [Getting Started](https://devcenter.heroku.com/articles/quickstart) guide on Heroku.

If you get an SSH key error, see the [documentation](https://devcenter.heroku.com/articles/keys).

Heroku has great documentation so search their devcenter site if you have any issues.

Now we're ready to modify your app to make it work on Heroku.

First we need to add a couple of gems and modify the *Gemfile*.

As Heroku does not allow you to use SQLite as a database, we need to use PostgreSQL for our production environment.

Find the `gem 'sqlite3'` line in your gemfile, cut it (Command+X) and paste it (Command+V) within the development group of gems.

```
group :development do
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_19, :mri_20, :rbx]
  gem 'hub', :require=>nil
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'sqlite3'
end
```

Now add a production group under the development group and include the *pg* (PostgreSQL) and *rails_12factor* (allows Rails 4 apps to run on Heroku) gems. 

```
group :production do
  gem 'pg'
  gem 'rails_12factor'
end
```

Run `bundle` in your terminal.

Create an app on Heroku in your terminal (substitue *appname* for the name of your app - it must be unique so sometimes you might need to add a number or your name):
```
heroku create appname
```

This has created a new git remote. If you type `git remote -v` in your terminal, you will see that there are Heroku entries there now.

Commit your changes to git.

```
git add .
git commit -am 'ready for Heroku'
```

And push your app to Heroku:
```
git push heroku master
```

The first push will take a minute or two. When it has finished, you need to create the database tables on the production database.

```
heroku run rake db:migrate
```

You can now visit your app on the web by going to the URL *http://YOUR_APP_NAME.herokuapp.com* (of course change YOUR_APP_NAME to what you named your app on Heroku).

The data you have entered into your development environment will not be in your production environment.

Add your Facebook developer ID and Secret to Heroku with the following command (obviously using your own key and secret).
```
heroku config:set OMNIAUTH_PROVIDER_KEY=XXXXXXXXXXXXXXX OMNIAUTH_PROVIDER_SECRET=XXXXXXXXXXXXXXX
```

This is the same as doing the *export* command on your development machine. You can check your Heroku config values at any time with `heroku config`.

Go to the app you created at the [Facebook developer site](https://developers.facebook.com/apps), choose *Edit app* and change the *Site URL* to your Heroku app site (eg. http://YOUR_APP_NAME.herokuapp.com) and save the changes.

Because your app is in *Sandbox mode*, only you will be able to login. If you take your app out of Sandbox mode, other people will be able to log in too.

### Step 10.

Using cloud storage for your uploads. 

> This tutorial assumes you have used the Carrierwave gem to allow image uploads for the photos section of the site. See the [Autogiftr](https://github.com/TheCoderFactory/webappcoder/blob/master/Tutorial-Giftify.md#step-11) tutorial for Carrierwave setup instructions.

You will notice that when you upload pictures (or any other files) with Carrierwave in your app on Heroku, the pictures will stop working (disappear). This is because Heroku doesn't support storing files.

You need to use a cloud storage service such as [AWS S3 (Amazon)](http://aws.amazon.com/s3/) or [Google Developer Storage](https://developers.google.com/storage/). Neither are free but are very cheap eg. 8.5c per Gigabyte per month. And AWS even has a free trial period for most of their services.

I will use AWS S3 for this tutorial.

After you have signed up for your account with Amazon AWS, go to the [Management Console](https://console.aws.amazon.com/console/home?#).

Choose the S3 link and click the Create Bucket* button. Give the bucket a name (eg. bandrockr) and click on *Create*. I use the *US Standard* region as it is the cheapest and there is no noticable lag.

We will now set up Carrierwave and Fog gems to use S3 for file storage in our app.

In your *Gemfile*, add the fog gem:
```
gem "fog", "~> 1.3.1"
```
----
You might not have seen this type of gem versioning in your Gemfile before now. It is possible to specify the gem version like below:

++ '= 1.3.1'
++ '> 1.3.1'
++ '>= 1.3.1'
++ '< 1.3.1'
++ '~> 1.3.1'

The first four are self-explanatory but the last one (using tilde+greater-than), means to use at least version 1.3.1 and use up to version 1.4 (the next major release). Or could be `>= 1.3.1 AND < 1.4`

'~> 1.4' means `>= 1.4 AND < 2`
----

Once you have saved your Gemfile, run `bundle` in your terminal.

Go to *app/uploaders/image_uploader.rb* (When I created my uploader I used the following command: `rails g uploader Image`, if you used a different `Photo` it would be *app/uploaders/photo_uploader.rb*).

Comment out the line that says `storage :file`.

Now create a file in *app/initializers* called *carrierwave.rb* and copy in the code found in this Gist:

[Carrierwave initializer file to use Fog and S3 storage for your file uploads](https://gist.github.com/pedrogrande/7003284)















