class ExpectedHours
  EXPECTED_HOURS_PER_DAY = 8
  ALLOWED_UNDERWORK_HOURS = 8

  class << self
    def per_month(month:, year: DateTime.current.year)
      EXPECTED_HOURS_PER_DAY * workdays_count(month, year)
    end

    private

    def workdays_count(month, year)
      month_start = DateTime.new(year.to_i, month.to_i, 1)

      (month_start..month_start.end_of_month).to_a.count(&:on_weekday?)
    end
  end
end
