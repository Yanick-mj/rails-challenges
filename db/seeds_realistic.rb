# Seeds basés sur le CONTEXTE RÉEL du projet
# Fonctionnent SEULEMENT après les migrations nécessaires

puts "🌱 Seeding avec contexte réel..."

# Vérifier que les tables existent
unless ActiveRecord::Base.connection.table_exists?('challenge_participations')
  puts "❌ Table challenge_participations manquante. Exécutez: rails db:migrate"
  exit 1
end

# Nettoyer (optionnel en dev)
if Rails.env.development?
  ChallengeParticipation.delete_all
  Challenge.delete_all
  User.delete_all
end

# Créer utilisateurs avec les champs RÉELS
puts "Créating users with real schema..."

begin
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

  # Utilisateurs participants
  user1 = User.create!(email: "user1@example.com", password: "password", first_name: "John", last_name: "Doe")
  user2 = User.create!(email: "user2@example.com", password: "password", first_name: "Jane", last_name: "Smith")
  user3 = User.create!(email: "user3@example.com", password: "password", first_name: "Bob", last_name: "Wilson")

  puts "✅ Created #{User.count} users"

rescue ActiveRecord::RecordInvalid => e
  puts "❌ Erreur création users: #{e.message}"
  puts "💡 Les champs first_name/last_name manquent peut-être. Exécutez: rails db:migrate"
  exit 1
end

# Créer challenges avec les champs RÉELS  
puts "Creating challenges with real associations..."

challenge1 = Challenge.create!(
  name: "30-Day Fitness Challenge",
  description: "Complete a 30-minute workout every day for 30 days. Stay consistent and track your progress!",
  start_date: Date.current,
  end_date: Date.current + 30.days,
  user: creator
)

challenge2 = Challenge.create!(
  name: "Daily Reading",
  description: "Read for at least 20 minutes every day. Build a sustainable reading habit.",
  start_date: Date.current + 1.week,
  end_date: Date.current + 60.days,
  user: admin
)

challenge3 = Challenge.create!(
  name: "Learn Spanish", 
  description: "Practice Spanish for 15 minutes daily using your favorite app or resource.",
  start_date: Date.current + 3.days,
  end_date: Date.current + 90.days,
  user: user1
)

puts "✅ Created #{Challenge.count} challenges"

# Créer participations avec table RÉELLE
puts "Creating participations..."

begin
  # Challenge 1: 2 participants
  ChallengeParticipation.create!(challenge: challenge1, user: user1)
  ChallengeParticipation.create!(challenge: challenge1, user: user2)

  # Challenge 2: 1 participant  
  ChallengeParticipation.create!(challenge: challenge2, user: user3)

  # Challenge 3: aucun participant

  puts "✅ Created #{ChallengeParticipation.count} participations"

rescue ActiveRecord::StatementInvalid => e
  puts "❌ Erreur participations: #{e.message}"
  puts "💡 Table challenge_participations manquante. Exécutez: rails db:migrate"
  exit 1
end

# Résumé basé sur RÉALITÉ
puts "\n🎉 Seeding réaliste terminé!"
puts "📊 Summary:"
puts "   - #{User.count} users (avec first_name/last_name)"
puts "   - #{Challenge.count} challenges (avec user associations)"  
puts "   - #{ChallengeParticipation.count} participations (table many-to-many)"
puts "\n📝 Comptes de test:"
puts "   - admin@example.com (password: password)"
puts "   - creator@example.com (password: password)"
puts "   - user1@example.com, user2@example.com, user3@example.com (password: password)"
puts "\n🏁 Prêt pour tester l'US participation!"