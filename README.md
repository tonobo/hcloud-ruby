# Hcloud

[![Build Status](https://github.com/tonobo/hcloud-ruby/actions/workflows/ruby.yml/badge.svg)](https://github.com/tonobo/hcloud-ruby/actions/workflows/ruby.yml)
[![codecov](https://codecov.io/gh/tonobo/hcloud-ruby/branch/master/graph/badge.svg)](https://codecov.io/gh/tonobo/hcloud-ruby)
[![Gem Version](https://badge.fury.io/rb/hcloud.svg)](https://badge.fury.io/rb/hcloud)
[![Maintainability](https://api.codeclimate.com/v1/badges/aa67f9d590d86845822f/maintainability)](https://codeclimate.com/github/tonobo/hcloud-ruby/maintainability)

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

* Create a client instance which fully handles concurrent pagination

```ruby
c = Hcloud::Client.new(
  token: "<your project token>", 
  auto_pagination: true,
  concurrency: 50 # default 20
)
```

* Expose client connection to class level

```ruby
Hcloud::Client.connection = Hcloud::Client.new(...)
```

### Client concurrency

Each action could be handled concurrently. The actual downsides are located 
at the exception handling. Means one request could break the whole bunch of requests,
you currently have to deal with that.

```ruby
servers = []
client.concurrent do
  10.times do 
    servers << client.servers.create(...)
  end
end 

servers.each do |(action, server, root_password)|
  # do something with your servers ...
end
```

### Server Resource

* List servers (basic client)

```ruby
# default page(1)
# default per_page(50)
c.servers.page(2).per_page(40).each do |server|
  server.datacenter.location.id #=> 1
end
```

* List servers (auto pagination client)

```ruby
# default nolimit
c.servers.limit(80).each do |server|
  server.datacenter.location.id #=> 1
end
```

* List with registered class level client

```ruby
Server.limit(10).each do |server|
  # do something with the server
end
```

* Create a server

Nonblocking:

```ruby
c.servers.create(name: "moo5", server_type: "cx11", image: "ubuntu-16.04")
#=> [#<Hcloud::Action>, <#Hcloud::Server>, "root_password"]
```

Wating for finish:

```ruby
action,server = c.servers.create(name: "moo5", server_type: "cx11", image: "ubuntu-16.04")

while action.status == "running"
  puts "Waiting for Action #{action.id} to complete ..."
  action = c.actions.find(action.id)
  server = c.servers.find(server.id)
  puts "Action Status: #{action.status}"
  puts "Server Status: #{server.status}"
  puts "Server IP Config: #{server.public_net["ipv4"]}"
  sleep 5
end
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
c.servers.first.destroy
#=> #<Hcloud::Action>
```
