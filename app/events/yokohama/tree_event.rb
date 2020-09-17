# frozen_string_literal: true

module Yokohama
  class TreeEvent < DomainTreeEvent
    # TIMESTAMP = %r{(?<timestamp>[^/]+)}.freeze # 2020-09-06T14:03:10+09:00
    # ORGANIZATION = %r{(?<organization>[^/]+)}.freeze # yokohama
    # PARK = %r{(?<park>[^/]+)}.freeze # 富岡西公園
    # DATE = %r{(?<date>[^/]+)}.freeze # 2020-09-13
    # TIME = %r{(?<time>[^/]+)}.freeze # 11:00~13:00
    # TENNIS_COURT = %r{(?<tennis_court>[^/]+)}.freeze # テニスコート１

    # def path_depth
    #   raise NotImplementedError, "You must implement #{self.class}##{__method__}."
    # end

    # def regex_list
    #   [
    #     TIMESTAMP,
    #     ORGANIZATION,
    #     PARK,
    #     DATE,
    #     TIME,
    #     TENNIS_COURT
    #   ]
    # end

    # def build_regex
    #   result = //
    #   path_depth.times { |n| result += %r{/#{regex_list[n]}} }
    #   result
    # end
  end
end
