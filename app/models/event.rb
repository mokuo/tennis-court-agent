# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                            :bigint           not null, primary key
#  availability_check_identifier :string(255)      not null
#  contents                      :json
#  name                          :string(255)      not null
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

  def self.persist!(domain_event)
    create!(
      availability_check_identifier: domain_event.availability_check_identifier,
      contents: domain_event.contents,
      name: domain_event.name,
      published_at: domain_event.published_at
    )
  end
end
