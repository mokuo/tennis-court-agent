# frozen_string_literal: true

class AvailableDate
  def initialize(date)
    @date = date
  end

  def check_target?
    @date.saturday? ||
      @date.sunday? ||
      japanese_holiday?
  end

  def to_date
    @date
  end

  private

  def japanese_holiday?
    JapaneseHoliday.find_by(date: @date).present?
  end
end
