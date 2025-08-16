web: bundle exec puma
worker: bundle exec rails runner "loop { SolidQueue::Job.perform_all; sleep 1 }"
