module PhotoCook
  class MagickPhoto < MiniMagick::Image
    attr_accessor :source_path
    attr_accessor :resized_path
  end
end