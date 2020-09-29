# frozen_string_literal: true

class AvailableDate
  def self.filter(dates)
    new.filter(dates)
  end

  def filter(dates)
    dates.filter { |date| check_target?(date) }
  end

  private

  def check_target?(date)
    date.saturday? ||
      date.sunday? ||
      japanese_holiday?(date)
  end

  def japanese_holiday?(date)
    JapaneseHoliday.find_by(date: date).present?
  end
end
