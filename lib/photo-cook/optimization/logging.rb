# encoding: utf-8
# frozen_string_literal: true

PhotoCook.subscribe 'optimization:success' do |path, original_size, new_size, msec|
  PhotoCook.log do
    diff = original_size - new_size
    log "Optimization successfully performed"
    log "File path:     #{path}"
    log "Original size: #{PhotoCook::Utils.format_size(original_size)}"
    log "New size:      #{PhotoCook::Utils.format_size(new_size)}"
    log "Saved:         #{PhotoCook::Utils.format_size(diff)} / #{diff} bytes / #{(diff / original_size.to_f * 100.0).round(2)}%"
    log "Completed in:  #{msec.round(1)}ms"
  end
end

PhotoCook.subscribe 'optimization:failure' do |path|
  PhotoCook.log do
    log "Optimization failed because one of the following:"
    log "1) photo is already optimized;"
    log "2) some problem occurred with optimization utility."
    log "Related to: #{path}"
  end
end
