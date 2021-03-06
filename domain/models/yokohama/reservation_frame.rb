# frozen_string_literal: true

# HACK: disable コメント消す
# rubocop:disable Metrics/ClassLength

module Yokohama
  class ReservationFrame
    include ActiveModel::Model
    include ActiveModel::Attributes

    # NOTE: RubyとRailsにおけるTime, Date, DateTime, TimeWithZoneの違い - Qiita
    ## https://qiita.com/jnchito/items/cae89ee43c30f5d6fa2c
    # https://github.com/rails/rails/blob/master/activemodel/lib/active_model/type.rb
    attribute :park_name, :string
    attribute :tennis_court_name, :string
    attribute :start_date_time, :time
    attribute :end_date_time, :time
    attribute :now, :boolean
    attribute :state, :string
    attribute :id, :integer

    validates :park_name, presence: true
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

    def organization_name_ja
      "横浜市"
    end

    def date_str
      start_date_time.strftime("%Y%m%d")
    end

    def time_str
      start_date_time.strftime("%H%M") + end_date_time.strftime("%H%M")
    end

    def date
      start_date_time.to_date
    end

    def eql_frame?(other)
      park_name == other.park_name &&
        tennis_court_name == other.tennis_court_name &&
        start_date_time.to_s == other.start_date_time.to_s &&
        end_date_time.to_s == other.end_date_time.to_s
    end

    def eql?(other)
      eql_frame?(other) &&
        now == other.now
    end

    def hash
      [park_name, tennis_court_name, start_date_time, end_date_time, now].hash
    end

    def to_human
      # NOTE: 予約サイトのテニスコート名に公園名が含まれているため
      "#{tennis_court_name_to_human} #{date_time_to_human} #{now_to_human}"
    end

    def tennis_court_name_to_human
      # NOTE: 改行が入っている
      tennis_court_name.gsub(/\s/, " ")
    end

    def date_time_to_human
      "#{date_to_human} #{time_to_human}"
    end

    def to_hash
      {
        park_name: park_name,
        tennis_court_name: tennis_court_name,
        start_date_time: start_date_time.to_s,
        end_date_time: end_date_time.to_s,
        now: now,
        state: state,
        id: id
      }
    end

    def self.from_hash(hash)
      hash = hash.symbolize_keys

      new(
        park_name: hash[:park_name],
        tennis_court_name: hash[:tennis_court_name],
        start_date_time: Time.zone.parse(hash[:start_date_time]),
        end_date_time: Time.zone.parse(hash[:end_date_time]),
        now: hash[:now],
        state: hash[:state],
        id: hash[:id]
      )
    end

    def opening_hour
      7
    end

    # NOTE: テニスコート名に公園名が入っているので、取り除く
    def plain_tennis_court_name
      tennis_court_name.gsub(/^#{park_name}\n/, "")
    end

    private

    def date_to_human
      date.strftime("%Y/%m/%d（#{ja_wday[date.wday]}）")
    end

    def time_to_human
      "#{start_date_time.strftime('%H:%M')}~#{end_date_time.strftime('%H:%M')}"
    end

    def now_to_human
      now ? "今すぐ予約可能" : "翌日#{opening_hour}時に予約可能"
    end

    def ja_wday
      %w[日 月 火 水 木 金 土]
    end
  end
end
# rubocop:enable Metrics/ClassLength
