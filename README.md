# Rails + Ember.js

Read at: [http://www.devmynd.com/blog/2013-3-rails-ember-js](http://www.devmynd.com/blog/2013-3-rails-ember-js)

## Introduction

I usually sling Ruby, but lately I've been dreaming of the client-side. I've been dreaming because I watched [Tom Dale and Yehuda Katz](http://www.tilde.io) blast their mind-bullets through my skull and show me a new(ly 1.0ish) JavaScript framework called, [Ember.js](http://emberjs.com). (See: [Part 1](http://www.youtube.com/watch?v=_6yMxU-_ARs), [Part 2](http://www.youtube.com/watch?v=TTy1pbXdKJg), [Part 3](http://www.youtube.com/watch?v=4Ed_o3_59ME), and [Part 4](http://www.youtube.com/watch?v=aBvOXnTG5Ag))

I've never been a big fan of magic, but it is pretty baller when you see it up close. Like the first time you see someone levitate, then realize, "I'm just standing in the right spot for this tool to fool me." (See: [This cool kid.](http://www.youtube.com/watch?v=U8JomWZiOpQ))

The magic of Ember.js is _strong_. It leans on the lessons of its predecessors. It is basically Backbone.js at its core. So, if you want to ninja it all up, go for it. I'm not getting any younger, so letting someone else do the lifting once in a while is not a bad thing (for me).

Plus, JavaScript, in general, is the new hotness. Actually, it's more like the coolest old dude in the room that everyone knows and now he has a new story that everyone wants to hear. It's a language without a lot of strong opinions ([most of the time](https://github.com/twitter/bootstrap/issues/3057)). It has a crazy install base. Nearly every computer since like 1997 has a JavaScript engine running somewhere on it. JavaScript also requires almost nothing else to dig in. Want to write a JavaScript program? Okay, go ahead. Start writing.

There's no compiler, no convoluted instructions on how to install some stuff to get it running, and no real barriers to entry (other than the fact that you need to learn the syntax itself). Need classes? Okay, create them. _Do it yourself, you lazy bums_.

_NOTE: Please don't check my facts. 1997 was just a guess, okay? Thanks._

Annnnnnnd, scene. No more ranting. I promise.

## The Guides

Now, the nomenclature is a bit different from Rails in Ember.js, but it makes sense if you've ever done any desktop application development. Models, Views, and Controllers are based on the desktop way of thinking. Not the server-side architecure version that Rails peeps are used to. Read up on what each part of Ember.js does [here](http://emberjs.com/guides). The Ember.js guides are a great starting point for anyone trying to wrap their brain around what Ember.js is actually doing behind the scenes.

## Ember Extension

This tool promises to make debugging Ember.js applications much easier. Debugging is often painful because most of Ember.js lives in memory and not in files. The Ember Extension is a Chrome Extension that works with the Web Inspector Tools.

The Tilde Team seems to still be working out its kinks. But, here are some resources I've found useful so far…

* [Trying the Ember Inspector Out](http://www.kaspertidemann.com/how-to-try-out-the-ember-inspector-in-google-chrome)
* [Yehuda's Demo](https://www.youtube.com/watch?v=18OSYuhk0Yo&hd=1)
* [GitHub](https://github.com/tildeio/ember-extension)

## Installing Ember.js with Rails

Okay, I'm going to cover a lot of ground here, but I've also tried to break this down into simple, managable pieces. This tutorial only assumes you have basic knowledge of a Rails application and almost zero knowledge of an Ember.js application, other than JavaScript.

### Strap It Up

Let me be honest, this is super easy for a green project, but probably not the easiest task for a project that already has some clutter.

So, let's take the pie-in-the-sky route…

    rails new ember_tester -d postgresql

If you're using the PostgreSQL database, create the role and give it access with the superuser flag...

    createuser ember_tester -s

Bewm. Rails. With PostgreSQL (Heroku friendly, but not necessary).

Immediately delete the _public/index.html_ file. In Rails 4.0, you won't need to worry about this step…

    rm public/index.html

Add in the _ember-rails_ gem to the _Gemfile_…

    gem 'ember-rails'

And bundle it up…

    bundle install

Now you can bootstrap your new Rails app with Ember.js…

    rails generate ember:bootstrap

This creates a bunch of common folders and hooks you up with a namespace.

Making development mode work requires you to add the following to your _config/environments/development.rb_ environment file…

    config.ember.variant = :development

Stop here if you're all like, "Dude, I got it from here."

### Setting Up a Resource

Now, let's set up a Post resource on the Rails side of things…

    rails generate resource Post title:string body:text

This will not only set up the Rails files, it will set up the Ember.js files as well! Let's take a look…

    invoke  active_record
    create    db/migrate/20130301181446_create_posts.rb
    create    app/models/post.rb
    invoke    test_unit
    create      test/unit/post_test.rb
    create      test/fixtures/posts.yml
    invoke  controller
    create    app/controllers/posts_controller.rb
    invoke    erb
    create      app/views/posts
    invoke    test_unit
    create      test/functional/posts_controller_test.rb
    invoke    helper
    create      app/helpers/posts_helper.rb
    invoke      test_unit
    create        test/unit/helpers/posts_helper_test.rb
    invoke  resource_route
     route    resources :posts
    create  app/serializers/post_serializer.rb
    invoke  ember:model
    create    app/assets/javascripts/models/post.js
    invoke  ember controller and view (singular)
    create    app/assets/javascripts/views/post_view.js
    create    app/assets/javascripts/templates/post.handlebars
    create    app/assets/javascripts/controllers/post_controller.js
    create    app/assets/javascripts/routes/post_route.js
    invoke  ember controller and view (plural)
    create    app/assets/javascripts/views/posts_view.js
    create    app/assets/javascripts/templates/posts.handlebars
    create    app/assets/javascripts/controllers/posts_controller.js

You get the file structure for free. This is helpful and, even if these files are basically empty placeholders now, in the long run you will end up using them.

Let's set up some seed data in your _db/seeds.rb_ file…

    Post.create(
      title: 'A Sample Post',
      body: 'This will be a simple post record.'
    )

Now, create/migration/seed your database…

    bundle exec rake db:create db:migrate db:seed

### A Simple API

Okay, so we now have a resource, but I think the route Rails just gave us needs some help becoming an API for our new Ember.js client. So, let's make the _config/routes.rb_ look more like…

    EmberTester::Application.routes.draw do
      namespace :api do
        namespace :v1 do
          resources :posts
        end
      end

      root :to => 'ember#start'
    end

And, fix the _app/controllers/posts_controller.rb_. First, let's move it to the correct spot for our new API::V1 module…

    mkdir -p app/controllers/api/v1
    mv app/controllers/posts_controller.rb app/controllers/api/v1/posts_controller.rb

And its test…

    mkdir -p test/functional/api/v1
    mv test/functional/posts_controller_test.rb test/functional/api/v1/posts_controller_test.rb

Also, we need to modulerize that PostsController. While we are in there, let's just give it some basic functionality of show and index actions…

    class Api::V1::PostsController < ApplicationController
      respond_to :json

      def index
        respond_with Post.all
      end

      def show
        respond_with Post.find(params[:id])
      end
    end

Same with the test (spice it up with some actual testing too)…

    require 'test_helper'

    class Api::V1::PostsControllerTest < ActionController::TestCase
      test "should get index" do
        get :index, format: :json
        assert_response :success
      end

      test "should get show" do
        get :show, id: Post.first.id, format: :json
        assert_response :success
      end
    end

Yes, I know you can use some fancy pants API builder gem, but this is supposed to be a simple example application.

Add a controller that Ember.js can start with…

    rails generate controller Ember start

Start a Rails server…

    rails server

You can now do…

    curl http://localhost:3000/api/v1/posts.json

And, that should return some JSON data for you.

What's happening here? Rails is happening. That route we created is now serving a JSON representation of _Post.all_ from the controller. The object (in this case, an Array of Post objects) gets serialized with the [active_model_serializers](https://github.com/rails-api/active_model_serializers) gem. This gem gives you a serializer class to tell Rails what the JSON should look like when someone requests it. Take a look at the _app/serializers/post_serializer.rb_ file. The _active_model_serializers_ gem plays nice with Ember.js and _ember-rails_ includes it for you. The Rails resource generator even generated a serializer class for us.

Do you know how hard this would have been like 6 years ago in Java? Pain. Full.

### Hooking Up to Ember.js

Point your browser at _http://localhost:3000_ and see what you have so far. You should see in the Web Inspector's console a few debug messages from Ember.js. And, you should see the Application handlebars template rendering.

Ember.js does a lot for you. It gets everyone all bound up for you. Just waiting.

#### The Store

First off, we need to tell Ember.js that we are foolin' and moved the API into our own little secret path. In the _app/assets/javascripts/store.js_…

    EmberTester.Store = DS.Store.extend({
      revision: 11,
      adapter: DS.RESTAdapter.create({
        namespace: 'api/v1'
      })
    });

Ember.js's Store is like the _config/database.yml_ in Rails. It tells [ember-data](https://github.com/emberjs/data) where to get data for it's models. It sets up all the adapters so you can have any data source backing your Ember.js application.

#### Routes

Now, we should route users around. Create a new route file for our Posts index…

    touch app/assets/javascripts/routes/posts_route.js

Fill it in…

    EmberTester.PostsRoute = Ember.Route.extend({
      model: function() {
        return EmberTester.Post.find();
      }
    });

The _model_ function now just returns all the Post records in our Store.

Now, in our _app/javascripts/router.js_ we can connect the routes to the resources…

    EmberTester.Router.map(function() {
      this.resource('posts', function() {
        this.resource('post', { path: ':post_id' });
      });
    });

Nesting these routes makes the _{{outlet}}_ areas of the templates work to render inside each other. _{{outlet}}_ works like _yield_ in Rails. Nesting routes should happen when the user-interface deems it nested as well.

#### Candybars… I mean, Handlebars

Let's edit up our _app/assets/javascripts/templates/application.handlebars_ template and add some navigation…

    <header id="header">
      <h2>{{#linkTo "index"}}Home{{/linkTo}}</h2>

      <nav>
        <ul>
          <li>{{#linkTo "posts"}}Posts{{/linkTo}}</li>
        </ul>
      </nav>
    </header>

    <div id="content">
    {{outlet}}
    </div>

The _app/assets/javascripts/templates/posts.handlebars_ template…

    <h1>Posts</h1>

    <ul>
    {{#each post in controller}}
      <li>{{#linkTo 'post' post}}{{post.title}}{{/linkTo}}</li>
    {{else}}
      <li>There are no posts.</li>
    {{/each}}
    </ul>

    {{outlet}}

And, finally the _app/assets/javascripts/templates/post.handlebars_ template…

    <h1>{{title}}</h1>

    <p>{{body}}</p>

You're done. Take a deep breath.

Now, we didn't do anything very exciting yet. Future posts will detail more functionality that Ember.js and Rails can do together. Coming soon will be how to connect Pusher with Rails and Ember.js!
