
local MODALS_BY_KEY = {
  ["0"] = -1,
  ["off"] = -1,
  ["none"] = -1,
  ["1"] = 1,
  ["2"] = 2,
  ["3"] = 3,
  ["4"] = 4,
  ["202"] = 202,
}

---@param chatcommands chatcommands
local function register(chatcommands)
    -- 0x004a9ed0
  local _activateModalDialog = core.exposeCode(core.AOBScan("53 55 33 ED 39 6C 24 10"), 3, 1)

  -- Disable right click last active unit logic: 00434d7e
  core.writeCode(core.AOBScan("C7 ? ? ? ? ? ? ? ? ? 7E 14"), {0x90 ,0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90})
  -- 02403678
  local _, mmc2 = utils.AOBExtract("B9 I(? ? ? ?) E8 ? ? ? ? B9 ? ? ? ? 89 ? ? ? ? ? 89 ? ? ? ? ? 89 ? ? ? ? ?")
  
  local command = chatcommands:argparser("/view")
  command:command_target("command") -- store command in var "command"
  local modal = command:command("modal", "view modal menu")
  modal:argument("id", "modal menu to view")

  chatcommands:registerChatCommand(command, function(args, cmd)
    log(2, string.format("view: %s", args.command))
    for k, v in pairs(args) do
      log(2, string.format("  arg: [%s] = %s (%s)", k, tostring(v), type(v)))
    end

    if args.command == "modal" then
      local id = MODALS_BY_KEY[args.id]
      if id == nil then
        local available = "available: "
        for k, v in pairs(MODALS_BY_KEY) do
          available = available .. tostring(k) .. ", "
        end
        log(WARNING, string.format("modal with id '%s' does not exist. available: %s", tostring(id), available))

        id = tonumber(args.id) -- try the raw
        if id == nil then
          error(string.format("invalid id '%s'", tostring(args.id)))
        end

        log(1, string.format("trying non-registered id: %s", id))
      end

      _activateModalDialog(mmc2, id, 0)

      return false
    end

    error(string.format("unsupported command: %s", args.command))
  end )

end

return {
  register = register,
}