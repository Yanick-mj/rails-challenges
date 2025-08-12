# Simplified seeds without Faker
return unless Rails.env.development? || Rails.env.test?

puts "🌱 Simple seeding..."

# Create users
admin = User.create!(
  email: "admin@example.com",
  password: "password",
  first_name: "Admin",
  last_name: "User"
)

creator = User.create!(
  email: "creator@example.com", 
  password: "password",
  first_name: "Challenge",
  last_name: "Creator"
)

user1 = User.create!(email: "user1@example.com", password: "password", first_name: "John", last_name: "Doe")
user2 = User.create!(email: "user2@example.com", password: "password", first_name: "Jane", last_name: "Smith")

# Create challenges
challenge1 = Challenge.create!(
  name: "30-Day Fitness Challenge",
  description: "Complete a 30-minute workout every day for 30 days.",
  start_date: Date.current,
  end_date: Date.current + 30.days,
  user: creator
)

challenge2 = Challenge.create!(
  name: "Daily Meditation", 
  description: "Practice 10 minutes of daily meditation.",
  start_date: Date.current,
  end_date: Date.current + 21.days,
  user: admin
)

# Add participations
ChallengeParticipation.create!(challenge: challenge1, user: user1)
ChallengeParticipation.create!(challenge: challenge1, user: user2)

puts "✅ Simple seeding completed!"
puts "Test accounts: admin@example.com, creator@example.com, user1@example.com (password: password)"