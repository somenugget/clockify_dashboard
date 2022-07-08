class TimesController < ApplicationController
  before_action :authenticate_user

  def index
    api_base = 'https://api.clockify.me/api/v1'
    workspaces_response = HTTParty.get("#{api_base}/workspaces", headers: { 'X-Api-Key' => api_key })

    @workspaces = workspaces_response.parsed_response.map do |ws|
      time_entries = HTTParty.get(
        "#{api_base}/workspaces/#{ws['id']}/user/#{current_user['id']}/time-entries",
        query: { start: start_date.strftime("%FT%T.000Z"), end: end_date.strftime("%FT%T.000Z"), 'page-size' => 5000 },
        headers: { 'X-Api-Key' => api_key }
      )


      {
        'id' => ws['id'],
        'name' => ws['name'],
        'sum' => time_entries.
          parsed_response.
          select { |te| te['timeInterval']['duration'].present? }.
          map { |te| ActiveSupport::Duration.parse te['timeInterval']['duration'] }.
          sum
      }
    end

    @total_hours = @workspaces.map { |ws| ws['sum'] }.sum
    @expected_hours = ExpectedHours.per_month(month: start_date.month, year: start_date.year)
    @enough_hours = @total_hours.in_hours > @expected_hours - ExpectedHours::ALLOWED_UNDERWORK_HOURS
    @months_links = months_links
  end

  private

  def start_date
    (params[:start] ||  DateTime.current).to_datetime.beginning_of_month
  end

  def end_date
    start_date.end_of_month
  end

  def months_links
    current_date = Date.current

    (0..6).map do |month|
      month_date = current_date - month.month

      {
        'label' => month_date.strftime('%b %Y'),
        'path' => root_path(start: month_date.strftime('%F')),
        'active' => start_date.strftime('%Y-%m') == month_date.strftime('%Y-%m')
      }
    end
  end
end
