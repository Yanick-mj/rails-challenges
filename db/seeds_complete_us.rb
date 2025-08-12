# Seeds complets pour US Participation - Post migrations
# Fonctionne APRÈS avoir appliqué les migrations :
# - CreateChallengeParticipations 
# - AddNameToUsers

puts "🌱 Seeding US Participation complète..."

# Vérifications des tables nécessaires
unless ActiveRecord::Base.connection.table_exists?('challenge_participations')
  puts "❌ Table challenge_participations manquante."
  puts "💡 Exécutez d'abord : rails db:migrate"
  exit 1
end

unless ActiveRecord::Base.connection.column_exists?(:users, :first_name)
  puts "❌ Colonnes first_name/last_name manquantes dans users."
  puts "💡 Exécutez d'abord : rails db:migrate"
  exit 1
end

# Nettoyer les données existantes (dev seulement)
if Rails.env.development?
  puts "Cleaning existing data..."
  ChallengeParticipation.delete_all
  Challenge.delete_all  
  User.delete_all
end

# Créer utilisateurs avec TOUS les champs requis
puts "Creating users with complete schema..."

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

  # Participants de test
  user1 = User.create!(email: "user1@example.com", password: "password", first_name: "John", last_name: "Doe")
  user2 = User.create!(email: "user2@example.com", password: "password", first_name: "Jane", last_name: "Smith")
  user3 = User.create!(email: "user3@example.com", password: "password", first_name: "Bob", last_name: "Wilson")
  user4 = User.create!(email: "user4@example.com", password: "password", first_name: "Alice", last_name: "Brown")
  user5 = User.create!(email: "user5@example.com", password: "password", first_name: "Tom", last_name: "Davis")

  puts "✅ Created #{User.count} users with first_name/last_name"

rescue ActiveRecord::RecordInvalid => e
  puts "❌ Erreur création users: #{e.message}"
  puts "💡 Vérifiez que les migrations ont été appliquées"
  exit 1
end

# Créer challenges avec différents scénarios
puts "Creating challenges for US testing..."

challenge1 = Challenge.create!(
  name: "30-Day Fitness Challenge",
  description: "Complete a 30-minute workout every day for 30 days. Track your progress and stay motivated!",
  start_date: Date.current,
  end_date: Date.current + 30.days,
  user: creator
)

challenge2 = Challenge.create!(
  name: "Daily Reading Habit",
  description: "Read for at least 20 minutes every day. Build a sustainable reading habit and expand your knowledge.",
  start_date: Date.current + 1.week,
  end_date: Date.current + 60.days,
  user: admin
)

challenge3 = Challenge.create!(
  name: "Learn Spanish", 
  description: "Practice Spanish for 15 minutes daily using your favorite app or resource. ¡Vamos!",
  start_date: Date.current + 3.days,
  end_date: Date.current + 90.days,
  user: user1
)

challenge4 = Challenge.create!(
  name: "Morning Meditation",
  description: "Start each day with 10 minutes of mindfulness meditation. Find your inner peace.",
  start_date: Date.current - 1.week,
  end_date: Date.current + 3.weeks,
  user: user2
)

puts "✅ Created #{Challenge.count} challenges"

# Créer participations pour tester l'US
puts "Creating participations for US scenarios..."

begin
  # Challenge 1: 5 participants (moyen rempli)
  [user1, user2, user3, user4, user5].each do |participant|
    ChallengeParticipation.create!(challenge: challenge1, user: participant)
  end

  # Challenge 2: 2 participants (peu rempli)
  [user3, user5].each do |participant|
    ChallengeParticipation.create!(challenge: challenge2, user: participant)
  end

  # Challenge 3: 0 participants (vide)
  # Aucune participation

  # Challenge 4: 9 participants (presque plein)
  [admin, creator, user1, user3, user4, user5].each do |participant|
    next if participant == challenge4.user # Skip creator
    ChallengeParticipation.create!(challenge: challenge4, user: participant)
  end
  
  # Ajouter quelques participants en plus pour atteindre 9
  extra_users = []
  3.times do |i|
    extra_user = User.create!(
      email: "extra#{i+1}@example.com",
      password: "password",
      first_name: "Extra#{i+1}",
      last_name: "User"
    )
    extra_users << extra_user
    ChallengeParticipation.create!(challenge: challenge4, user: extra_user)
  end

  puts "✅ Created #{ChallengeParticipation.count} participations"

rescue ActiveRecord::RecordInvalid => e
  puts "❌ Erreur participations: #{e.message}"
  puts "💡 Vérifiez les validations métier"
  exit 1
end

# Résumé avec scénarios de test US
puts "\n🎉 US Participation seeding terminé!"
puts "📊 Summary:"
puts "   - #{User.count} users (avec noms complets)"
puts "   - #{Challenge.count} challenges (différents états)"
puts "   - #{ChallengeParticipation.count} participations (scénarios variés)"

puts "\n📝 Comptes de test:"
puts "   - admin@example.com (password: password)"
puts "   - creator@example.com (password: password)"
puts "   - user1@example.com à user5@example.com (password: password)"

puts "\n🎯 Scénarios US disponibles:"
puts "   - Challenge 1 (#{challenge1.participants.count}/10) : Moyen rempli"
puts "   - Challenge 2 (#{challenge2.participants.count}/10) : Peu rempli"  
puts "   - Challenge 3 (#{challenge3.participants.count}/10) : Vide"
puts "   - Challenge 4 (#{challenge4.participants.count}/10) : Presque plein"

puts "\n🏁 Prêt pour tester tous les AC de l'US !"
puts "💡 Lancez : rails server puis http://localhost:3000"