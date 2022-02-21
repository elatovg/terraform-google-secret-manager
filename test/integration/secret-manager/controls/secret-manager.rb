project_id  = attribute('project_id')
project_number  = attribute('project_number')
secret      = "secret-1"



describe command("gcloud --project='#{project_id}' secrets describe #{secret}") do
  its(:exit_status) { should be_zero }
  it { expect(subject.stdout).to match(%r{name: projects/#{project_number}/secrets/#{secret}}) }
end