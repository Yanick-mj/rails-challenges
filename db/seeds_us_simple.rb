# Seeds simples pour tester US Participation
# À exécuter APRÈS les migrations

puts "🌱 Creating test data for US Participation..."

# Clean existing data
ChallengeParticipation.delete_all if defined?(ChallengeParticipation)
Challenge.delete_all
User.delete_all

# Create test users
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

user1 = User.create!(
  email: "user1@example.com",
  password: "password", 
  first_name: "John",
  last_name: "Doe"
)

user2 = User.create!(
  email: "user2@example.com",
  password: "password",
  first_name: "Jane", 
  last_name: "Smith"
)

puts "✅ Created #{User.count} users"

# Create test challenges
challenge1 = Challenge.create!(
  name: "30-Day Fitness Challenge",
  description: "Complete a 30-minute workout every day for 30 days.",
  start_date: Date.current,
  end_date: Date.current + 30.days,
  user: creator
)

challenge2 = Challenge.create!(
  name: "Daily Reading",
  description: "Read for at least 20 minutes every day.",
  start_date: Date.current + 1.week,
  end_date: Date.current + 60.days, 
  user: admin
)

challenge3 = Challenge.create!(
  name: "Learn Spanish",
  description: "Practice Spanish for 15 minutes daily.",
  start_date: Date.current + 3.days,
  end_date: Date.current + 90.days,
  user: user1
)

puts "✅ Created #{Challenge.count} challenges"

# Create some participations to test
ChallengeParticipation.create!(challenge: challenge1, user: user1)
ChallengeParticipation.create!(challenge: challenge1, user: user2)
ChallengeParticipation.create!(challenge: challenge2, user: user1)

puts "✅ Created #{ChallengeParticipation.count} participations"

puts "\n🎉 Test data ready!"
puts "📝 Test accounts:"
puts "   - admin@example.com / password"
puts "   - creator@example.com / password"  
puts "   - user1@example.com / password"
puts "   - user2@example.com / password"

puts "\n🎯 Test scenarios:"
puts "   - Challenge 1: #{challenge1.participants.count}/10 participants"
puts "   - Challenge 2: #{challenge2.participants.count}/10 participants"
puts "   - Challenge 3: #{challenge3.participants.count}/10 participants (empty)"

puts "\n🚀 Ready to test! Run: rails server"