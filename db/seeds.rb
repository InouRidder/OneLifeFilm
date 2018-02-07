require 'open-uri'
require 'nokogiri'
require 'pry'

puts "Do you want to import the latest films? press y"
answer = gets.chomp
import_films if answer == 'y'

def import_films
  file = open('db/videos.html').read
  html_doc = Nokogiri::HTML(file)
  array = []
  html_doc.search('.video_manager__table_item').each do |element|
    attributes = element.search('.video_manager__table_cell--greedy').search('a').first.attributes
    name = attributes["title"].value
    url = "https://vimeo.com#{attributes["href"].value}"

    film = Film.new(name: name, video_url: url).set_attributes
    film.save
  end
end

puts "Destroying all bookings"
Booking.destroy_all

puts "Creating 10 fake bookings"
10.times do
  booking = Booking.create(email_address: Faker::Internet.email, name: Faker::Name.unique.name, date_wedding: Date.today + rand(100), subject: Faker::Hacker.say_something_smart , location_wedding: Faker::Address.street_address, status: ['pending', 'approved'].sample)
  Playbook.create(allowed_songs: 3, booking: booking)
end

puts "Scraping 50 songs & Inserting into DB"

raw_doc = open("https://www.billboard.com/charts/greatest-hot-100-singles").read
parsed_doc = Nokogiri::HTML(raw_doc)

parsed_doc.search('.chart-row__title').take(50).each do |element|
  title = element.search('.chart-row__song').text.strip
  artist = element.search('.chart-row__artist').text.strip
  Song.create(title: title, artist: artist)
  puts "#{title} - #{artist}"
end

puts "Finished seeding"
