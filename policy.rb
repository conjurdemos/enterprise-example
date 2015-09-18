variables = [
  variable('services/fantasyfootballnerd.com/api-key'),
  variable('services/espn.com/api-key'),
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
  variable('services/fantasyfootballnerd.com/api-key').permit %w(read execute), g
  variable('services/espn.com/api-key').permit %w(read execute), g
end

layer('fantasyapps') do |l|
  variables.each do |v|
    v.permit %w(execute), l
  end
end

