# frozen_string_literal: true
require 'test/unit'
require 'shoulda-context'
require 'photo-cook'

class PhotoCookTest < Test::Unit::TestCase
  def test_resize_size_to_fill
    assert_same_dimensions(PhotoCook::Resize::Calculations.size_to_fill(1000, 800, 640,  640),  [640, 640])
    assert_same_dimensions(PhotoCook::Resize::Calculations.size_to_fill(1000, 800, 1280, 1280), [800, 800])
    assert_same_dimensions(PhotoCook::Resize::Calculations.size_to_fill(1000, 800, 3840, 3840), [800, 800])
    assert_same_dimensions(PhotoCook::Resize::Calculations.size_to_fill(1000, 800, 1000, 1280), [625, 800])
    assert_same_dimensions(PhotoCook::Resize::Calculations.size_to_fill(1000, 800, 2000, 2560), [625, 800])
    assert_same_dimensions(PhotoCook::Resize::Calculations.size_to_fill(264,  175, 400,  300),  [233, 175])
    assert_same_dimensions(PhotoCook::Resize::Calculations.size_to_fill(331,  277, 680,  360),  [331, 175])
    assert_same_dimensions(PhotoCook::Resize::Calculations.size_to_fill(259,  179, 260,  180),  [258, 179])
    assert_same_dimensions(PhotoCook::Resize::Calculations.size_to_fill(259,  179, 520,  360),  [258, 179])
    assert_same_dimensions(PhotoCook::Resize::Calculations.size_to_fill(455,  683, 800,  700),  [455, 398])
    assert_same_dimensions(PhotoCook::Resize::Calculations.size_to_fill(683,  455, 800,  700),  [520, 455])
    assert_same_dimensions(PhotoCook::Resize::Calculations.size_to_fill(444,  455, 1200, 1255), [435, 455])
  end

  def test_size_to_fit
    assert_same_dimensions(PhotoCook::Resize::Calculations.size_to_fit(400,  300,  200,  700),  [200,  150])
    assert_same_dimensions(PhotoCook::Resize::Calculations.size_to_fit(1920, 1200, 2560, 2560), [1920, 1200])
  end

  def assert_same_dimensions(d1, d2)
    assert_same(d2[0], d1[0])
    assert_same(d2[1], d1[1])
  end
end
