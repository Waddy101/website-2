# frozen_string_literal: true

class Event < ApplicationRecord
  has_many :game_event_relations, dependent: :destroy
  has_many :games, through: :game_event_relations
  default_scope { order('datetime ASC, id ASC') }
  def self.all_future
    all.select { |event| event.datetime.future? }
  end

  def facebook_event_link
    "https://facebook.com/events/#{facebook_event_id}"
  end

  def self.next_lan
    all_future.find { |event| !!(event.name =~ /LAN \d{2,3}/) }
  end

  def self.new_from_facebook_event(facebook_event)
    Event.new(
      name: facebook_event['name'],
      description: facebook_event['description'],
      location: facebook_event.dig('place', 'name'),
      datetime: DateTime.parse(facebook_event['start_time']),
      image_link: facebook_event.dig('cover', 'source'),
      facebook_event_id: facebook_event['id'],
      ticket_link: facebook_event['ticket_uri']
    )
  end
end
