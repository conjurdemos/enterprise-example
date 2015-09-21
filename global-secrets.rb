global_secrets = nil

group '/operations' do
  owns do
    global_secrets = [
      variable('certs/myorg.com/businessapp1'),
      variable('services/squareup.com/api-key'),
      variable('services/data.nasdaq.com/api-key'),
      variable('services/stripe.com/api-key'),
      variable('services/logentries.com/api-key')
    ]
  end
end

group '/developers' do |developers|
  global_secrets.each do |secret|
    secret.permit %w(read execute), developers
  end
end

group('/contractors') do |contractors|
  variable('services/data.nasdaq.com/api-key').permit %w(read execute), contractors
end
