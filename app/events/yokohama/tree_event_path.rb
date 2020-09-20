# frozen_string_literal: true

module Yokohama
  class TreeEventPath
    include ActiveModel::GlobalIdentification

    TIMESTAMP = %r{(?<timestamp>[^/]+)}.freeze # ex) 2020-09-06T14:03:10+09:00
    ORGANIZATION = %r{(?<organization>[^/]+)}.freeze # ex) yokohama
    PARK = %r{(?<park>[^/]+)}.freeze # ex) 公園名
    DATE = %r{(?<date>[^/]+)}.freeze # ex) 2020-09-13
    RESERVATION_FRAME = %r{(?<reservation_frame>[^/]+)}.freeze # ex) テニスコート１_11:00~13:00
    NOW = %r{(?<now>[^/]+)}.freeze # true / false（今すぐ予約可）
    REGEX = %r{/#{TIMESTAMP}(/#{ORGANIZATION})?(/#{PARK})?(/#{DATE})?(/#{RESERVATION_FRAME})?(/#{NOW})?}.freeze

    delegate :hash, to: :path_str

    def initialize(path_str)
      @path_str = path_str
    end

    def self.build
      "/#{Time.zone.now.to_s(:iso8601)}/yokohama"
    end

    def self.parse(path_str)
      new(path_str)
    end

    def append(str)
      self.class.new("#{path_str}/#{str}")
    end

    def to_s
      path_str
    end

    def eql?(other)
      to_s == other.to_s
    end

    def timestamp
      match_data[:timestamp]
    end

    def organization
      match_data[:organization]
    end

    def park
      match_data[:park]
    end

    def date
      d = match_data[:date]
      d && Date.parse(d)
    end

    def reservation_frame
      r = match_data[:reservation_frame]
      now = ActiveRecord::Type::Boolean.new.cast(match_data[:now])
      r && _reservation_frame(r, now)
    end

    private

    attr_reader :path_str

    def match_data
      @match_data ||= REGEX.match(path_str)
    end

    def _reservation_frame(reservation_frame_s, now)
      times, tennis_court = reservation_frame_s.split("_", 2)
      start_time, end_time = times.split("~", 2)
      Yokohama::ReservationFrame.new(
        {
          tennis_court_name: tennis_court,
          start_date_time: Time.zone.parse("#{date} #{start_time}"),
          end_date_time: Time.zone.parse("#{date} #{end_time}"),
          now: now
        }
      )
    end
  end
end
