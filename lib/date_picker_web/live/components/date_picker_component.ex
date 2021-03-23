defmodule DatePickerWeb.Live.Components.DatePickerComponent do
  use DatePickerWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="date_picker" x-data="{ calendar_open : <%= @calendar_open %> }">
      <h1>Select your date: <button @click="{ calendar_open ? calendar_open = false : calendar_open = true }"><%= format_selected_date(@calendar.selected_day) %></button></h1>
      <div class="calendar" x-show="calendar_open" @click.away="calendar_open = false">
        <button class="previous_month" phx-click="change_month" phx-value-month="<%= @calendar.previous_month %>" phx-target="<%= @myself %>"><svg width="5" height="8" viewBox="0 0 5 8" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M4 7L1 4L4 1" stroke="#829AB1" stroke-width="1"/></svg></button>
        <h3 class="month"><%= @calendar.selected_month %></h3>
        <button class="next_month" phx-click="change_month" phx-value-month="<%= @calendar.next_month %>" phx-target="<%= @myself %>"><svg width="5" height="8" viewBox="0 0 5 8" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M1 1L4 4L1 7" stroke="#829AB1" stroke-width="1"/></svg></button>

        <ul class="dow"><li>S</li><li>M</li><li>T</li><li>W</li><li>T</li><li>F</li><li>S</li></ul>
        <%= for week <- @calendar.days_by_week do %>
          <ul class="week">
            <%= for date <- week do %>
              <%= print_calendar_date(%{date: date, selected_day: @calendar.selected_day, target: @myself}, assigns) %>
            <% end %>
          </ul>
        <% end %>
      </div>
    </div>
    """
  end

  def preload(assigns) do
    assigns
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    socket = assign(socket, :calendar, calendar_info(assigns.selected_date, assigns.selected_date))
    {:ok, assign(socket, assigns)}
  end

  def handle_event("change_month", %{"month" => month}, socket) do
    selected_day = get_in(socket.assigns, [:calendar, :selected_day])
    socket = assign(socket, calendar: calendar_info(month, selected_day), calendar_open: true)
    {:noreply, socket}
  end

  def handle_event("change_selected_day", %{"date" => date}, socket) do
    socket = assign(socket, calendar: calendar_info(date, date), calendar_open: true)
    send(self(), {:selected_date, date})
    {:noreply, socket}
  end

  defp calendar_info(month, selected_day) do
    month = cast_to_date(month)
    selected_day = cast_to_date(selected_day)

    %{
      selected_day: selected_day,
      selected_month: Calendar.strftime(month, "%B"),
      previous_month: previous_month(month),
      next_month: next_month(month),
      days_by_week: days_by_week(month)
    }
  end

  defp previous_month(%{month: 1} = date), do: %{date | year: date.year - 1, month: 12, day: 1}
  defp previous_month(%{month: month} = date), do: %{date | month: month - 1, day: 1}

  defp next_month(%{month: 12} = date), do: %{date | year: date.year + 1, month: 1, day: 1}
  defp next_month(%{month: month} = date), do: %{date | month: month + 1, day: 1}

  defp days_by_week(date) do
    month_start = Date.beginning_of_month(date)
    month_end = Date.end_of_month(date)

    offset_start = Date.day_of_week(month_start, :sunday) - 1
    offset_end = 7 - Date.day_of_week(month_end, :sunday)

    date_list = Date.range(month_start, month_end) |> Enum.map(& &1)

    padding_start = for _o <- 1..offset_start, do: nil
    padding_end = for _o <- 1..offset_end, do: nil

    padded_month_list = padding_start ++ date_list ++ padding_end
    Enum.chunk_every(padded_month_list, 7)
  end

  defp cast_to_date(%Date{} = date), do: date
  defp cast_to_date(date), do: Date.from_iso8601!(date)

  defp print_calendar_date(%{date: date, selected_day: date, target: _tgt}, assigns) do
    ~L"""
    <li aria-current="date"><button disabled><%= date.day %></button></li>
    """
  end

  defp print_calendar_date(%{date: nil, selected_day: _selected_day, target: _tgt}, assigns) do
    ~L"<li></li>"
  end

  defp print_calendar_date(%{date: date, selected_day: _selected_day, target: tgt}, assigns) do
    ~L"""
    <li><button phx-click="change_selected_day" phx-value-date="<%= date %>" phx-target="<%= tgt %>"><%= date.day %></button></li>
    """
  end

  defp format_selected_date(date) do
    date
    |> cast_to_date()
    |> Calendar.strftime("%b. %d, %Y")
  end
end
