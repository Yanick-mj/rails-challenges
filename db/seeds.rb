require "faker"

Challenge.destroy_all

15.times do |i|
  start_date = Faker::Date.forward(days: rand(0..30))
  end_date = start_date + rand(1..10).days

  Challenge.create!(
    name: "Challenge #{i + 1}",
    description: "This is the description for challenge #{i + 1}",
    start_date: start_date,
    end_date: end_date
  )
end
puts "Created #{Challenge.count} challenges."
