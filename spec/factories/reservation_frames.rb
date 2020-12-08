# frozen_string_literal: true

# == Schema Information
#
# Table name: reservation_frames
#
#  id                            :bigint           not null, primary key
#  availability_check_identifier :string           not null
#  end_at                        :datetime         not null
#  now                           :boolean          not null
#  park_name                     :string           not null
#  start_at                      :datetime         not null
#  state                         :integer          default(0), not null
#  tennis_court_name             :string           not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
FactoryBot.define do
  factory :reservation_frame do
    park_name { "MyString" }
    tennis_court_name { "MyString" }
    start_at { "2020-12-08 12:33:36" }
    end_at { "2020-12-08 12:33:36" }
    now { false }
    state { 1 }
  end
end
