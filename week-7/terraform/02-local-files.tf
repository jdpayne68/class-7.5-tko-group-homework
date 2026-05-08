# ----------------------------------------------------------------
# LOCAL FILES
# ----------------------------------------------------------------

resource "local_file" "favorite_food" {
  content  = "lamb rib chops"
  filename = "${path.module}/rendered/favorite-food.txt"
}