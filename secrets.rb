hr_secrets = dev_secrets = research_secrets = qa_secrets = nil
qa_report_key = nil

group '/operations' do
  owns do
    hr_secrets = [
      resource('webservice', 'myorg.com/hr/app1'),
      resource('webservice', 'myorg.com/hr/reporting-api-key'),
      resource('webservice', 'mybank.com/api-key'),
      resource('webservice', 'myinsurance.com/api-key')
    ]

    dev_secrets = [
      variable('licenses/compiler'),
      variable('licenses/profiler'),
      variable('licenses/coverity'),
    ]

    research_secrets = [
      resource('webservice', 'researchtoday.com/api-key'),
      resource('webservice', 'innovation.com/api-key'),
      variable('licenses/modeler')
    ]

    qa_secrets = [
      resource('webservice', 'myorg.com/qa/ci_tool/api-key'),
      qa_report_key = resource('webservice', 'myorg.com/qa/ci_tool/report-api-key')
    ]
  end

  group '/employees' do |employees|
    variable('certs/myorg.com/hrapp1').permit %w(read execute), employees
  end

  group('/hradmins') do |hradmins|
    hr_secrets.each do |secret|
      secret.permit %w(read execute), hradmins
    end
  end

  group('/developers') do |developers|
    dev_secrets.each do |secret|
      secret.permit %w(read execute), developers
    end
    qa_report_key.permit %w(execute), developers
  end

  group('/researchers') do |researchers|
    research_secrets.each do |secret|
      secret.permit %w(read execute), researchers
    end
  end

  group('/qa') do |qa|
    qa_secrets.each do |secret|
      secret.permit %w(read update execute), qa
    end
  end

  group '/operations' do
    owns do
      layer 'hr-hosts' do |layer|
        hr_secrets.each { |secret| can 'execute', secret }
        add_member "use_host", group('/hradmins')
      end

      layer 'development-hosts' do |layer|
        dev_secrets.each { |secret| can 'execute', secret }
        add_member "use_host", group('/developers')
      end

      layer 'research-hosts' do |layer|
        research_secrets.each { |secret| can 'execute', secret }
        add_member "use_host", group('/researchers')
      end

      layer 'qa-hosts' do |layer|
        qa_secrets.each { |secret| can 'execute', secret }
        add_member "use_host", group('/qa')
      end
    end
  end
end
