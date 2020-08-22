# frozen_string_literal: true

module Yokohama
  class ReservationFrame
    include ActiveModel::Model
    include ActiveModel::Attributes

    # NOTE: RubyとRailsにおけるTime, Date, DateTime, TimeWithZoneの違い - Qiita
    ## https://qiita.com/jnchito/items/cae89ee43c30f5d6fa2c
    # https://github.com/rails/rails/blob/master/activemodel/lib/active_model/type.rb
    attribute :tennis_court_name, :string
    attribute :start_date_time, :time
    attribute :end_date_time, :time
    attribute :now, :boolean

    validates :tennis_court_name, presence: true
    validates :start_date_time, presence: true
    validates :end_date_time, presence: true

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def self.build(tennis_court_name, onclick_attr_str)
      a = onclick_attr_str.split("','")
      date_str = a[5]
      time_str = a[6]

      year = date_str[0, 4].to_i
      month = date_str[4, 2].to_i
      day = date_str[6, 2].to_i

      start_hour = time_str[0, 2].to_i
      end_hour = time_str[4, 2].to_i

      new({ tennis_court_name: tennis_court_name,
            start_date_time: Time.zone.local(year, month, day, start_hour),
            end_date_time: Time.zone.local(year, month, day, end_hour) })
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def date_str
      start_date_time.strftime("%Y%m%d")
    end

    def time_str
      start_date_time.strftime("%H%M") + end_date_time.strftime("%H%M")
    end

    def date
      start_date_time.to_date
    end

    def eql?(other)
      tennis_court_name == other.tennis_court_name &&
        start_date_time == other.start_date_time &&
        end_date_time == other.end_date_time
    end

    def hash
      [tennis_court_name, start_date_time, end_date_time].hash
    end

    def to_human
      "#{tennis_court_name} #{date_time_to_human} #{now_to_human}"
    end

    private

    def date_time_to_human
      "#{date_to_human} #{time_to_human}"
    end

    def date_to_human
      date.strftime("%Y/%m/%d（#{ja_wday[date.wday]}）")
    end

    def time_to_human
      "#{start_date_time.strftime('%H:%M')}~#{end_date_time.strftime('%H:%M')}"
    end

    def now_to_human
      now ? "今すぐ予約可能" : "翌日７時に予約可能"
    end

    def ja_wday
      %w[日 月 火 水 木 金 土]
    end
  end
end
