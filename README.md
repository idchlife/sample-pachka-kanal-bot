# Sample Pachka Kanal Bot

Repository containing sample bot for Pachka messenger,
using Kanal library as base and Kanal Pachka Interface for connection
with Pachka api.

All needed info about coding routes and configuration you
can find in `app.rb` file.

## Installation

- Be sure you have ruby at least 2.7.6
- Clone this repository
- `bundle install`

## Usage

1. Rewrite configuration and routes as you please inside app.rb
2. `ruby app.rb`
3. By this point it is assumed your app on some kind of server
4. You can specify address and port you used in your Pachka bot configuration to accept outgoing hooks
5. Optionally you can use proxy server with some kind of domain to pass requests to your app

## License

Code of sample application is available with [MIT License](https://opensource.org/licenses/MIT).

