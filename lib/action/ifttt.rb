require 'rest-client'
require 'singleton'

module DSCConnect
  module Action
    class IFTTT
      include Singleton
      include LoggingHelper

      def maker_event(event:, **args)
        response = RestClient.post(
          event_uri(event),
          args.to_json,
          content_type: :json,
          accept: :json
        )
        info "Response : #{response}"
      rescue Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET,
             EOFError, SocketError, Timeout::Error, Net::HTTPBadResponse,
             Net::HTTPHeaderSyntaxError, Net::ProtocolError, RestClient::Unauthorized => e
        raise ActionError, e.message
      end

      private

      def event_uri(event)
        "https://maker.ifttt.com/trigger/#{event}/with/key/#{maker_key}"
      end

      def maker_key
        Configuration.instance.action_handlers.try(:ifttt).try(:maker_key)
      end
    end
  end
end
