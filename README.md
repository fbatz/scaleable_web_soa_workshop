# Final Challenge

This challenge brings all things learned over the course of the SOA workshop together. It is your job to create multiple services that work together over the web.

Please help each other as much as you can but make sure that each of you comes up with an **individual** solution. The submission is not supposed to be a group's work.

## Intro

Your goal is to create a system that is used to track the inventory of a larger corporation. They run many offices in multiple locations and want to know how many pencils, staplers, computers, etc. they have in each of these locations.

As a good SOA developer your solution should come in 4 services:

* A user management system
* An item tracking system
* A system to manage the different locations
* A reporting system

We will run through all the different services one by one and all of them are stripped down to the bare minimum for this challenge. So no worries at all and lets get started!

## The Systems

All systems communicate with each other and the end user over HTTP. For this challenge no SSL/TLS is used. As in prior challenges user authentication happens via HTTP Basic Auth. Please see the User Management service description for more details.

![Overview over all four systems](assets/final-challenge-systems-overview.png)

### User Management

The user management in our example is a very basic authentication system with 3 hard coded users. There is no way to add, change or delete users at all.

The system provides a single HTTP endpoint:

**GET /user**

All requests to that endpoint must be made using HTTP Basic Auth to authenticate as one of these three users:

User  | Password
----- | -------------
wanda | partyhard2000
paul  | thepanther
anne  | flytothemoon

If the authentication succeeds, that is the HTTP Basic Auth combination of user name and password is correct, the endpoint returns a status code ``200``. In any other case (user not found, password incorrect) the endpoint returns HTTP status ``403``. The response body must always be empty.

The user management system is never used from an end-user. Instead services query it to check if the authentication they get from the end-user is valid. E.g. if a user wants to pull a report from the report system she is authenticating her request to the report system with HTTP Basic Auth. The report system then calls the ``/user`` endpoint of the user management system and only if that returns a ``200`` status code the report is created. If the user system would return a ``403`` the report system would not create a report and instead return a ``403`` status code as well. [This diagram](assets/authentication.pdf) illustrates the flow (please see the split of events depending of a valid or invalid authentication in 3a/b and 4a/b).

### Location Management System

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

The request body must be a JSON (see Ruby's JSON library and check ``JSON.parse`` and ``JSON.dump``) encoded location object without the id like this:

```json
{
  "name": "Office Alexanderstraße",
  "address": "Alexanderstraße 45, 33853 Bielefeld, Germany"
}
```

The system should create that record internally, and return a HTTP status ``201`` with a complete JSON representation of the location (including the ID) as it's response body. Like this:

```json
{
  "name": "Office Alexanderstraße",
  "address": "Alexanderstraße 45, 33853 Bielefeld, Germany",
  "id": 562
}
```

If not all fields are send in the request return an HTTP error code and a JSON encoded error message as the body.

**Important:** Please note that you do not need to use any data persistence (DB, Redis, …) for this challenge. Just keeping all the records in memory and therefore losing them whenever an app is terminated is good enough!

**GET /locations**

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

Requests shall have an empty body. Deletes the location specified by the ID supplied in the URL. It then returns status ``200`` and an empty body.

Returns status ``404`` if the supplied ID does not exist.

## Item Tracking System

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

The request body must be a JSON encoded item object without the id like this:

```json
{
  "name": "Johannas PC",
  "location": 123
}
```

The system should create that record internally, and return a HTTP status ``201`` with a complete JSON representation of the tracked item (including the ID) as it's response body. Like this:

```json
{
  "name": "Johannas PC",
  "location": 123,
  "id": 456
}
```

If not all fields are send in the request return an HTTP error code and a JSON encoded error message as the body. The system does **not** have to check for the validity of the supplied location ids!

**GET /items**

Requests shall have an empty body. Returns status ``200`` and a JSON encoded array of all tracked items known to the system. Like this:

```json
[
  {
    "name": "Johannas PC",
    "location": 123,
    "id": 456
  },
  {
    "name": "Johannas desk",
    "location": 123,
    "id": 457
  },
  {
    "name": "Lobby chair #1",
    "location": 729,
    "id": 501
  }
]
```

**DELETE /locations/:id**

Requests made with an empty body. Deletes the tracked item specified by the ID supplied in the URL. It then returns status ``200`` and an empty body.

Returns status ``404`` if the supplied ID does not exist.

## Report System

The report system combines data from the location and item tracking system. It does not hold any data itself.

The system has only one endpoint to get a list of all tracked items grouped by their respective location. Each request must be authenticated with a valid user name / password combination (see User Management System for all existing users).

**GET /reports/by-location**

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
  }
]
```

## Implementation

There are no hard limits on the way you build the systems. Ruby is preferred (if you want to use any other language please talk to me first so that we can ensure that I am able to read what you are coding). I strongly suggest building your systems with [Sinatra](http://www.sinatrarb.com/) or [Grape](https://github.com/intridea/grape) but any framework of your choice, or the lack thereof, is fine by me.

## Important Aside

During this challenge you create 4 services. Remember that while trying to resemble real life conditions these services are not meant to be ready for any *production* use. Your focus should therefore lie on the interaction between services, not making the services itself *pretty*, super stable or super performant (this also means all validations that are not mentioned in this challenge).

## Miscellaneous

The deadline is March 31st 2015.

For your submission please put each system in a seperate folder which's name easily determine it's content. Zip/Tar all 4 folders and please send a single archive file. If you have any remarks (how to handle your apps, etc) feel free to attach them as a README to the archive.

If you have any questions regarding this challenge please open a GitHub issue on this repo. This way everyone can see the answer. In case you wish to keep a question private please email us instead.

## Grading

This is a rough overview of my grading scheme:

Topic          | Points | Details
-------------- | ------ | --------
Implementation | 50     | Are your systems doing everything described in here and how well are they crafted
Documentation  | 15     | How well is each service and are shared mechanics (e.g. authentication) documented for someomne who **does not** have access to this document. There is nothing wrong in copying relevant parts from this document, too.
Tests          | 15     | Are your services tested? How well are they tested? How well are the tests written?
12factor       | 30     | Do your services and the way they are managed and configured obey the 12factor manifest?
**Total**      | 110    |

You will need 100 points for a 1+ (or your equivalent of *the best* grade possible). We all have our weak spots and this way you can still earn a perfect grade with some minor flaws.
