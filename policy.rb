variables = [
  variable('certs/myorg.com/hcm-web'),
  variable('certs/myorg.com/hcm-reporting'),
  variable('certs/myorg.com/hcm-biz'),
  variable('services/authorize.net/api-key'),
  variable('services/stripe.com/api-key'),
  variable('services/logentries.com/api-key')
]

group('/operations') do |g|
  variables.each do |v|
    v.permit %w(read execute update), g
  end
end
group('/hr-admins') do |g|
  variable('services/data.nasdaq.com/api-key').permit %w(read execute), g
end
group('/employees') do |g|
end

layer('hcm-web') do |l|
  variables.each do |v|
    v.permit %w(execute), l
  end
end
layer('hcm-reporting') do |l|
  variables.each do |v|
    v.permit %w(execute), l
  end
end
layer('hcm-biz') do |l|
  variables.each do |v|
    v.permit %w(execute), l
  end
end
layer('hcm-db') do |l|
  variables.each do |v|
    v.permit %w(execute), l
  end
end
