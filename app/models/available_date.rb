# frozen_string_literal: true

class AvailableDate
  def check_target?(date)
    date.saturday? ||
      date.sunday? ||
      japanese_holiday?(date)
  end

  private

  def japanese_holiday?(date)
    JapaneseHoliday.find_by(date: date).present?
  end
end
