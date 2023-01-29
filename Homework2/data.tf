data "template_file" "user_data" {
  template = "${file("install_nginx.sh")}"
}