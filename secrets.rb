hr_secrets = dev_secrets = research_secrets = qa_secrets = nil
hr_hosts = dev_hosts = research_hosts = qa_hosts = nil
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

    hr_hosts = [
      host('hr1.myorg.com'),
      host('hr2.myorg.com'),
      host('hr3.myorg.com')
    ]

    dev_hosts = [
      host('db.myorg.com'),
      host('build1.myorg.com'),
      host('build2.myorg.com')
    ]

    research_hosts = [
      host('modeling1.myorg.com'),
      host('modeling2.myorg.com'),
      host('modeling3.myorg.com'),
      host('modeling4.myorg.com'),
      host('scope.myorg.com')
    ]

    qa_hosts = (1..10).map { |i| host("qa#{i}.myorg.com") }
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
        hr_hosts.each { |host| add_host host }
      end

      layer 'development-hosts' do |layer|
        dev_secrets.each { |secret| can 'execute', secret }
        add_member "use_host", group('/developers')
        dev_hosts.each { |host| add_host host }
      end

      layer 'research-hosts' do |layer|
        research_secrets.each { |secret| can 'execute', secret }
        add_member "use_host", group('/researchers')
        research_hosts.each { |host| add_host host }
      end

      layer 'qa-hosts' do |layer|
        qa_secrets.each { |secret| can 'execute', secret }
        add_member "use_host", group('/qa')
        qa_hosts.each { |host| add_host host }
      end
    end
  end
end

hr_hosts.each { |host| host.resource.annotations['host_type'] = 'SOX' }
