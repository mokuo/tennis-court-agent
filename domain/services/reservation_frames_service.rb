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
  TENNIS_COURT_NAME_REGEX = /(?<non_number>\D+)(?<number>\d*)/.freeze

  def initialize
    @org_tennis_court_names = {}
  end

  def sort(reservation_frames)
    rfs = tennis_court_name2hankaku_num(reservation_frames)
    rfs = _sort(rfs)
    reverse_tennis_court_name(rfs)
  end

  private

  def tennis_court_name2hankaku_num(reservation_frames)
    reservation_frames.map do |reservation_frame|
      org_tennis_court_name = reservation_frame.tennis_court_name
      reservation_frame.tennis_court_name = reservation_frame.tennis_court_name.gsub(/[０１２３４５６７８９]/) { |c| NUM_HASH[c] }
      @org_tennis_court_names[reservation_frame.hash] = org_tennis_court_name

      reservation_frame
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def _sort(reservation_frames)
    reservation_frames.sort do |a, b|
      a_match_data = a.tennis_court_name.match(TENNIS_COURT_NAME_REGEX)
      b_match_data = b.tennis_court_name.match(TENNIS_COURT_NAME_REGEX)

      if a.tennis_court_name == b.tennis_court_name
        a.start_date_time <=> b.start_date_time
      elsif a_match_data[:non_number] == b_match_data[:non_number]
        a_match_data[:number].to_i <=> b_match_data[:number].to_i
      else
        a_match_data[:non_number] <=> b_match_data[:non_number]
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def reverse_tennis_court_name(reservation_frames)
    reservation_frames.map do |reservation_frame|
      reservation_frame.tennis_court_name = @org_tennis_court_names[reservation_frame.hash]
      reservation_frame
    end
  end
end
