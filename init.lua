
---@param chatcommands chatcommands
local function registerCommandAIC(chatcommands)
  local parser = chatcommands:argparser("/aic")
  parser:argument("character", "AI character: all or number 1-16")
  parser:argument("field", "AI character field")
  parser:argument("value", "The new value. If not specified, prints the current value"):args('?')

  chatcommands:registerChatCommand(parser, function(args, command)
    local characters = {}
    if args.character == "all" then
      characters = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}
    else
      characters = { args.character }
    end

    local field = args.field

    if args.value == nil then
      log(2, "getting value")
      local resultMsg = string.format("%s %s => ", args.character, field)
      for k, character in ipairs(characters) do
        resultMsg = resultMsg .. string.format("%s", modules.aicloader:getAICValue(character, field))
        if characters[k+1] ~= nil then
          resultMsg = resultMsg .. ","
        end
      end

      log(1, string.format("Result msg: %s", resultMsg))

      return false, resultMsg
    end

    log(2, "setting value")

    local value = args.value
    for k, character in ipairs(characters) do
      modules.aicloader:setAICValue(character, field, value)
    end

    return false, nil
  end)
end

return {
  enable = function(self, config)
    ---@type chatcommands
    local chatcommands = modules.chatcommands

    registerCommandAIC(chatcommands)
  end,
  disable = function(self, config) end,
}