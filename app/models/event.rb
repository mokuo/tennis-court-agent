# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                            :bigint           not null, primary key
#  availability_check_identifier :string           not null
#  contents                      :json
#  name                          :string           not null
#  published_at                  :datetime         not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
class Event < ApplicationRecord
  validates :availability_check_identifier,
            presence: true,
            format: { with: /\A\d{14}\z/ } # ex) 20201010123007
  validates :contents, presence: true
  validates :name, presence: true
  validates :published_at, presence: true

  def self.persist!(domain_event_hash)
    create!(
      availability_check_identifier: domain_event_hash[:availability_check_identifier],
      contents: domain_event_hash,
      name: domain_event_hash[:name],
      published_at: domain_event_hash[:published_at]
    )
  end

  def to_domain_event
    domain_event_hash = contents
    domain_event_hash.delete("name")
    name.constantize.from_hash(domain_event_hash.symbolize_keys)
  end
end
