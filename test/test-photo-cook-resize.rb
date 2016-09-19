# frozen_string_literal: true
require 'test/unit'
require 'shoulda-context'
require 'photo-cook'
require 'helper'
require 'fileutils'

Test::Unit.at_start { PhotoCook.disable_logging! }
Test::Unit.at_exit  { FileUtils.rmtree(TestHelper.tmp_dirpath) }

class PhotoCookResizeTest < Test::Unit::TestCase
  def test_resize_fit
    source = File.join(TestHelper.fixtures_dirpath, 'dog.png')
    store  = File.join(TestHelper.tmp_dirpath, 'dog-200x200-fit.png')
    PhotoCook::Resize.perform(source, store, 200, 200, :fit)

    photo = MiniMagick::Image.open(store)
    assert_nothing_raised { photo.validate! }
    assert_equal(photo[:dimensions][0], 200)
    assert_equal(photo[:dimensions][1], 186)
  end

  def test_resize_fit_high_resolution
    source = File.join(TestHelper.fixtures_dirpath, 'dog.png')
    store  = File.join(TestHelper.tmp_dirpath, 'dog-1000x1000-fit.png')
    PhotoCook::Resize.perform(source, store, 1000, 1000, :fit)

    photo = MiniMagick::Image.open(store)
    assert_nothing_raised { photo.validate! }
    assert_equal(photo[:dimensions][0], 800)
    assert_equal(photo[:dimensions][1], 745)
  end

  def test_resize_fill
    source = File.join(TestHelper.fixtures_dirpath, 'dog.png')
    store  = File.join(TestHelper.tmp_dirpath, 'dog-200x200-fill.png')
    PhotoCook::Resize.perform(source, store, 200, 200, :fill)

    photo = MiniMagick::Image.open(store)
    assert_nothing_raised { photo.validate! }
    assert_equal(photo[:dimensions][0], 200)
    assert_equal(photo[:dimensions][1], 200)
  end

  def test_resize_fill_high_resolution
    source = File.join(TestHelper.fixtures_dirpath, 'dog.png')
    store  = File.join(TestHelper.tmp_dirpath, 'dog-1000x1000-fill.png')
    PhotoCook::Resize.perform(source, store, 1000, 1000, :fill)

    photo = MiniMagick::Image.open(store)
    assert_nothing_raised { photo.validate! }
    assert_equal(photo[:dimensions][0], 745)
    assert_equal(photo[:dimensions][1], 745)
  end

  def test_resize_base64
    source = File.join(TestHelper.fixtures_dirpath, 'dog.png')
    store  = File.join(TestHelper.tmp_dirpath, 'dog-10x10-fit.png')
    base64 = PhotoCook::Resize::base64_uri_from_source_path(source, store, 10, 10, :fit)
    assert_match(/data:image\/png;base64,/, base64)
  end
end
