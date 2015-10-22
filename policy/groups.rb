employees = group 'employees'

group 'hr-admin' do
  owns do
    group 'hr' do |g|
      employees.add_member g
    end
  end
end

group 'developers-admin' do
  owns do
    group 'developers' do |g|
      employees.add_member g
    end
  end
end

group 'researchers-admin' do
  owns do
    group 'researchers' do |g|
      employees.add_member g
    end
  end
end

group 'qa-admin' do
  owns do
    group 'qa' do |g|
      employees.add_member g
    end
  end
end

group 'operations-admin' do
  owns do
    group 'operations' do |g|
      employees.add_member g
    end
  end
end

group 'ci-admin' do
  owns do
    group 'ci' do |g|
      employees.add_member g
    end
  end
end
