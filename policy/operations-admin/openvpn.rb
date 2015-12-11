policy "openvpn/v1" do
  admins = group "admins"
  users  = group "users"

  layer do
    add_member "admin_host", admins
    add_member "use_host", users
  end
end