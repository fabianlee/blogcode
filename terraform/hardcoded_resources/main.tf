
resource "local_file" "foo1" {
  content  = "this is foo1"
  filename = "${path.module}/foo1.txt"
}
resource "local_file" "foo2" {
  content  = "this is foo2"
  filename = "${path.module}/foo2.txt"
}
