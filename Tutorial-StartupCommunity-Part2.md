### Adding AJAX to your app

You will now add the functionality that allows users to post on their profile page.
Even though many users can make many posts, a post will always belong to one user.



Create the scaffold for Post in your terminal:
```
rails g scaffold Post title content:text user:references
```

and of course you should migrate:
```
rake db:migrate
```

Adjust your user and post models to tell the app the relationship between users and posts:

*app/models/user.rb*
```
has_many :posts
```


Now we will modify the posts controller so that when a user creates a post, it is associated with the current user.
*app/controllers/posts_controllers.rb*

```
  def create
    @post = Post.new(post_params)
    @post.user = current_user
    @post.save
    respond_with(@post)
  end
```

Now let's bring our users' posts into their user_profile pages and be ready to have a post form on the same page.
*app/controllers/user_profiles_controller.rb*

```
def show
	@posts = @user_profile.user.posts
	@post = Post.new
	respond_with(@user_profile)
end
```

Now let's add the posts to the user_profile show page.
*app/views/user_profiles/show.html.erb*

```
<h2>My Posts</h2>
<h3>New post:</h3>
<%= simple_form_for(@post) do |f| %>
  <%= f.error_notification %>
    <div class="form-group">
      <%= f.input :title, input_html: { class: "form-control"} %>
    </div>
    <div class="form-group">
      <%= f.input :content, label: 'Post', input_html: { class: "form-control"} %>
    </div>
    <%= f.button :submit %>
<% end %>
<hr>
<h3>Previous posts:</h3>
<% if @posts %>
	<div id="posts">
	  <% @posts.each do |post| %>
	    <div class="well">
	      <p>
	        <strong><%= post.title %></strong>
	      </p>
	      <p><small>Posted on <%= post.created_at.to_date %></small></p>
	      <hr>
	      <p><%= post.content %></p>
	    </div>
	  <% end %>
	 </div>
<% end %>
```

Now let's add the AJAX!

We will put a count of the number of posts the user has made up after the "My Posts" heading.
We will also add the post to the list of posts immediately.

First let's set a default scope so that posts show in descending chronological order:
*app/models/post.rb*

```
default_scope order: 'posts.created_at DESC'
```
Now let's add the number of posts to Posts heading:
*app/views/user_profiles/show.html.erb*

```
<h2>My Posts (<span id="posts_count"><%= @user_profile.user.posts.count %></span>)</h2>
```

Now we will put the list of posts into a partial.
```
<%= render @posts %>
```

Create a new file *app/views/posts/_post.html.erb*

Then cut/paste and following part from the user_profile show page and remove the first and last line. The *for each* loop does not need to be called here as it is implied by this type of partial. Also add the class 'post' to the div.

```
<% @posts.each do |post| %>
	<div class="well post">
	  <p>
	    <strong><%= post.title %></strong>
	  </p>
	  <p><small>Posted on <%= post.created_at.strftime('%b %d, %Y at %I:%M %p') %></small></p>
	  <hr>
	  <p><%= post.content %></p>
	</div>
<% end %>
```

Add the following lines to *app/controllers/posts_controller.rb*

This one up the top before the methods:

```
respond_to :html, :js
```

Change the create method to look like this:
```
def create
    @post = Post.new(post_params)
    @post.user = current_user
 
    @post.save
 
    respond_with @post, :location => user_profile_url(current_user.user_profile)
  end
```

Modify the first line of the New Post form on the user_profile show page:

*app/views/user_profiles/show.html.erb*
```
<%= simple_form_for @post, remote: true do |f| %>
```


Add the javascript! Because this template is aligned with the create method in the posts_controller, we have access to the @post variable. This way we can get the number of posts that belong to the user who posted this new post.

*app/views/posts/create.js.coffee*

```
$('<%= escape_javascript(render(:partial => @post))%>')
  .prependTo('#posts')
  .hide()
  .fadeIn()
 
$('#new_post')[0].reset()
 
$('#posts_count').html '<%= @post.user.posts.count %>'
```




