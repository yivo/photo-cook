module PhotoCook
  module CarrierWave
    def resize(w, h, mode = :fit)
      PhotoCook.resize(url, w, h, mode)
    end

    def base64_uri(w, h, mode = :fit)
      PhotoCook.base64_uri(url, w, h, mode)
    end

    def optimize
      PhotoCook.perform_optimization(current_path)
    end
  end
end
