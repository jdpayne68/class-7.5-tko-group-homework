#Resource via https://registry.terraform.io/providers/hashicorp/google/latest/docs and help from teammates and also google "how to create a text file via terraform"

resource "local_file" "food_text" {
  content  = "I do love pizza! Especially meat lovers pizza with extra cheese."
  filename = "${path.module}/food.txt"
}