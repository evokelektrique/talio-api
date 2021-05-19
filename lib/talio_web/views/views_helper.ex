defmodule TalioWeb.ViewsHelper do
  # shift time zones 
  def format_time(date_time, timezone \\ "Asia/Tehran") do
    DateTime.shift_zone(date_time, timezone)
  end

  def format_time!(date_time, timezone \\ "Asia/Tehran") do
    DateTime.shift_zone!(date_time, timezone)
  end
end
