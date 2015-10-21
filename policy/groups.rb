group 'employees'

group 'hr-admin' do
  owns do
    group 'hr'
  end
end

group 'developers-admin' do
  owns do
    group 'developers'
  end
end

group 'researchers-admin' do
  owns do
    group 'researchers'
  end
end

group 'qa-admin' do
  owns do
    group 'qa'
  end
end

group 'operations-admin' do
  owns do
    group 'operations'
  end
end

group 'ci-admin' do
  owns do
    group 'ci'
  end
end
