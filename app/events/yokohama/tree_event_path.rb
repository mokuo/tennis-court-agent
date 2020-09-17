# frozen_string_literal: true

module Yokohama
  class TreeEventPath
    TIMESTAMP = %r{(?<timestamp>[^/]+)}.freeze # ex) 2020-09-06T14:03:10+09:00
    ORGANIZATION = %r{(?<organization>[^/]+)}.freeze # ex) yokohama
    PARK = %r{(?<park>[^/]+)}.freeze # ex) 公園名
    DATE = %r{(?<date>[^/]+)}.freeze # ex) 2020-09-13
    TIME = %r{(?<time>[^/]+)}.freeze # ex) 11:00~13:00
    TENNIS_COURT = %r{(?<tennis_court>[^/]+)}.freeze # ex) テニスコート１
    REGEX = %r{/#{TIMESTAMP}(/#{ORGANIZATION})?(/#{PARK})?(/#{DATE})?(/#{TIME})?(/#{TENNIS_COURT})?}.freeze

    def initialize(path_str)
      @path_str = path_str
    end

    def self.build
      "/#{Time.zone.now.to_s(:iso8601)}/yokohama"
    end

    def timestamp
      match_path[:timestamp]
    end

    private

    attr_reader :path_str, :match_path

    def match_path
      @match_path ||= REGEX.match(path_str)
    end
  end
end
