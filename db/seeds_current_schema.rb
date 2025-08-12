# Seeds basés sur le SCHEMA RÉEL actuel
# Fonctionne avec : users (email, password) + challenges (name, description, dates, user_id)

puts "🌱 Seeding avec schema RÉEL actuel..."

# Nettoyer
Challenge.delete_all if Rails.env.development?
User.delete_all if Rails.env.development?

# Créer utilisateurs SANS first_name/last_name (car ça n'existe pas)
puts "Creating users with REAL schema (email/password only)..."

admin = User.create!(
  email: "admin@example.com",
  password: "password"
)

creator = User.create!(
  email: "creator@example.com", 
  password: "password"
)

user1 = User.create!(
  email: "user1@example.com",
  password: "password"
)

user2 = User.create!(
  email: "user2@example.com", 
  password: "password"
)

puts "✅ Created #{User.count} users (email/password only)"

# Créer challenges avec le schema RÉEL
puts "Creating challenges with REAL associations..."

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

# NOTE: PAS de challenge_participations car la table n'existe pas
puts "\n🎉 Seeding terminé avec schema RÉEL!"
puts "📊 Summary:"
puts "   - #{User.count} users (email seulement, pas de noms)"
puts "   - #{Challenge.count} challenges (avec user associations)"  
puts "   - 0 participations (table n'existe pas encore)"
puts "\n📝 Comptes de test:"
puts "   - admin@example.com (password: password)"
puts "   - creator@example.com (password: password)" 
puts "   - user1@example.com, user2@example.com (password: password)"
puts "\n⚠️  POUR L'US PARTICIPATION:"
puts "   - Il faut créer les migrations manquantes"
puts "   - Puis re-seeder avec les participations"