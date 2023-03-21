# frozen_string_literal: true

module JabberAdmin
  module Commands
    # Destroys a given room (MUC).
    #
    # @see https://bit.ly/31CtqxB
    class DestroyRoom
      # Pass the correct data to the given callable.
      #
      # @param callable [Proc, #call] the callable to call
      # @param room [String] room JID (eg. +room1@conference.localhost+)
      def self.call(callable, room:)
        name, service = room.split('@')
        callable.call('destroy_room', name: name, service: service)
      end
    end
  end
end
