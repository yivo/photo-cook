# encoding: utf-8
# frozen_string_literal: true

PhotoCook.subscribe 'resize:middleware:match' do |uri|
  PhotoCook.log do
    log "PhotoCook::Resize::Middleware matched request for photo resize"
    log "Request URI: #{uri}"
  end
end

PhotoCook.subscribe 'resize' do |photo, msec|
  PhotoCook.log do
    log "Performed resize"
    log "Source path:             #{photo.source_path}"
    log "Store path:              #{photo.store_path}"
    log "Max width:               #{photo.max_width}px"
    log "Max height:              #{photo.max_height}px"
    log "Desired width:           #{photo.desired_width}px"
    log "Desired height:          #{photo.desired_height}px"
    log "Desired aspect ratio:    #{photo.desired_aspect_ratio.round(3)}"
    log "Calculated width:        #{photo.calculated_width}px"
    log "Calculated height:       #{photo.calculated_height}px"
    log "Calculated aspect ratio: #{photo.calculated_aspect_ratio.round(3)}"
    log "Resize mode:             #{photo.resize_mode}"
    log "Completed in:            #{msec.round(1)}ms"
  end
end
