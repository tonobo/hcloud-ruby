# Hcloud

[![Build Status](https://travis-ci.org/tonobo/hcloud-ruby.svg?branch=master)](https://travis-ci.org/tonobo/hcloud-ruby)
[![codecov](https://codecov.io/gh/tonobo/hcloud-ruby/branch/master/graph/badge.svg)](https://codecov.io/gh/tonobo/hcloud-ruby)

This is an unoffical ruby client for HetznerCloud Api service.

**Its currently in development and lacking a lot of feature. 
The bindings are also not considered stable.**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hcloud'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hcloud

## Usage

### Client

* Create a client instance.

```ruby
c = Hcloud::Client.new(token: "<your project token>")
```

### Server Resource

* List servers

```ruby
c.servers.each do |server|
  server.datacenter.location.id #=> 1
end
```

* Create a server

```ruby
c.servers.create(name: "moo5", server_type: "cx11", image: "ubuntu-16.04")
#=> [#<Hcloud::Action>, <#Hcloud::Server>, "root_password"]
```

* Update servers' name

```ruby
c.servers.count
#=> 2
c.servers.first.update(name: "moo")
#=> #<Hcloud::Server>
c.servers.each{|x| x.update(name: "moo") }
Hcloud::Error::UniquenessError: server name is already used
```

* Delete a server

```ruby
c.servers.first.delete
#=> #<Hcloud::Action>
```
