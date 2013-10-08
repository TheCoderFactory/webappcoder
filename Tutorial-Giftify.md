# Autogiftr

This tutorial will help you build the Autogiftr app.

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




