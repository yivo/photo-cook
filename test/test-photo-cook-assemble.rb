# frozen_string_literal: true
require 'test/unit'
require 'shoulda-context'
require 'photo-cook'
require 'helper'

class PhotoCookAssembleTest < Test::Unit::TestCase
  def test_assemble
    assert_equal('/uploads/resize-cache/fit-300x300/dog.png', PhotoCook::Resize.uri('/uploads/dog.png', 300, 300, :fit))
    assert_equal('/uploads/resize-cache/fill-300x300/dog.png', PhotoCook::Resize.uri('/uploads/dog.png', 300, 300, :fill))
    assert_equal('/uploads/photos/1/md5/resize-cache/fill-300x300/dog.png', PhotoCook::Resize.uri('/uploads/photos/1/md5/dog.png', 300, 300, :fill))
  end

  def test_strip
    assert_equal('/uploads/dog.png', PhotoCook::Resize.strip('/uploads/resize-cache/fit-300x300/dog.png'))
    assert_equal('/uploads/dog.png', PhotoCook::Resize.strip('/uploads/resize-cache/fill-300x300/dog.png'))
    assert_equal('/uploads/photos/1/md5/dog.png', PhotoCook::Resize.strip('/uploads/photos/1/md5/resize-cache/fill-300x300/dog.png'))
  end
end
