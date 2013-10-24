# BandRockr

This tutorial steps you through the creation of a web app that is a social network and discovery site for rock bands. 


We will use:
+ RailsComposer to give us a great starter app
+ Carrierwave gem to upload images



### Setup

The Rails development environment: Terminal app, text editor (Sublime Text recommended) and your browser (Chrome/Safari etc)

Download and install [Sublime Text 3](http://www.sublimetext.com/3).

In your command line: 

```
ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ~/usr/local/bin/subl
```


Make sure your terminal is using the correct version of Ruby and Rails.

Is RVM installed?
Type in your terminal:
```
rvm -v
```

```
ruby -v
```
This should say you are using version 1.9.3 or 2.0.0

Also type `rails -v` to check that you are using version 3.2.13 or 4. 




### Step 1. 

Starting the app.

Go to the [Rails Composer](http://railsapps.github.io/rails-composer/) app to copy the url you will need to create the app.

Open your command line/terminal, go to your apps folder and create the new app

```
rails new bandrockr -m https://raw.github.com/RailsApps/rails-composer/master/composer.rb
```

Respond to the questions as follows:

1. (3) Build your own application
1. (2) Thin
1. (2) Thin
1. (1) SQLite
1. (1) ERB
1. (1) Test::Unit
1. (1) None
1. (1) None
1. (1) None
1. (2) Twitter Bootstrap
1. (2) Twitter Bootstrap (SASS)
1. (2) Gmail
1. (1) Devise
1. (2) CanCan with Rolify
1. (2) SimpleForm
1. (4) Home Page, User Accounts, Admin Dashboard
1. y (Ban spiders)
1. y (Create a Github repo)
1. n (Don't use application.yml)
1. y (Reduce logs)
1. y (Use better_errors)
1. n (Don't create project specific gemset)

This creates a starter app for us. Let's open our project in sublime.

First change into the BandRockr directory:
```
cd bandrockr
```

```
subl .
```

And start our Rails server to see that our app works.
```
rails server
```

Open your browser to [localhost:3000](localhost:3000)


If you get an error, you might need to run `bundle install`.



### Step 2.

Now we seed the database with our admin user and user roles. 
Copy the text from the [Gist](https://gist.github.com/pedrogrande/5632376) and paste into (replace all the text) in *db/seeds.rb*

We push this data into the database with this command:
```
rake db:seed
```

Now let's open a new tab in our command line (terminal) window with Command+T and run the rails server again: `rails s`

Log in with the admin user account.


### Step 3.

Now that we have the basic site set up, we will start to add functionality.

But let's first think about the application design.

I was thinking the data models that make sense are:

+ BandProfile - where the bands can put in their name, info, facebook link, twitter, soundcloud
+ Gig - info about their upcoming/past gigs
+ Photo - image, info

There is a lot more we could do but lets start with this.


Let's create our scaffolds.

```
rails g scaffold BandProfile name info:text facebook twitter soundcloud
```

```
rails g scaffold Photo image caption band_profile:references
```

```
rails g scaffold Gig title date:date start_time:time finish_time:time location street_address suburb tickets_url band_profile:references
```

check your files in *db/migrate* to make sure they look right.

now run `rake db:migrate`

Now add the relationships into the model files:

*app/models/band_profile.rb*
```
class BandProfile < ActiveRecord::Base
	has_many :photos
  has_many :gigs
end
```

*app/models/photo.rb*
```
class Member < ActiveRecord::Base
	belongs_to :band_profile
end
```

*app/models/gig.rb*
```
class Gig < ActiveRecord::Base
	belongs_to :band_profile
end
```

### Step 4.

Let's have a look at what this gives us.








