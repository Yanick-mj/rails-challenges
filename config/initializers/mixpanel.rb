# Configuration Mixpanel
require "mixpanel-ruby"

# Initialiser le tracker Mixpanel
MIXPANEL_TOKEN = ENV["MIXPANEL_TOKEN"] || "ce5d905d78e7112a08dc81e5624a4c42"

# Créer l'instance Mixpanel
$mixpanel = Mixpanel::Tracker.new(MIXPANEL_TOKEN)

# Configuration pour l'environnement de développement
if Rails.env.development?
  # En développement, on envoie les événements ET on les log
  # Le callback ne fonctionne pas comme prévu, on utilise une approche différente
  puts "🔧 Mixpanel configuré pour l'environnement de développement"
  puts "   Token: #{MIXPANEL_TOKEN}"
  puts "   Les événements seront envoyés à Mixpanel ET loggés"
end
