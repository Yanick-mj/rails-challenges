# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'faker'

# Only seed in development or test environment
return unless Rails.env.development? || Rails.env.test?

puts "🌱 Seeding database..."

# Create sample users
puts "Creating users..."

users = []

# Create main test users
admin = User.find_or_create_by!(email: "admin@example.com") do |user|
  user.password = "password"
  user.first_name = "Admin"
  user.last_name = "User"
end
users << admin

creator = User.find_or_create_by!(email: "creator@example.com") do |user|
  user.password = "password"
  user.first_name = "Challenge"
  user.last_name = "Creator"
end
users << creator

# Create additional test users
8.times do |i|
  user = User.find_or_create_by!(email: "user#{i+1}@example.com") do |u|
    u.password = "password"
    u.first_name = Faker::Name.first_name
    u.last_name = Faker::Name.last_name
  end
  users << user
end

puts "✅ Created #{users.count} users"

# Create sample challenges
puts "Creating challenges..."

challenges = []

# Challenge 1: Active challenge with some participants
challenge1 = Challenge.find_or_create_by!(name: "30-Day Fitness Challenge") do |c|
  c.description = "Complete a 30-minute workout every day for 30 days. Track your progress and stay motivated with fellow participants!"
  c.start_date = Date.current
  c.end_date = Date.current + 30.days
  c.user = creator
end
challenges << challenge1

# Challenge 2: Future challenge
challenge2 = Challenge.find_or_create_by!(name: "Read 12 Books This Year") do |c|
  c.description = "Join us in reading one book per month. Share recommendations and discuss your favorite reads!"
  c.start_date = Date.current + 1.week
  c.end_date = Date.current + 1.year
  c.user = admin
end
challenges << challenge2

# Challenge 3: Nearly full challenge
challenge3 = Challenge.find_or_create_by!(name: "Daily Meditation") do |c|
  c.description = "Practice mindfulness with 10 minutes of daily meditation. Build a sustainable habit together."
  c.start_date = Date.current - 1.week
  c.end_date = Date.current + 3.weeks
  c.user = users[2]
end
challenges << challenge3

# Challenge 4: Empty challenge
challenge4 = Challenge.find_or_create_by!(name: "Learn a New Language") do |c|
  c.description = "Spend 15 minutes daily learning a new language using your favorite app or resource."
  c.start_date = Date.current + 3.days
  c.end_date = Date.current + 90.days
  c.user = users[3]
end
challenges << challenge4

puts "✅ Created #{challenges.count} challenges"

# Create participations
puts "Creating participations..."

# Add participants to challenge 1 (5 participants)
participants_count = 0
[users[4], users[5], users[6], users[7], users[8]].each do |user|
  unless ChallengeParticipation.exists?(challenge: challenge1, user: user)
    ChallengeParticipation.create!(challenge: challenge1, user: user)
    participants_count += 1
  end
end

# Add participants to challenge 2 (2 participants)
[users[4], users[6]].each do |user|
  unless ChallengeParticipation.exists?(challenge: challenge2, user: user)
    ChallengeParticipation.create!(challenge: challenge2, user: user)
    participants_count += 1
  end
end

# Add participants to challenge 3 (9 participants - nearly full)
[users[0], users[1], users[4], users[5], users[6], users[7], users[8], users[9], admin].each do |user|
  next if user == challenge3.user # Skip the creator
  unless ChallengeParticipation.exists?(challenge: challenge3, user: user)
    ChallengeParticipation.create!(challenge: challenge3, user: user)
    participants_count += 1
  end
end

# Challenge 4 has no participants

puts "✅ Created #{participants_count} participations"

# Summary
puts "\n🎉 Seeding completed!"
puts "📊 Summary:"
puts "   - #{User.count} users total"
puts "   - #{Challenge.count} challenges total"
puts "   - #{ChallengeParticipation.count} participations total"
puts "\n📝 Test accounts:"
puts "   - admin@example.com (password: password)"
puts "   - creator@example.com (password: password)"
puts "   - user1@example.com through user8@example.com (password: password)"
puts "\n🏁 You can now test the participation system!"
