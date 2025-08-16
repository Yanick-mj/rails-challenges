web: bundle exec puma
worker: bundle exec rails runner "loop { SolidQueue::Job.dispatch_all; sleep 1 }"
