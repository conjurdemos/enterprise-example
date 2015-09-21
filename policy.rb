variables = [
  variable('certs/myorg.com/businessapp1'),
  variable('services/squareup.com/api-key'),
  variable('services/data.nasdaq.com/api-key'),
  variable('services/stripe.com/api-key'),
  variable('services/logentries.com/api-key')
]

group('/operations') do |g|
  variables.each do |v|
    v.permit %w(read execute update), g
  end
end
group('/developers') do |g|
  variables.each do |v|
    v.permit %w(read execute), g
  end
end
group('/contractors') do |g|
  variable('services/data.nasdaq.com/api-key').permit %w(read execute), g
end

layer('businessapp1') do |l|
  variables.each do |v|
    v.permit %w(execute), l
  end
end

