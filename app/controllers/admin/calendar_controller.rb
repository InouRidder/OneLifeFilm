class Admin::CalendarController < Admin::AdminController

  def index
    @months = Date::MONTHNAMES.compact
    @month = params[:month] || @months[Date.today.month - 1]
    this_year = Date.today.year
    @year = params[:year].try(:to_i) || this_year
    @years = ((this_year-4)..(this_year+4)).to_a
    @bookings = Booking.by_month("#{@month} #{@year}").decorate
    @requests = Request.by_month("#{@month} #{@year}").where("state != 'declined'").decorate
    @events_per_day = create_event_object(@bookings, @requests)
    respond_to do |format|
      format.html
      format.js {render 'insert_events', events_per_day: @events_per_day, title: @month, year: @year }
    end
  end

  private

  def create_event_object(bookings, requests)
    events_per_day = {}
    bookings.each do |booking|
      events_per_day[booking.date_wedding] ? events_per_day[booking.date_wedding][:bookings]<< booking : events_per_day[booking.date_wedding] = {bookings: [booking] , requests: []}
    end
    requests.each do |request|
        events_per_day[request.date_wedding] ? events_per_day[request.date_wedding][:requests] << request : events_per_day[request.date_wedding] = {bookings: [], requests: [request]}
      end
    events_per_day.sort.to_h
  end

end
