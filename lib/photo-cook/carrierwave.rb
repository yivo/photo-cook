module PhotoCook
  module CarrierWave
    def resize(*args)
      PhotoCook.resize(url, *args)
    end

    def base64_uri(*args)
      PhotoCook.base64_uri(url, *args)
    end

    def hresize(*args)
      PhotoCook.hresize(url, *args)
    end

    def vresize(*args)
      PhotoCook.vresize(url, *args)
    end

    # TODO Problem with changed file size after optimization and WYSIWYG

    def optimize_photo
      PhotoCook::OptimizationJob.perform_now(current_path)
    end
  end
end