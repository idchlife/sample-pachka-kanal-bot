# frozen_string_literal: true

require "logger"
require "kanal"
require "kanal/interfaces/pachka/pachka_interface"

# Get access token from environment variables
# (usually you load them from file in this script or provide them in the command line)
access_token = ENV.fetch("PACHKA_ACCESS_TOKEN", nil)

# Just in case if there is no access token
raise "Can't find PACHKA_ACCESS_TOKEN env variable. Did you forget to define it?" if access_token.nil?

# Initialize Kanal core
core = Kanal::Core::Core.new

# Define host and port for local web server which
# will accept requests from Pachka bot outgoing webhooks
host = "localhost"
port = 8090

# Create Pachka interface, which provides conditions, input/output properties
interface = Kanal::Interfaces::Pachka::PachkaInterface.new core, access_token, host: host, port: port

# Specify needed log level for debug purposes
logger = Logger.new $stdout
logger.level = Logger::WARN

core.add_logger logger

# Default response needed if there is no route found for input
core.router.default_response do
  pachka_text "Hey! It seems I don't yet know how to respond to that. But I will, someday! ;)"
end

# If error occures in respond block - provide this response
core.router.error_response do
  pachka_text "Unfortunately, error occured :( Please be patient while we fix it!"
end

# Configuration of router
core.router.configure do
  # Here you will define your routes.
  # Observing this code you can familiarize yourself with Kanal routing DSL
  # And use defined conditions and input/output properties by Pachka interface for Kanal

  # When command received from pachka is /help
  # It does not matter for this condition - whether command has text after it or not
  on :pachka, command: :help do
    # You can define subroutes, they will be checked for if parent route
    # has all conditions passed

    # This route executes only if text after command is "working hours"
    # Meaning whole query from user message looks like this: /help working hours
    on :pachka, text: "working hours" do
      # This block is used if you don't want any subroutes and ready to write response
      respond do
        # Thanks to Pachka interface for Kanal we have output parameters like
        # pachka_text - text for message
        # pachka_file_path - path to local file to upload with message
        # How to define output parameters in respond block?
        # You simply write them as DSL method

        pachka_text "Working hours for our company: 10.00 AM - 7.00 PM"
      end

      # If you want, you can even send another message (as many as you like),
      # it will be shipped right after the first one.
      # It can be used to separate text in multiple messages for whatever purpose
      respond do
        pachka_text "Rememeber to be in time for work!"

        # As you can see, you can send file with the message.
        # (any file, remember than images will have preview in messenger)
        # You can also just send file without message (in which case message won't be empty)
        pachka_file_path "./sample_file.zip"
      end

      # You can also send async message, it will be executed in separate thread meaning it won't
      # block your bot application
      respond_async do
        sleep 5
        pachka_text "Also this not so useful message is sent after 5 seconds of wait"
      end
    end

    on :pachka, text: "office 1 address" do
      respond do
        pachka_text "Office 1 addres is: Budapest, Andrássy út"
      end
    end

    # This route is special.
    # It uses condition pack :flow (defined in Batteries plugin for Kanal which used inside Pachka interface)
    # and condition :any (note that it is just symbol, and not a named argument like in rotes above,
    # because this conditions does not need argument)
    #
    # This route will be always used if router gets here trying to find suitable route checking by conditions
    # Meaning it's somewhat dangerous to use it on the upper level, but in our case,
    # if command does not start with /help - router won't get here and won't use this "always use" route.
    #
    # If router gets through /help route and fails to check for "working hours" and "office 1 address" route
    # it will get here, and we can provide users with message about available help commands
    on :flow, :any do
      respond do
        pachka_text "I can't help you with this information.
Available help topics (write after /help command):

working hours
office 1 address
"
      end
    end
  end

  # There will be case when you need to by flexible when processing messages from user
  # and provide a variety of different answers for command.
  # It would be cumbersome to write for example all cities here as subroutes.
  # Instead, we would process user pachka_text (which comes after "/weather")
  # in respond block
  on :pachka, command: :weather do
    respond do
      # Input is always available in respond block DSL
      # It stores properties that comes from input and are populated by the
      # Pachka interface for Kanal
      # Here they are:
      # input.pachka_query - full query, meaning if user sends /weather Vienna it will contain "/weather Vienna"
      # input.pachka_command - stored command without first slash, meaning if user sends /hello it will contain "hello"
      # input.pachka_text - stored only text that comes after command, meaning if user sends /weather Vienna it will contain "Vienna"
      city_name = input.pachka_text

      if city_name.empty?
        pachka_text "I can't parse weather without name of place!"
      else
        # Let's imagine you parse here some weather data
        weather = "Parsed weather for: #{city_name}"

        # You may be confused by the same name of DSL method pachka_text and input.pachka_text property
        # It means that Pachka interface for Kanal registered input property (input.pachka_text)
        # and output property (pachka_text DSL in respond block)
        # If you want to set output property - which will be shipped to pachka via bot message,
        # you use DSL methods.
        #
        # You can learn which DSL methods available in the docblocks above in
        # the help doc for first respond block
        pachka_text weather
      end
    end
  end
end

interface.start
