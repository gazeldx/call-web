class Publisher
  def self.publish(exchange_name, routing_key, message = {})
    if channel.open?
      Rails.logger.info "==== channel is open. exchange_name: #{exchange_name}, routing_key: #{routing_key}, message for topic published is: #{message.to_json} ===="
    else
      Rails.logger.info "==== channel is not open. exchange_name: #{exchange_name}, routing_key: #{routing_key}, message for topic published is: #{message.to_json} ===="
    end

    exchange = channel.topic(exchange_name, durable: true)

    if message.is_a?(Hash)
      exchange.publish(message.to_json, routing_key: routing_key, content_type: 'application/json')
    else
      exchange.publish(message, routing_key: routing_key, content_type: 'text/plain')
    end

    # exchange.publish(message.to_json, routing_key: routing_key, content_type: 'text/plain')

    # x = channel.fanout("blog.#{exchange}")
    # q  = channel.queue("agent.inbound_call", :auto_delete => true)
    # # x  = ch.default_exchange
    #
    # x = channel.direct("agent.inbound_call")
    # x.publish(message.to_json)

    # channel.queue("americas.south").bind(exchange, :routing_key => "americas.south.#").subscribe do |delivery_info, metadata, payload|
    #   puts "An update for South America: #{payload}, routing key is #{delivery_info.routing_key}"
    # end
  end

  def self.directPublish(exchange_name, routing_key, message = {})
    if channel.open?
      Rails.logger.info "==== channel is open and message for direct publish is #{message.to_json} ===="
    else
      Rails.logger.info "==== channel is not open ===="
    end

    exchange = channel.direct(exchange_name, durable: true)

    if message.is_a?(Hash)
      exchange.publish(message.to_json, routing_key: routing_key, content_type: 'application/json')
    else
      exchange.publish(message, routing_key: routing_key, content_type: 'text/plain')
    end
  end

  def self.channel
    @channel ||= connection.create_channel
  end

  def self.connection
    @connection ||= Bunny.new({ host: Settings.rabbitmq.host,
                                port: 5672,
                                vhost: Settings.rabbitmq.vhost,
                                user: Settings.rabbitmq.username,
                                pass: Settings.rabbitmq.password,
                                ssl: false,
                                heartbeat: :server, # will use RabbitMQ setting
                                frame_max: 131072,
                                auth_mechanism: "PLAIN"
                              }).tap do |c|
      c.start
    end
  end
end