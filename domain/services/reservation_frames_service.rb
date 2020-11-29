# frozen_string_literal: true

class ReservationFramesService
  NUM_HASH = {
    "０" => 0,
    "１" => 1,
    "２" => 2,
    "３" => 3,
    "４" => 4,
    "５" => 5,
    "６" => 6,
    "７" => 7,
    "８" => 8,
    "９" => 9
  }.freeze
  REGEX = /(?<non_number>\D+)(?<number>\d*)/.freeze

  def sort(reservation_frames)
    rfs = reservation_frames.sort_by(&:start_date_time)
    # rfs.sort_by(&:tennis_court_name)
    rfs = rfs.map do |rf|
      rf.tennis_court_name = rf.tennis_court_name.gsub(/[０１２３４５６７８９]/) { |c| NUM_HASH[c] }
      rf
    end

    rfs = rfs.sort do |a, b|
      a_match_data = a.tennis_court_name.match(REGEX)
      b_match_data = b.tennis_court_name.match(REGEX)

      if a_match_data[:non_number] != b_match_data[:non_number]
        a_match_data[:non_number] <=> b_match_data[:non_number]
      elsif a_match_data[:number].nil? || b_match_data[:number].nil?
        a_match_data[:non_number] <=> b_match_data[:non_number]
      else
        a_match_data[:number] <=> b_match_data[:number]
      end
    end

    rfs.map do |rf|
      rf.tennis_court_name = rf.tennis_court_name.gsub(/\d/) { |c| NUM_HASH.invert[c] }
      rf
    end
  end
end
