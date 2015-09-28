global_secrets = nil

group '/operations' do
  owns do
    global_secrets = [
      variable('certs/myorg.com/hrapp1'),
      variable('services/myorg.com/reporting-api-key'),
      variable('services/mybank.com/api-key'),
      variable('services/myinsurance.com/api-key'),
    ]
  end
end

group '/employees' do |employees|
    variable('certs/myorg.com/hrapp1').permit %w(read execute), employees
  end
end

group('/hradmins') do |hradmins|
    global_secrets.each do |secret|
        secret.permit %w(read execute), hradmins
end

group('/operations') do |operations|
    global_secrets.each do |secret|
        secret.permit %w(read execute), operations
end

