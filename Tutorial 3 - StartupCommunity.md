### Self referential associations

#### In this tutorial we will add the functionality where a user can *follow* another user, in the style of Twitter.

The difference between one directional and bi-directional self-referential:

One directional is where a user can follow a user but it is not mandatory for the followed user to follow the first user in return.
- A user can follow other users
- A user can be followed by other users

Bi-directional is where there is no relationship between users unless they are both linked to each other.
- A user can be friends with other users only if those users agree to the friendship

Start by generating a model that is a join table for the relationships between users.

```
rails generate model Relationship follower_id:integer followed_id:integer
```

Since we will be finding relationships by follower_id and by followed_id, we should add an index on each column for database efficiency. So before you migrate, go the migration file created by the generate command and add the add_index lines. *db/migrate/xxxxx_create_relationships.rb*

```
class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
```
The third add_index line is a composite index that enforces uniqueness of pairs of (follower_id, followed_id), so that a user can’t follow another user more than once.

Then migrate `rake db:migrate`

In your user model, we need to tell it about *relationships* and we want the app to destroy the relationships if the user is deleted. We also add the line to tell the app that a User has many followed users through relationships - the representation of our many-to-many relationship. Because of Rails conventions, it is expecting to use :followeds. But as this is an awkward sounding/non-existing word, we will change it to :followed_users and tell the app that the source is :followed.

*app/models/user.rb*
```
has_many :relationships, foreign_key: "follower_id", dependent: :destroy
has_many :followed_users, through: :relationships, source: :followed
```

And we need to tell the relationship model that the follower and followed objects are actually Users. We will also add validation so that a relationship isn't created without two user ids.

*app/models/relationship.rb*
```
class Relationship < ActiveRecord::Base
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end

```

Add some helper methods to our user model. As we will use this logic a lot in our app, it is great to have these methods defined in our model.

*app/models/user.rb*
```
  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy!
  end
```

We have now added followed users, so now let's add followers to our user model:
*app/models/user.rb*
```
has_many :reverse_relationships, foreign_key: "followed_id", class_name: "Relationship", dependent: :destroy
has_many :followers, through: :reverse_relationships, source: :follower
```

We need to make routes for our *following* and *followers* actions.

*config/routes.rb*
```
resources :users do
    member do
      get :following, :followers
    end
end
resources :relationships, only: [:create, :destroy]
```

*app/views/user_profiles/show.html.erb*
```
<div class="col-md-4">

  <div class="stats">
    <a href="<%= following_user_path(@user_profile.user) %>" class="btn btn-lg btn-warning">
      <strong id="following" class="stat">
      Following 
        <span class="badge"><%= @user_profile.user.followed_users.count %></span> users
      </strong>
      
    </a>
    </p>
    <a href="<%= followers_user_path(@user_profile.user) %>" class="btn btn-lg btn-warning">
      <strong class="stat">
      Followed by
        <span class="badge" id="followers"><%= @user_profile.user.followers.count %></span> users
      </strong>
      
    </a>
  </div>
<br>
<div class="follow_unfollow">
<% unless current_user == @user_profile.user %>
  <div id="follow_form">
  <% if current_user.following?(@user_profile.user) %>
    <%= render 'unfollow' %>
  <% else %>
    <%= render 'follow' %>
  <% end %>
  </div>
<% end %>
</div>
</div>
</div>
```

*app/views/user_profiles/_follow.html.erb
```
<%= form_for(current_user.relationships.build(followed_id: @user_profile.user.id),
             remote: true) do |f| %>
  <div><%= f.hidden_field :followed_id %></div>
  <%= f.submit "Follow", class: "btn btn-large btn-primary" %>
<% end %>
```

*app/views/user_profiles/_unfollow.html.erb
```
<%= form_for(current_user.relationships.find_by(followed_id: @user_profile.user.id),
             html: { method: :delete },
             remote: true) do |f| %>
  <%= f.submit "Unfollow", class: "btn btn-large" %>
<% end %>
```



*app/controllers/relationships_controller.rb*
```
class RelationshipsController < ApplicationController
  
  def create
    @user = User.find(params[:relationship][:followed_id])
    @user_profile = @user.user_profile
    current_user.follow!(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    @user_profile = @user.user_profile
    current_user.unfollow!(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end
```

*app/views/relationships/create.js.erb*
```
$("#follow_form").html("<%= escape_javascript(render('user_profiles/unfollow')) %>")
$("#followers").html('<%= @user_profile.user.followers.count %>')
```

*app/views/relationships/destroy.js.erb*
```
$("#follow_form").html("<%= escape_javascript(render('user_profiles/follow')) %>")
$("#followers").html('<%= @user_profile.user.followers.count %>')
```




