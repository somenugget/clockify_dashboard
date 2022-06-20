class TimeController < ApplicationController
  def index
    api_base = 'https://api.clockify.me/api/v1'
    user_response = HTTParty.get("#{api_base}/user", headers: { 'X-Api-Key' => ENV['CLOCKIFY_API_KEY'] })
    @user = user_response.parsed_response

    workspaces_response = HTTParty.get("#{api_base}/workspaces", headers: { 'X-Api-Key' => ENV['CLOCKIFY_API_KEY'] })

    @workspaces = workspaces_response.parsed_response.map do |ws|
      time_entries = HTTParty.get(
        "#{api_base}/workspaces/#{ws['id']}/user/#{@user['id']}/time-entries",
        query: { start: start_date.strftime("%FT%T.000Z"), end: end_date.strftime("%FT%T.000Z") },
        headers: { 'X-Api-Key' => ENV['CLOCKIFY_API_KEY'] }
      )

      {
        'id' => ws['id'],
        'name' => ws['name'],
        'sum' => time_entries.
          parsed_response.
          map { |te| ActiveSupport::Duration.parse te['timeInterval']['duration'] }.
          sum
      }
    end

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
