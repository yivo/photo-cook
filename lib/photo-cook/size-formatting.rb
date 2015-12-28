module PhotoCook
  def self.format_size(bytes, precision = 2)
    if bytes >= 1_000_000_000.0
      "#{(bytes / 1_000_000_000.0).round(precision)} GB"

    elsif bytes >= 1_000_000.0
      "#{(bytes / 1_000_000.0).round(precision)} MB"

    else
      "#{(bytes / 1_000.0).round(precision)} KB"
    end
  end
end