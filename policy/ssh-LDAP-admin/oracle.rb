policy "oracle/v1" do
  admin = group "admin"
  
  layer do
    add_member "admin_host", admin
  end
end