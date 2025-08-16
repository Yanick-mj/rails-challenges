#!/usr/bin/env ruby

# Script de test pour vérifier l'envoi d'emails
require_relative 'config/environment'

puts "🧪 Test d'envoi d'email..."

# Créer un utilisateur de test avec un email unique
timestamp = Time.current.to_i
user = User.new(
  email: "test#{timestamp}@example.com",
  password: 'password123',
  first_name: 'Test',
  last_name: 'User'
)

if user.save
  puts "✅ Utilisateur créé avec succès"
  puts "📧 Email de bienvenue envoyé à : #{user.email}"
else
  puts "❌ Erreur lors de la création de l'utilisateur :"
  puts user.errors.full_messages
  exit 1
end

# Créer un challenge de test
challenge = Challenge.new(
  name: 'Challenge de test',
  description: 'Ceci est un challenge de test pour vérifier l\'envoi d\'emails',
  start_date: Date.current + 1.week,
  end_date: Date.current + 2.weeks,
  max_participants: 5,
  user: user
)

if challenge.save
  puts "✅ Challenge créé avec succès"
  puts "📧 Email de confirmation envoyé à : #{user.email}"
else
  puts "❌ Erreur lors de la création du challenge :"
  puts challenge.errors.full_messages
  exit 1
end

# Tester la participation
if challenge.persisted? && user.persisted?
  participation = ChallengeParticipation.new(
    user: user,
    challenge: challenge
  )

  if participation.save
    puts "✅ Participation créée avec succès"
    puts "📧 Email de participation envoyé à : #{user.email}"
  else
    puts "❌ Erreur lors de la participation :"
    puts participation.errors.full_messages
  end
end

puts ""
puts "🎉 Test terminé !"
puts "Vérifiez votre boîte email pour voir les emails envoyés."
