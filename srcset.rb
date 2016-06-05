# def test_something
#   def lol(maxw, maxh, w, h)
#     ary = []
#
#     w = w.floor
#     maxw = maxw.floor
#     # maxx = [maxw % 160 == 0 ? maxw : 160 * (1 + maxw / 160), (w*3) % 160 == 0 ? (w*3) : 160 * (1 + (w*3) / 160)].min
#     maxx = [maxw, w * 3].min
#
#     x = 320
#     ary << [w, h] if w < x
#
#     while x <= maxx
#       inc = x / w.to_f
#       ary << [(w * inc).floor, (h * inc).floor]
#
#       if w > x && w < (x + 160)
#         ary << [w, h]
#       end
#
#       x += 160
#     end
#
#     ary
#   end
#
#   puts
#   puts lol(1000, 800, 350, 350)
#
#
#
#
# end
