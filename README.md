# Final Challenge

This is my solution for the final challenge. All services can be run alone, except the Report System, which relies on the other services. 

The description of each service shows the features and how to run it. There are also comments in the code to explain everything in detail.

## Instructions

**Setup**
```sh
$ bundle install
```

**Test**
```sh
$ bundle exec rspec
```


### Services
 * [User Management](#user-management)
 * [Location Management System](#location-management-system)
 * [Item Tracking System](#item-tracking-system)
 * [Report System](#report-system)


## User Management

**Start User Management**
```sh
$ rackup -o 0.0.0.0 -p 9292 config.users.ru
```

**GET /user** (no response)
```sh
$ curl --user paul:thepanther localhost:9292/user
```


The user management in our example is a very basic authentication system with 3 hard coded users. There is no way to add, change or delete users at all.

The system provides a single HTTP endpoint:

**GET /user**

All requests to that endpoint must be made using HTTP Basic Auth to authenticate as one of these three users:

User  | Password
----- | -------------
wanda | partyhard2000
paul  | thepanther
anne  | flytothemoon

If the authentication succeeds, that is the HTTP Basic Auth combination of user name and password is correct, the endpoint returns a status code ``200``. In any other case (user not found, password incorrect) the endpoint returns HTTP status ``403``.

The user management system is never used from an end-user. Instead services query it to check if the authentication they get from the end-user is valid. E.g. if a user wants to pull a report from the report system she is authenticating her request to the report system with HTTP Basic Auth. The report system then calls the ``/user`` endpoint of the user management system and only if that returns a ``200`` status code the report is created. If the user system would return a ``403`` the report system would not create a report and instead return a ``403`` status code as well.

## Location Management System

**Start Location Management System**
```sh
$ rackup -o 0.0.0.0 -p 9292 config.locations.api.ru
```

The location management system holds a very simple model of data about each location where the company keeps stuff (e.g. their offices, warehouses, etc). The data model looks like this:

* name (any string)
* address (any string)
* id (an auto incremented integer that is set by the system)

So a location could look like this:

```ruby
{
  "name" => "Office Alexanderstraße",
  "address" => "Alexanderstraße 45, 33853 Bielefeld, Germany",
  "id" => 562
}
```

The system has actions to create, delete and list all locations. Each request must be authenticated with a valid user name / password combination (see User Management System for all existing users).

**POST /locations**
```sh
$ curl --data "name=Geek House&address=FH Salzburg, 5020 Salzburg" localhost:9292/locations
```

The request body must be a JSON encoded location object without the id like this:

```json
{
  "name": "Geek House",
  "address": "FH Salzburg, 5020 Salzburg"
}
```

The system creates an id record internally, and returns a HTTP status ``201`` with a complete JSON representation of the location (including the ID) as it's response body. Like this:

```json
{
  "name": "Geek House",
  "address": "FH Salzburg, 5020 Salzburg",
  "id": 1
}
```

**GET /locations**
```sh
$ curl localhost:9292/locations
```

Requests shall have an empty body. Returns status ``200`` and a JSON encoded array of all locations known to the system. Like this:

```json
[
  {
    "name": "Office Alexanderstraße",
    "address": "Alexanderstraße 45, 33853 Bielefeld, Germany",
    "id": 562
  },
  {
    "name": "Warehouse Hamburg",
    "address": "Gewerbestraße 1, 21035 Hamburg, Germany",
    "id": 563
  },
  {
    "name": "Headquarters Salzburg",
    "address": "Mozart Gasserl 4, 13371 Salzburg, Austria",
    "id": 568
  }
]
```

**DELETE /locations/:id**
```sh
$ curl -X DELETE localhost:9292/locations/1
```

Requests shall have an empty body. Deletes the location specified by the ID supplied in the URL. It then returns status ``200`` and an empty body.

Returns status ``404`` if the supplied ID does not exist.

## Item Tracking System

**Start Item Tracking System**
```sh
$ rackup -o 0.0.0.0 -p 9292 config.items.api.ru
```

The item tracking system holds a very simple model of data about each tracked item. The data model looks like this:

* name (any string)
* location id (an integer referencing a location)
* id (an auto incremented integer that is set by the system)

So a tracked item could look like this:

```ruby
{
  "name" => "Johannas PC",
  "location" => 123,
  "id" => 456
}
```

The system has actions to create, delete and list all tracked items. Each request must be authenticated with a valid user name / password combination (see User Management System for all existing users).

**POST /items**
```sh
$ curl --data "name=Supercomputer&location=1" localhost:9292/items
```

The request body must be a JSON encoded item object without the id like this:

```json
{
  "name": "Supercomputer",
  "location": 1
}
```

The system creates that record internally, and returns a HTTP status ``201`` with a complete JSON representation of the tracked item (including the ID) as it's response body. Like this:

```json
{
  "name": "Supercomputer",
  "location": 1,
  "id": 1
}
```

**GET /items**
```sh
$ curl localhost:9292/items
```

Response:

```json
[
  {
    "name":"Johannas PC",
    "location":562,
    "id":456
  },
  {
    "name":"Johannas desk",
    "location":562,
    "id":457
  },
  {
    "name":"Lobby chair #1",
    "location":563,
    "id":501
  }
]
```

**DELETE /items/:id**
```sh
$ curl -X DELETE localhost:9292/items/1
```
Requests made with an empty body. Deletes the tracked item specified by the ID supplied in the URL. It then returns status ``200`` and an empty body.

Returns status ``404`` if the supplied ID does not exist.

## Report System

The report system combines data from the location and item tracking system. It does not hold any data itself.

The system has only one endpoint to get a list of all tracked items grouped by their respective location. Each request must be authenticated with a valid user name / password combination (see User Management System for all existing users).

The report system relies on all other services.

**Start all services**
```sh
$ rackup -o 0.0.0.0 -p 9292 config.ru
```

**GET /reports/by-location**
```sh
$ curl --user paul:thepanther localhost:9292/reports/by_location
```

Requests shall have an empty body. Returns status ``200`` and a JSON encoded array of all locations. Each location object has a key ``items`` which holds an array of all items in that location. Like this:

```json
[
  {
    "name": "Office Alexanderstraße",
    "address": "Alexanderstraße 45, 33853 Bielefeld, Germany",
    "id": 562,
    "items": [
      {
        "name": "Johannas PC",
        "location": 562,
        "id": 456
      },
      {
        "name": "Johannas desk",
        "location": 562,
        "id": 457
      }
    ]
  },
  {
    "name": "Warehouse Hamburg",
    "address": "Gewerbestraße 1, 21035 Hamburg, Germany",
    "id": 563,
    "items": [
      {
        "name": "Lobby chair #1",
        "location": 563,
        "id": 501
      }
    ]
  },
  {
    "name":"Headquarters Salzburg",
    "address":"Mozart Gasserl 4, 13371 Salzburg, Austria",
    "id":568
  }
]
```