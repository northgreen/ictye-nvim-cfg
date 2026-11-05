local vm_active = false
local timer = vim.loop.new_timer()
timer:start(1000, 1000, vim.schedule_wrap(function()
  local current_vm_active = vim.fn.exists('b:visual_multi') == 1
  if current_vm_active and not vm_active then
    vm_active = true
    smear_cursor.toggle()

  elseif not current_vm_active and vm_active then
    vm_active = false
    smear_cursor.toggle()
    print("awa")
  end
end))
