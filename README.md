# pkg-info-srv


pkg-info-srv is a Proof Of Concept for a service that would provide information on GNU/Linux packages.

## The problem

The initial requirements are pasted verbatim below

```
View Packages

On a Debian or an Ubuntu system there is a file called /var/lib/dpkg/status that holds information about software packages that the system knows about. Write a small program in Typescript that exposes some key information about currently installed packages via a REST API. The program should listen to HTTP requests on port 8080 on localhost and provide the following features:

1. The root API endpoint for the packages `/api/packages/` lists installed packages alphabetically and allows the consumer to find the details (2.) for each package.
2. Each package has its own API endpoint for details `/api/packages/:package-name`, the following information should be returned:
 - Name
 - Description
 - The names of the packages the current package depends on (skip version numbers)
 - The names of the packages that depend on the current package

Some things to keep in mind:
- Use REST/HATEOAS conventions.
- Minimize the use of external dependencies.
- The goal of the assignment is to view how you solve the problems with the programming language, not how well you use package managers :)
- The main design goal of this program is maintainability.
- Only look at the Depends field. Ignore other fields that work similarly, such as Suggests and Recommends.
- The section Syntax of control files of the Debian Policy Manual applies to the input data.
- A sample input file from https://gist.github.com/lauripiispanen/29735158335170c27297422a22b48caa
- Please avoid making your submission available to potential third parties by posting it to a public repository. Using a private repository is fine, or alternatively you can submit a zip file of the repository.
```

### Addendum

- The requirement of the solution being written in Typescript was deemed _a recommendation from the client_. If any other framework/approach is implemented, a justification ensues.

- The service should listen to the file changes (i.e.: the file can be considered dynamic, thus the service needs to react to file changes and serve the updated information accordingly.

## A solution

A solution for the given problem is to implement a REST service that listens for requests to the given endpoints (`/api/packages/` and `/api/packages/:package-name`) and provides the required response defined above in detail. The response payload is returned in JSON format.

The service reads the given file that describes packages installed in GNU/Linux Debian/Ubuntu systems, interprets it and responds with the required information in JSON format. The responses will contain, along with the payload, a status code conforming the standard HTTP status codes commonly used in REST architecture (2xx success, 4xx client error, etc). The server will respond with a 404 status code to other endpoints other than the mentioned above aside from documentation-related endpoints listed in OpenApi definition in root URL.

The service is to be implemented in Ruby using Sinatra.

For more information, refer to the TODO.

## A justification


TBD

## Usage


Given a successful installation of Ruby on local machine run through the following steps:

- Checkout codez
- `$ bundle install`
- `$ bundle exec rackup -p 8080`
- Open browser and point it to http://localhost:8080

or with Docker (upon request)

```
$ docker run -it -p 8080:8080 spavi/pkg-info-srv:latest
```

## Development

[Rake](https://github.com/ruby/rake) has been taken into use for automating
some tasks (documentation, code analysis, etc). For a list of automated tasks:

```
$ bundle exec rake -vT
rake doc:yard              # Generate YARD Documentation
rake rubocop               # Run RuboCop
rake rubocop:auto_correct  # Auto-correct RuboCop offenses
rake spec                  # Run RSpec code examples
```

### Documentation

A definition of the service using [OpenAPI specification](https://swagger.io/) is available at the base URL. Use a [dockerized swagger-editor](https://hub.docker.com/r/swaggerapi/swagger-editor/) or copy & paste the JSON output from the base URL into [editor.swagger.io](http://editor.swagger.io/) to interpret it.

Use `rake` to generate the documentation.

```
$ bundle exec rake doc:yard # To re-generate documentation
```

Documentation is saved to ./doc folder. You can mount it using Docker and [ecstatic](https://github.com/magandrez/ecstatic):

```
docker run -d --name docserver -p 80:80 -v ~/Documents/workbench/pkg-info-srv/doc:/var/html/www magandrez/ecstatic
```

### Tests

Tests are written using [RSpec](https://rspec.info/). Use `rake` to run tests.

### Bugs

See [KNOWN_BUGS](KNOWN_BUGS.md).
